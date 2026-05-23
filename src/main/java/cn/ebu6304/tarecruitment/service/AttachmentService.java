package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.model.AttachmentRecord;
import cn.ebu6304.tarecruitment.repository.AttachmentRepository;
import jakarta.servlet.http.Part;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;

public class AttachmentService {
    private static final int MAX_EXTRACTED_TEXT_CHARS = 12000;

    private final AttachmentRepository attachmentRepository;
    private final Path uploadRoot;

    public AttachmentService(AttachmentRepository attachmentRepository, Path uploadRoot) {
        this.attachmentRepository = attachmentRepository;
        this.uploadRoot = uploadRoot;
        ensureUploadRoot();
    }

    public List<AttachmentRecord> saveAttachments(
            String applicationId,
            String applicantId,
            String jobId,
            Part cvFile,
            Part transcriptFile
    ) {
        List<AttachmentRecord> saved = new ArrayList<>();
        saveSingle(applicationId, applicantId, jobId, "CV", cvFile).ifPresent(saved::add);
        saveSingle(applicationId, applicantId, jobId, "TRANSCRIPT", transcriptFile).ifPresent(saved::add);
        return saved;
    }

    public List<AttachmentRecord> listByApplicationId(String applicationId) {
        return attachmentRepository.listByApplicationId(applicationId);
    }

    public String latestCvExtractedText(String applicantId, String jobId) {
        return attachmentRepository
                .latestByApplicantJobAndType(applicantId, jobId, "CV")
                .map(AttachmentRecord::extractedText)
                .filter(text -> text != null && !text.isBlank())
                .orElse("");
    }

    public Optional<AttachmentRecord> findByAttachmentId(String attachmentId) {
        return attachmentRepository.findByAttachmentId(attachmentId);
    }

    public Path resolvePath(AttachmentRecord record) {
        return uploadRoot.resolve(record.storedRelativePath()).normalize();
    }

    public byte[] readFileBytes(AttachmentRecord record) {
        Path path = resolvePath(record);
        try {
            return Files.readAllBytes(path);
        } catch (NoSuchFileException e) {
            throw new IllegalStateException("Attachment file not found: " + path, e);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read attachment file: " + path, e);
        }
    }

    private Optional<AttachmentRecord> saveSingle(
            String applicationId,
            String applicantId,
            String jobId,
            String attachmentType,
            Part part
    ) {
        if (part == null || part.getSize() <= 0) {
            return Optional.empty();
        }

        String rawFilename = part.getSubmittedFileName();
        String originalFilename = safeFilename(rawFilename == null ? attachmentType.toLowerCase(Locale.ROOT) : rawFilename);
        String extension = fileExtension(originalFilename);
        String attachmentId = UUID.randomUUID().toString().replace("-", "").substring(0, 16);

        String relativePath = applicantId + "/" + applicationId + "/" + attachmentType.toLowerCase(Locale.ROOT)
                + "-" + attachmentId + (extension.isBlank() ? "" : "." + extension);
        Path target = uploadRoot.resolve(relativePath).normalize();
        ensureParent(target);

        try (InputStream input = part.getInputStream()) {
            Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to save attachment: " + originalFilename, e);
        }

        String extractedText = extractTextIfSupported(target, part.getContentType(), originalFilename);
        String uploadedAt = OffsetDateTime.now().toString();

        AttachmentRecord record = new AttachmentRecord(
                attachmentId,
                applicationId,
                applicantId,
                jobId,
                attachmentType,
                originalFilename,
                relativePath,
                part.getContentType(),
                part.getSize(),
                extractedText,
                uploadedAt
        );
        attachmentRepository.append(record);
        return Optional.of(record);
    }

    private String extractTextIfSupported(Path filePath, String contentType, String originalFilename) {
        String lowerName = originalFilename == null ? "" : originalFilename.toLowerCase(Locale.ROOT);
        String lowerContentType = contentType == null ? "" : contentType.toLowerCase(Locale.ROOT);

        if (lowerName.endsWith(".pdf") || lowerContentType.contains("pdf")) {
            return extractPdfText(filePath);
        }
        if (lowerName.endsWith(".txt") || lowerContentType.startsWith("text/plain")) {
            try {
                String raw = Files.readString(filePath, StandardCharsets.UTF_8);
                return truncate(raw);
            } catch (IOException e) {
                return "";
            }
        }
        return "";
    }

    private String extractPdfText(Path filePath) {
        try (PDDocument doc = PDDocument.load(filePath.toFile())) {
            PDFTextStripper stripper = new PDFTextStripper();
            String text = stripper.getText(doc);
            return truncate(text);
        } catch (IOException e) {
            return "";
        }
    }

    private static String truncate(String text) {
        if (text == null) {
            return "";
        }
        String trimmed = text.trim();
        if (trimmed.length() <= MAX_EXTRACTED_TEXT_CHARS) {
            return trimmed;
        }
        return trimmed.substring(0, MAX_EXTRACTED_TEXT_CHARS);
    }

    private static String safeFilename(String input) {
        String name = input.replace("\\", "/");
        int idx = name.lastIndexOf('/');
        if (idx >= 0) {
            name = name.substring(idx + 1);
        }
        return name.replaceAll("[^A-Za-z0-9._-]", "_");
    }

    private static String fileExtension(String filename) {
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) {
            return "";
        }
        return filename.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    private void ensureUploadRoot() {
        try {
            Files.createDirectories(uploadRoot);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to create upload directory: " + uploadRoot, e);
        }
    }

    private void ensureParent(Path path) {
        Path parent = path.getParent();
        if (parent == null) {
            return;
        }
        try {
            Files.createDirectories(parent);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to create attachment parent directory: " + parent, e);
        }
    }
}

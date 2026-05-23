package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.model.AttachmentRecord;
import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ApplicationServlet", urlPatterns = "/applications")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024L, maxRequestSize = 20 * 1024 * 1024L)
public class ApplicationServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_TA);
            SubmitApplicationRequest payload = readSubmitRequest(request);
            syncApplicantProfile(current.userId(), payload);
            ApplicationService.SubmitResponse submitResponse = appContext.applicationService().submitApplication(
                    payload.applicationId(),
                    current.userId(),
                    payload.jobId()
            );
            List<AttachmentRecord> attachments = saveAttachmentsIfAny(request, current.userId(), submitResponse.record());
            int status = submitResponse.created() ? 201 : 200;
            writeJson(response, status, Map.of(
                    "created", submitResponse.created(),
                    "record", submitResponse.record(),
                    "attachments", attachments.stream().map(this::toAttachmentResponse).toList()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_TA);
            int page = readIntParameter(request, "page", 1);
            int size = readIntParameter(request, "size", 10);
            List<ApplicationRecord> items = appContext.applicationService().queryByApplicant(current.userId(), page, size);
            writeJson(response, 200, Map.of(
                    "applicantId", current.userId(),
                    "page", page,
                    "size", size,
                    "count", items.size(),
                    "items", items
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    private void syncApplicantProfile(String userId, SubmitApplicationRequest payload) {
        appContext.userRepository().findById(userId).ifPresent(existing -> {
            String nextSkills = normalize(payload.skills(), existing.skills());
            String nextResume = normalize(payload.experience(), existing.resumeText());

            boolean changed = !nextSkills.equals(existing.skills())
                    || !nextResume.equals(existing.resumeText());
            if (!changed) {
                return;
            }

            UserProfile updated = new UserProfile(
                    existing.userId(),
                    existing.displayName(),
                    existing.role(),
                    existing.identifier(),
                    existing.email(),
                    existing.passwordHash(),
                    nextSkills,
                    nextResume,
                    OffsetDateTime.now().toString()
            );
            appContext.userRepository().upsert(updated);
        });
    }

    private SubmitApplicationRequest readSubmitRequest(HttpServletRequest request) throws IOException, ServletException {
        if (!isMultipart(request)) {
            return readJson(request, SubmitApplicationRequest.class);
        }
        return new SubmitApplicationRequest(
                request.getParameter("applicationId"),
                request.getParameter("applicantId"),
                request.getParameter("jobId"),
                request.getParameter("fullName"),
                request.getParameter("studentId"),
                request.getParameter("email"),
                request.getParameter("skills"),
                request.getParameter("experience")
        );
    }

    private boolean isMultipart(HttpServletRequest request) {
        String contentType = request.getContentType();
        return contentType != null && contentType.toLowerCase().startsWith("multipart/");
    }

    private List<AttachmentRecord> saveAttachmentsIfAny(
            HttpServletRequest request,
            String applicantId,
            ApplicationRecord record
    ) throws IOException, ServletException {
        if (!isMultipart(request)) {
            return List.of();
        }
        Part cvPart = request.getPart("cvFile");
        Part transcriptPart = request.getPart("transcriptFile");
        return appContext.attachmentService().saveAttachments(
                record.applicationId(),
                applicantId,
                record.jobId(),
                cvPart,
                transcriptPart
        );
    }

    private Map<String, Object> toAttachmentResponse(AttachmentRecord record) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("attachmentId", record.attachmentId());
        item.put("attachmentType", record.attachmentType());
        item.put("originalFilename", record.originalFilename());
        item.put("sizeBytes", record.sizeBytes());
        item.put("uploadedAt", record.uploadedAt());
        item.put("hasExtractedText", record.extractedText() != null && !record.extractedText().isBlank());
        return item;
    }

    private static String normalize(String preferred, String fallback) {
        if (preferred != null && !preferred.isBlank()) {
            return preferred.trim();
        }
        return fallback == null ? "" : fallback;
    }

    public record SubmitApplicationRequest(
            String applicationId,
            String applicantId,
            String jobId,
            String fullName,
            String studentId,
            String email,
            String skills,
            String experience
    ) {
    }
}

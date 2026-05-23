package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.AttachmentRecord;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

public class AttachmentRepository {
    private final JsonlFileStore<AttachmentRecord> fileStore;

    public AttachmentRepository(JsonlFileStore<AttachmentRecord> fileStore) {
        this.fileStore = fileStore;
    }

    public synchronized void append(AttachmentRecord record) {
        fileStore.append(record);
    }

    public synchronized List<AttachmentRecord> listByApplicationId(String applicationId) {
        List<AttachmentRecord> result = new ArrayList<>();
        fileStore.forEach(record -> {
            if (record.applicationId() != null && record.applicationId().equals(applicationId)) {
                result.add(record);
            }
        });
        result.sort(Comparator.comparing(AttachmentRecord::uploadedAt).reversed());
        return result;
    }

    public synchronized Optional<AttachmentRecord> findByAttachmentId(String attachmentId) {
        if (attachmentId == null || attachmentId.isBlank()) {
            return Optional.empty();
        }
        List<AttachmentRecord> matches = new ArrayList<>();
        fileStore.forEach(record -> {
            if (record.attachmentId() != null && record.attachmentId().equals(attachmentId)) {
                matches.add(record);
            }
        });
        matches.sort(Comparator.comparing(AttachmentRecord::uploadedAt).reversed());
        return matches.stream().findFirst();
    }

    public synchronized Optional<AttachmentRecord> latestByApplicantJobAndType(
            String applicantId,
            String jobId,
            String attachmentType
    ) {
        List<AttachmentRecord> candidates = new ArrayList<>();
        fileStore.forEach(record -> {
            if (record.applicantId() != null
                    && record.jobId() != null
                    && record.attachmentType() != null
                    && record.applicantId().equals(applicantId)
                    && record.jobId().equals(jobId)
                    && record.attachmentType().equalsIgnoreCase(attachmentType)) {
                candidates.add(record);
            }
        });
        candidates.sort(Comparator.comparing(AttachmentRecord::uploadedAt).reversed());
        return candidates.stream().findFirst();
    }
}

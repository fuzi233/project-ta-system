package cn.ebu6304.tarecruitment.model;

public record AttachmentRecord(
        String attachmentId,
        String applicationId,
        String applicantId,
        String jobId,
        String attachmentType,
        String originalFilename,
        String storedRelativePath,
        String contentType,
        long sizeBytes,
        String extractedText,
        String uploadedAt
) {
}

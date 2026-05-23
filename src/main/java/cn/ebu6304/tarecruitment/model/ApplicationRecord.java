package cn.ebu6304.tarecruitment.model;

public record ApplicationRecord(
        String applicationId,
        String applicantId,
        String jobId,
        String status,
        String submittedAt
) {
}

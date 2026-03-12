package cn.ebu6304.tarecruitment.model;

public record JobPosting(
        String jobId,
        String title,
        String moduleCode,
        String requiredSkills,
        int slots,
        String status,
        String createdBy,
        String createdAt
) {
}

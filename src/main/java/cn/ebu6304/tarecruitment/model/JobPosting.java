package cn.ebu6304.tarecruitment.model;

public record JobPosting(
        String jobId,
        String title,
        String moduleCode,
        String requiredSkills,
        int slots,
        Integer hoursPerWeek,
        String applicationDeadline,
        Integer monthlyStipend,
        String status,
        String createdBy,
        String createdAt
) {
}

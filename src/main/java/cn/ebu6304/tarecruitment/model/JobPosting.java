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
    public JobPosting(
            String jobId,
            String title,
            String moduleCode,
            String requiredSkills,
            int slots,
            String status,
            String createdBy,
            String createdAt
    ) {
        this(jobId, title, moduleCode, requiredSkills, slots, 10, "2099-12-31", 800, status, createdBy, createdAt);
    }
}

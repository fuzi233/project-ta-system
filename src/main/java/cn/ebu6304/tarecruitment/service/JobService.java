package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.JobRepository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

public class JobService {
    private final JobRepository jobRepository;

    public JobService(JobRepository jobRepository) {
        this.jobRepository = jobRepository;
    }

    public CreateJobResponse createJob(
            String jobId,
            String title,
            String moduleCode,
            String requiredSkills,
            int slots,
            Integer hoursPerWeek,
            String applicationDeadline,
            Integer monthlyStipend,
            String createdBy
    ) {
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        String normalizedTitle = Validators.requireNonBlank(title, "title");
        String normalizedModule = Validators.requireNonBlank(moduleCode, "moduleCode");
        String normalizedSkills = Validators.requireNonBlank(requiredSkills, "requiredSkills");
        String normalizedDeadline = Validators.requireNonBlank(applicationDeadline, "applicationDeadline");
        String normalizedCreator = Validators.requireNonBlank(createdBy, "createdBy");
        int normalizedSlots = Validators.requirePositive(slots, "slots");
        int normalizedHours = Validators.requirePositive(hoursPerWeek == null ? 0 : hoursPerWeek, "hoursPerWeek");
        int normalizedStipend = Validators.requirePositive(monthlyStipend == null ? 0 : monthlyStipend, "monthlyStipend");

        JobPosting record = new JobPosting(
                normalizedJobId,
                normalizedTitle,
                normalizedModule,
                normalizedSkills,
                normalizedSlots,
                normalizedHours,
                normalizedDeadline,
                normalizedStipend,
                "OPEN",
                normalizedCreator,
                OffsetDateTime.now().toString()
        );
        boolean created = jobRepository.createIfAbsent(record);
        return new CreateJobResponse(created, record);
    }

    public List<JobPosting> listJobs(String query, String status, int page, int size) {
        int normalizedPage = Validators.normalizePage(page);
        int normalizedSize = Validators.normalizeSize(size);
        return jobRepository.list(query, status, normalizedPage, normalizedSize);
    }

    public Optional<JobPosting> findByJobId(String jobId) {
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        return jobRepository.findByJobId(normalizedJobId);
    }

    public List<JobPosting> listJobsByCreator(String creatorId, int page, int size) {
        String normalizedCreator = Validators.requireNonBlank(creatorId, "creatorId");
        int normalizedPage = Validators.normalizePage(page);
        int normalizedSize = Validators.normalizeSize(size);
        return jobRepository.listByCreator(normalizedCreator, normalizedPage, normalizedSize);
    }

    public record CreateJobResponse(boolean created, JobPosting record) {
    }
}

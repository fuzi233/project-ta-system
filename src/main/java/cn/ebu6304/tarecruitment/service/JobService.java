package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.JobRepository;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
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
            String createdBy
    ) {
        return createJob(jobId, title, moduleCode, requiredSkills, slots, 10, "2099-12-31", 800, createdBy);
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
        validateHoursPerWeek(normalizedHours);
        validateDeadlineNotPast(normalizedDeadline);

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

    public UpdateJobResponse updateJob(
            String jobId,
            String title,
            String moduleCode,
            String requiredSkills,
            int slots,
            Integer hoursPerWeek,
            String applicationDeadline,
            Integer monthlyStipend,
            String updatedBy
    ) {
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        String normalizedTitle = Validators.requireNonBlank(title, "title");
        String normalizedModule = Validators.requireNonBlank(moduleCode, "moduleCode");
        String normalizedSkills = Validators.requireNonBlank(requiredSkills, "requiredSkills");
        String normalizedDeadline = Validators.requireNonBlank(applicationDeadline, "applicationDeadline");
        String normalizedUpdater = Validators.requireNonBlank(updatedBy, "updatedBy");
        int normalizedSlots = Validators.requirePositive(slots, "slots");
        int normalizedHours = Validators.requirePositive(hoursPerWeek == null ? 0 : hoursPerWeek, "hoursPerWeek");
        int normalizedStipend = Validators.requirePositive(monthlyStipend == null ? 0 : monthlyStipend, "monthlyStipend");
        validateHoursPerWeek(normalizedHours);
        validateDeadlineNotPast(normalizedDeadline);

        JobPosting existing = jobRepository.findByJobId(normalizedJobId)
                .orElseThrow(() -> new ApiException(404, "Job not found for jobId=" + normalizedJobId));
        if (!existing.createdBy().equals(normalizedUpdater)) {
            throw new ApiException(403, "MO can only update own jobs");
        }

        JobPosting updated = new JobPosting(
                existing.jobId(),
                normalizedTitle,
                normalizedModule,
                normalizedSkills,
                normalizedSlots,
                normalizedHours,
                normalizedDeadline,
                normalizedStipend,
                existing.status(),
                existing.createdBy(),
                existing.createdAt()
        );
        boolean updatedRecord = jobRepository.update(updated);
        if (!updatedRecord) {
            throw new ApiException(500, "Failed to update job for jobId=" + normalizedJobId);
        }
        return new UpdateJobResponse(true, updated);
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

    public record UpdateJobResponse(boolean updated, JobPosting record) {
    }

    private static void validateHoursPerWeek(int hoursPerWeek) {
        if (hoursPerWeek > 40) {
            throw new ApiException(400, "hoursPerWeek must not exceed 40");
        }
    }

    private static void validateDeadlineNotPast(String deadline) {
        LocalDate parsed = parseDeadline(deadline);
        if (parsed.isBefore(LocalDate.now())) {
            throw new ApiException(400, "applicationDeadline cannot be in the past");
        }
    }

    private static LocalDate parseDeadline(String deadline) {
        String trimmed = deadline == null ? "" : deadline.trim();
        for (DateTimeFormatter formatter : List.of(DateTimeFormatter.ISO_LOCAL_DATE, DateTimeFormatter.ofPattern("yyyy/M/d"))) {
            try {
                return LocalDate.parse(trimmed, formatter);
            } catch (DateTimeParseException ignored) {
            }
        }
        throw new ApiException(400, "applicationDeadline must be a valid date");
    }
}

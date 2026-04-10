package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class ApplicationService {
    private final ApplicationRepository applicationRepository;
    private final JobRepository jobRepository;

    public ApplicationService(ApplicationRepository applicationRepository, JobRepository jobRepository) {
        this.applicationRepository = applicationRepository;
        this.jobRepository = jobRepository;
    }

    public SubmitResponse submitApplication(String applicationId, String applicantId, String jobId) {
        String normalizedApplicant = Validators.requireNonBlank(applicantId, "applicantId");
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        String normalizedApplicationId = applicationId == null || applicationId.isBlank()
                ? normalizedApplicant + "-" + normalizedJobId
                : applicationId.trim();

        if (!jobRepository.existsOpenJob(normalizedJobId)) {
            throw new ApiException(404, "Open job not found for jobId=" + normalizedJobId);
        }

        ApplicationRecord record = new ApplicationRecord(
                normalizedApplicationId,
                normalizedApplicant,
                normalizedJobId,
                "SUBMITTED",
                OffsetDateTime.now().toString()
        );
        ApplicationRepository.SubmitResult result = applicationRepository.saveIfAbsent(record);
        return new SubmitResponse(result.created(), result.record());
    }

    public List<ApplicationRecord> queryByApplicant(String applicantId, int page, int size) {
        String normalizedApplicant = Validators.requireNonBlank(applicantId, "applicantId");
        int normalizedPage = Validators.normalizePage(page);
        int normalizedSize = Validators.normalizeSize(size);
        return applicationRepository.findByApplicantId(normalizedApplicant, normalizedPage, normalizedSize);
    }

    public List<ApplicationRecord> listCandidatesByJob(String jobId, int page, int size) {
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        int normalizedPage = Validators.normalizePage(page);
        int normalizedSize = Validators.normalizeSize(size);
        return applicationRepository.findByJobId(normalizedJobId, normalizedPage, normalizedSize);
    }

    public List<ApplicationRecord> listCandidatesByJobAndStatus(String jobId, String status, int page, int size) {
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        String normalizedStatus = Validators.requireNonBlank(status, "status");
        int normalizedPage = Validators.normalizePage(page);
        int normalizedSize = Validators.normalizeSize(size);
        return applicationRepository.findByJobIdAndStatus(normalizedJobId, normalizedStatus, normalizedPage, normalizedSize);
    }

    public Map<String, Long> getJobStats() {
        return applicationRepository.countByJob();
    }

    public Map<String, Long> getJobStatusStats(String jobId) {
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        return applicationRepository.countByJobAndStatus(normalizedJobId);
    }

    public UpdateStatusResponse updateStatus(String applicationId, String newStatus) {
        String normalizedAppId = Validators.requireNonBlank(applicationId, "applicationId");
        String normalizedStatus = Validators.requireNonBlank(newStatus, "status");
        
        boolean updated = applicationRepository.updateStatus(normalizedAppId, normalizedStatus);
        if (!updated) {
            throw new ApiException(404, "Application not found or status unchanged for applicationId=" + normalizedAppId);
        }
        
        ApplicationRecord updated_record = applicationRepository
                .findByApplicationId(normalizedAppId)
                .orElseThrow(() -> new ApiException(500, "Failed to retrieve updated application"));
        
        return new UpdateStatusResponse(true, updated_record);
    }

    public Optional<ApplicationRecord> findByApplicationId(String applicationId) {
        String normalizedAppId = Validators.requireNonBlank(applicationId, "applicationId");
        return applicationRepository.findByApplicationId(normalizedAppId);
    }

    public Map<String, Long> statusSummary() {
        return applicationRepository.statusSummary();
    }

    public long totalApplications() {
        return applicationRepository.totalCount();
    }

    public void compactData() {
        applicationRepository.compact();
    }

    public record SubmitResponse(boolean created, ApplicationRecord record) {
    }

    public record UpdateStatusResponse(boolean updated, ApplicationRecord record) {
    }
}

package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;

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
}

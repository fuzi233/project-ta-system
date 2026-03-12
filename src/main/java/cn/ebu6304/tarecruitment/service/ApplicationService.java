package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.storage.TextFileRepository;

public class ApplicationService {
    private final TextFileRepository repository;

    public ApplicationService(TextFileRepository repository) {
        this.repository = repository;
    }

    public void submitApplication(String applicantId, String jobId) {
        repository.saveApplication(new ApplicationRecord(applicantId, jobId, "SUBMITTED"));
    }

    public int countApplications() {
        return repository.loadApplications().size();
    }
}

package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.repository.ApplicationRepository;

import java.util.HashMap;
import java.util.Map;

public class WorkloadService {
    private final ApplicationRepository applicationRepository;

    public WorkloadService(ApplicationRepository applicationRepository) {
        this.applicationRepository = applicationRepository;
    }

    public WorkloadSnapshot snapshot(long alertThreshold) {
        Map<String, Long> byApplicant = applicationRepository.workloadByApplicant();
        Map<String, Long> overloaded = new HashMap<>();
        long total = 0;
        for (Map.Entry<String, Long> entry : byApplicant.entrySet()) {
            total += entry.getValue();
            if (entry.getValue() > alertThreshold) {
                overloaded.put(entry.getKey(), entry.getValue());
            }
        }
        return new WorkloadSnapshot(total, byApplicant, overloaded);
    }

    public record WorkloadSnapshot(long totalApplications, Map<String, Long> byApplicant, Map<String, Long> overloaded) {
    }
}

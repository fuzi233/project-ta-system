package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Locale;

public class WorkloadService {
    private static final Set<String> NON_ACTIVE_STATUSES = Set.of("REJECTED", "WITHDRAWN", "CANCELLED", "CLOSED");
    private final ApplicationRepository applicationRepository;

    public WorkloadService(ApplicationRepository applicationRepository) {
        this.applicationRepository = applicationRepository;
    }

    public WorkloadSnapshot snapshot(long alertThreshold) {
        long normalizedThreshold = Math.max(0L, alertThreshold);
        List<ApplicationRecord> latestRecords = applicationRepository.listLatestApplications();
        Map<String, ApplicantAccumulator> accumulators = new HashMap<>();

        for (ApplicationRecord record : latestRecords) {
            ApplicantAccumulator accumulator = accumulators.computeIfAbsent(record.applicantId(), key -> new ApplicantAccumulator());
            accumulator.totalApplications++;
            String normalizedStatus = normalizeStatus(record.status());
            if (isActiveStatus(normalizedStatus)) {
                accumulator.activeApplications++;
            }
            accumulator.statusBreakdown.merge(normalizedStatus, 1L, Long::sum);
        }

        List<WorkloadEntry> entries = new ArrayList<>();
        for (Map.Entry<String, ApplicantAccumulator> entry : accumulators.entrySet()) {
            String applicantId = entry.getKey();
            ApplicantAccumulator accumulator = entry.getValue();
            boolean overloaded = accumulator.activeApplications > normalizedThreshold;
            long overloadBy = overloaded ? accumulator.activeApplications - normalizedThreshold : 0L;
            entries.add(new WorkloadEntry(
                    applicantId,
                    accumulator.totalApplications,
                    accumulator.activeApplications,
                    overloaded,
                    overloadBy,
                    Map.copyOf(accumulator.statusBreakdown)
            ));
        }

        entries.sort(Comparator
                .comparingLong(WorkloadEntry::activeApplications).reversed()
                .thenComparingLong(WorkloadEntry::totalApplications).reversed()
                .thenComparing(WorkloadEntry::applicantId));

        Map<String, Long> byApplicant = new LinkedHashMap<>();
        Map<String, Long> overloaded = new LinkedHashMap<>();
        for (WorkloadEntry entry : entries) {
            byApplicant.put(entry.applicantId(), entry.activeApplications());
            if (entry.overloaded()) {
                overloaded.put(entry.applicantId(), entry.activeApplications());
            }
        }

        return new WorkloadSnapshot(latestRecords.size(), byApplicant, overloaded, normalizedThreshold, List.copyOf(entries));
    }

    private boolean isActiveStatus(String status) {
        return !NON_ACTIVE_STATUSES.contains(status);
    }

    private String normalizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return "UNKNOWN";
        }
        return status.trim().toUpperCase(Locale.ROOT);
    }

    public record WorkloadSnapshot(
            long totalApplications,
            Map<String, Long> byApplicant,
            Map<String, Long> overloaded,
            long threshold,
            List<WorkloadEntry> entries
    ) {
    }

    public record WorkloadEntry(
            String applicantId,
            long totalApplications,
            long activeApplications,
            boolean overloaded,
            long overloadBy,
            Map<String, Long> statusBreakdown
    ) {
    }

    private static class ApplicantAccumulator {
        private long totalApplications;
        private long activeApplications;
        private final Map<String, Long> statusBreakdown = new HashMap<>();
    }
}

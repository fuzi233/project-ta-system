package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.function.Predicate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

public class ApplicationRepository {
    private final JsonlFileStore<ApplicationRecord> fileStore;
    private final Map<String, Long> idIndex = new ConcurrentHashMap<>();
    private final AtomicLong physicalLineCounter = new AtomicLong(0);

    public ApplicationRepository(JsonlFileStore<ApplicationRecord> fileStore) {
        this.fileStore = fileStore;
        rebuildIndexes();
    }

    public synchronized SubmitResult saveIfAbsent(ApplicationRecord record) {
        String applicationId = record.applicationId();
        if (idIndex.containsKey(applicationId)) {
            Optional<ApplicationRecord> existing = findCurrentByApplicationId(applicationId);
            if (existing.isPresent()) {
                return new SubmitResult(false, existing.get());
            }
            throw new IllegalStateException("Application index is stale for applicationId=" + applicationId);
        }

        fileStore.append(record);
        long nextLine = physicalLineCounter.incrementAndGet();
        idIndex.put(applicationId, nextLine);
        return new SubmitResult(true, record);
    }

    public Optional<ApplicationRecord> findByApplicationId(String applicationId) {
        return findCurrentByApplicationId(applicationId);
    }

    public List<ApplicationRecord> findByApplicantId(String applicantId, int page, int size) {
        return filterAndPaginateCurrentRecords(page, size, item -> item.applicantId().equals(applicantId));
    }

    public List<ApplicationRecord> findByJobId(String jobId, int page, int size) {
        return filterAndPaginateCurrentRecords(page, size, item -> item.jobId().equals(jobId));
    }

    public List<ApplicationRecord> findByJobIdAndStatus(String jobId, String status, int page, int size) {
        return filterAndPaginateCurrentRecords(page, size, item ->
            item.jobId().equals(jobId) && item.status().equalsIgnoreCase(status)
        );
    }

    public synchronized Map<String, Long> workloadByApplicant() {
        Map<String, Long> result = new HashMap<>();
        for (ApplicationRecord record : currentRecordsSortedByLine()) {
            result.merge(record.applicantId(), 1L, Long::sum);
        }
        return result;
    }

    public synchronized Map<String, Long> countByJob() {
        Map<String, Long> result = new HashMap<>();
        for (ApplicationRecord record : currentRecordsSortedByLine()) {
            result.merge(record.jobId(), 1L, Long::sum);
        }
        return result;
    }

    public synchronized Map<String, Long> countByJobAndStatus(String jobId) {
        Map<String, Long> result = new HashMap<>();
        for (ApplicationRecord record : currentRecordsSortedByLine()) {
            if (record.jobId().equals(jobId)) {
                result.merge(record.status(), 1L, Long::sum);
            }
        }
        return result;
    }

    public synchronized Map<String, Long> statusSummary() {
        Map<String, Long> summary = new HashMap<>();
        for (ApplicationRecord record : currentRecordsSortedByLine()) {
            summary.merge(record.status(), 1L, Long::sum);
        }
        return summary;
    }

    public synchronized long totalCount() {
        return idIndex.size();
    }

    public synchronized boolean updateStatus(String applicationId, String newStatus) {
        Optional<ApplicationRecord> existing = findCurrentByApplicationId(applicationId);
        if (existing.isEmpty()) {
            return false;
        }

        ApplicationRecord oldRecord = existing.get();
        if (oldRecord.status().equalsIgnoreCase(newStatus)) {
            return false;
        }

        ApplicationRecord updatedRecord = new ApplicationRecord(
                oldRecord.applicationId(),
                oldRecord.applicantId(),
                oldRecord.jobId(),
                newStatus,
                oldRecord.submittedAt()
        );

        fileStore.append(updatedRecord);
        long nextLine = physicalLineCounter.incrementAndGet();
        idIndex.put(applicationId, nextLine);

        return true;
    }

    public synchronized void compact() {
        Map<String, ApplicationRecord> lastById = new LinkedHashMap<>();
        fileStore.forEach(record -> lastById.put(record.applicationId(), record));
        List<ApplicationRecord> compacted = new ArrayList<>(lastById.values());
        compacted.sort(Comparator.comparing(ApplicationRecord::applicationId));
        fileStore.replaceAll(compacted);
        rebuildIndexes();
    }

    private synchronized void rebuildIndexes() {
        idIndex.clear();
        physicalLineCounter.set(0);

        fileStore.forEach(record -> {
            long line = physicalLineCounter.incrementAndGet();
            idIndex.put(record.applicationId(), line);
        });
    }

    private Optional<ApplicationRecord> findCurrentByApplicationId(String applicationId) {
        Long line = idIndex.get(applicationId);
        if (line == null) {
            return Optional.empty();
        }
        Optional<ApplicationRecord> record = fileStore.readAtLine(line);
        if (record.isPresent() && applicationId.equals(record.get().applicationId())) {
            return record;
        }
        rebuildIndexes();
        Long rebuiltLine = idIndex.get(applicationId);
        if (rebuiltLine == null) {
            return Optional.empty();
        }
        Optional<ApplicationRecord> rebuiltRecord = fileStore.readAtLine(rebuiltLine);
        if (rebuiltRecord.isPresent() && applicationId.equals(rebuiltRecord.get().applicationId())) {
            return rebuiltRecord;
        }
        return Optional.empty();
    }

    private List<ApplicationRecord> filterAndPaginateCurrentRecords(int page, int size, Predicate<ApplicationRecord> filter) {
        int start = (page - 1) * size;
        int end = start + size;
        int matched = 0;
        List<ApplicationRecord> result = new ArrayList<>(size);
        for (ApplicationRecord record : currentRecordsSortedByLine()) {
            if (!filter.test(record)) {
                continue;
            }
            if (matched >= start && matched < end) {
                result.add(record);
            }
            matched++;
            if (matched >= end) {
                break;
            }
        }
        return result;
    }

    private List<ApplicationRecord> currentRecordsSortedByLine() {
        return currentRecordsSortedByLine(true);
    }

    private List<ApplicationRecord> currentRecordsSortedByLine(boolean allowRepair) {
        List<Map.Entry<String, Long>> entries = new ArrayList<>(idIndex.entrySet());
        entries.sort(Map.Entry.comparingByValue());
        List<ApplicationRecord> records = new ArrayList<>(entries.size());
        boolean hasStaleIndex = false;
        for (Map.Entry<String, Long> entry : entries) {
            Optional<ApplicationRecord> record = fileStore.readAtLine(entry.getValue());
            if (record.isPresent() && entry.getKey().equals(record.get().applicationId())) {
                records.add(record.get());
            } else {
                hasStaleIndex = true;
            }
        }
        if (hasStaleIndex && allowRepair) {
            rebuildIndexes();
            return currentRecordsSortedByLine(false);
        }
        return records;
    }

    public record SubmitResult(boolean created, ApplicationRecord record) {
    }
}

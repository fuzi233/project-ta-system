package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.LongAdder;

public class ApplicationRepository {
    private final JsonlFileStore<ApplicationRecord> fileStore;
    private final Map<String, Long> idIndex = new ConcurrentHashMap<>();
    private final Map<String, LongAdder> statusIndex = new ConcurrentHashMap<>();
    private final AtomicLong lineCounter = new AtomicLong(0);

    public ApplicationRepository(JsonlFileStore<ApplicationRecord> fileStore) {
        this.fileStore = fileStore;
        rebuildIndexes();
    }

    public synchronized SubmitResult saveIfAbsent(ApplicationRecord record) {
        Long existingLine = idIndex.get(record.applicationId());
        if (existingLine != null) {
            ApplicationRecord existing = fileStore.readAtLine(existingLine).orElse(record);
            return new SubmitResult(false, existing);
        }

        fileStore.append(record);
        long nextLine = lineCounter.incrementAndGet();
        idIndex.put(record.applicationId(), nextLine);
        statusIndex.computeIfAbsent(record.status(), key -> new LongAdder()).increment();
        return new SubmitResult(true, record);
    }

    public Optional<ApplicationRecord> findByApplicationId(String applicationId) {
        Long line = idIndex.get(applicationId);
        if (line == null) {
            return Optional.empty();
        }
        return fileStore.readAtLine(line);
    }

    public List<ApplicationRecord> findByApplicantId(String applicantId, int page, int size) {
        List<ApplicationRecord> filtered = listLatestApplications().stream()
                .filter(item -> item.applicantId().equals(applicantId))
                .toList();
        return paginate(filtered, page, size);
    }

    public List<ApplicationRecord> findByJobId(String jobId, int page, int size) {
        List<ApplicationRecord> filtered = listLatestApplications().stream()
                .filter(item -> item.jobId().equals(jobId))
                .toList();
        return paginate(filtered, page, size);
    }

    public List<ApplicationRecord> findByJobIdAndStatus(String jobId, String status, int page, int size) {
        List<ApplicationRecord> filtered = listLatestApplications().stream()
                .filter(item -> item.jobId().equals(jobId) && item.status().equalsIgnoreCase(status))
                .toList();
        return paginate(filtered, page, size);
    }

    public synchronized Map<String, Long> workloadByApplicant() {
        Map<String, Long> result = new HashMap<>();
        for (ApplicationRecord record : listLatestApplications()) {
            result.merge(record.applicantId(), 1L, Long::sum);
        }
        return result;
    }

    public synchronized List<ApplicationRecord> listLatestApplications() {
        List<Map.Entry<String, Long>> indexedLines = new ArrayList<>(idIndex.entrySet());
        indexedLines.sort(Map.Entry.comparingByValue());
        List<ApplicationRecord> records = new ArrayList<>(indexedLines.size());
        for (Map.Entry<String, Long> entry : indexedLines) {
            fileStore.readAtLine(entry.getValue()).ifPresent(records::add);
        }
        return records;
    }

    public synchronized Map<String, Long> countByJob() {
        Map<String, Long> result = new HashMap<>();
        for (ApplicationRecord record : listLatestApplications()) {
            result.merge(record.jobId(), 1L, Long::sum);
        }
        return result;
    }

    public synchronized Map<String, Long> countByJobAndStatus(String jobId) {
        Map<String, Long> result = new HashMap<>();
        for (ApplicationRecord record : listLatestApplications()) {
            if (record.jobId().equals(jobId)) {
                result.merge(record.status(), 1L, Long::sum);
            }
        }
        return result;
    }

    public synchronized Map<String, Long> statusSummary() {
        Map<String, Long> summary = new HashMap<>();
        for (Map.Entry<String, LongAdder> entry : statusIndex.entrySet()) {
            summary.put(entry.getKey(), entry.getValue().longValue());
        }
        return summary;
    }

    public synchronized long totalCount() {
        return idIndex.size();
    }

    public synchronized boolean updateStatus(String applicationId, String newStatus) {
        Long line = idIndex.get(applicationId);
        if (line == null) {
            return false;
        }

        Optional<ApplicationRecord> existing = fileStore.readAtLine(line);
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
        long nextLine = lineCounter.incrementAndGet();
        idIndex.put(applicationId, nextLine);

        LongAdder oldStatusCounter = statusIndex.get(oldRecord.status());
        if (oldStatusCounter != null) {
            oldStatusCounter.decrement();
            if (oldStatusCounter.longValue() <= 0) {
                statusIndex.remove(oldRecord.status(), oldStatusCounter);
            }
        }
        statusIndex.computeIfAbsent(newStatus, k -> new LongAdder()).increment();

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
        statusIndex.clear();
        lineCounter.set(0);

        Map<String, Long> latestLineById = new HashMap<>();
        Map<String, ApplicationRecord> latestRecordById = new HashMap<>();
        fileStore.forEach(record -> {
            long line = lineCounter.incrementAndGet();
            latestLineById.put(record.applicationId(), line);
            latestRecordById.put(record.applicationId(), record);
        });
        idIndex.putAll(latestLineById);
        latestRecordById.values()
                .forEach(record -> statusIndex.computeIfAbsent(record.status(), key -> new LongAdder()).increment());
    }

    private static List<ApplicationRecord> paginate(List<ApplicationRecord> source, int page, int size) {
        if (page < 1 || size < 1 || source.isEmpty()) {
            return List.of();
        }
        int start = (page - 1) * size;
        if (start >= source.size()) {
            return List.of();
        }
        int end = Math.min(start + size, source.size());
        return source.subList(start, end);
    }

    public record SubmitResult(boolean created, ApplicationRecord record) {
    }
}

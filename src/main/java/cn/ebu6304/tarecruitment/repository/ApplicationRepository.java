package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
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
        return fileStore.readPage(page, size, item -> item.applicantId().equals(applicantId));
    }

    public List<ApplicationRecord> findByJobId(String jobId, int page, int size) {
        return fileStore.readPage(page, size, item -> item.jobId().equals(jobId));
    }

    public List<ApplicationRecord> findByJobIdAndStatus(String jobId, String status, int page, int size) {
        return fileStore.readPage(page, size, item -> 
            item.jobId().equals(jobId) && item.status().equalsIgnoreCase(status)
        );
    }

    public synchronized Map<String, Long> workloadByApplicant() {
        Map<String, Long> result = new HashMap<>();
        fileStore.forEach(record -> result.merge(record.applicantId(), 1L, Long::sum));
        return result;
    }

    public synchronized Map<String, Long> countByJob() {
        Map<String, Long> result = new HashMap<>();
        fileStore.forEach(record -> result.merge(record.jobId(), 1L, Long::sum));
        return result;
    }

    public synchronized Map<String, Long> countByJobAndStatus(String jobId) {
        Map<String, Long> result = new HashMap<>();
        fileStore.forEach(record -> {
            if (record.jobId().equals(jobId)) {
                result.merge(record.status(), 1L, Long::sum);
            }
        });
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
        return lineCounter.get();
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
            return true;
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
        
        // Update status index
        statusIndex.computeIfAbsent(oldRecord.status(), k -> new LongAdder()).decrement();
        statusIndex.computeIfAbsent(newStatus, k -> new LongAdder()).increment();
        
        return true;
    }

    public synchronized void compact() {
        List<ApplicationRecord> all = new ArrayList<>();
        fileStore.forEach(all::add);
        all.sort(Comparator.comparing(ApplicationRecord::applicationId));
        fileStore.replaceAll(all);
        rebuildIndexes();
    }

    private synchronized void rebuildIndexes() {
        idIndex.clear();
        statusIndex.clear();
        lineCounter.set(0);

        fileStore.forEach(record -> {
            long line = lineCounter.incrementAndGet();
            idIndex.put(record.applicationId(), line);
            statusIndex.computeIfAbsent(record.status(), key -> new LongAdder()).increment();
        });
    }

    public record SubmitResult(boolean created, ApplicationRecord record) {
    }
}

package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

public class JobRepository {
    private final JsonlFileStore<JobPosting> fileStore;
    private final Map<String, Long> idIndex = new ConcurrentHashMap<>();
    private final AtomicLong lineCounter = new AtomicLong(0);

    public JobRepository(JsonlFileStore<JobPosting> fileStore) {
        this.fileStore = fileStore;
        rebuildIndexes();
    }

    public synchronized boolean createIfAbsent(JobPosting jobPosting) {
        if (idIndex.containsKey(jobPosting.jobId())) {
            return false;
        }
        fileStore.append(jobPosting);
        long nextLine = lineCounter.incrementAndGet();
        idIndex.put(jobPosting.jobId(), nextLine);
        return true;
    }

    public synchronized boolean existsOpenJob(String jobId) {
        Long line = idIndex.get(jobId);
        if (line == null) {
            return false;
        }
        return fileStore.readAtLine(line)
                .map(job -> "OPEN".equalsIgnoreCase(job.status()))
                .orElse(false);
    }

    public synchronized Optional<JobPosting> findById(String jobId) {
        Long line = idIndex.get(jobId);
        if (line == null) {
            return Optional.empty();
        }
        return fileStore.readAtLine(line);
    }

    public synchronized List<JobPosting> list(String query, String status, int page, int size) {
        String normalizedQuery = query == null ? "" : query.trim().toLowerCase(Locale.ROOT);
        String normalizedStatus = status == null ? "" : status.trim().toUpperCase(Locale.ROOT);
        return fileStore.readPage(page, size, job -> {
            boolean queryMatch = normalizedQuery.isEmpty()
                    || job.title().toLowerCase(Locale.ROOT).contains(normalizedQuery)
                    || job.moduleCode().toLowerCase(Locale.ROOT).contains(normalizedQuery)
                    || job.requiredSkills().toLowerCase(Locale.ROOT).contains(normalizedQuery);
            boolean statusMatch = normalizedStatus.isEmpty() || normalizedStatus.equals(job.status().toUpperCase(Locale.ROOT));
            return queryMatch && statusMatch;
        });
    }

    public synchronized List<JobPosting> listAll() {
        List<JobPosting> all = new ArrayList<>();
        fileStore.forEach(all::add);
        return all;
    }

    public synchronized Optional<JobPosting> findByJobId(String jobId) {
        Long line = idIndex.get(jobId);
        if (line == null) {
            return Optional.empty();
        }
        return fileStore.readAtLine(line);
    }

    public synchronized List<JobPosting> listByCreator(String creatorId, int page, int size) {
        return fileStore.readPage(page, size, job -> job.createdBy().equals(creatorId));
    }

    public synchronized void compact() {
        Map<String, JobPosting> lastById = new LinkedHashMap<>();
        fileStore.forEach(job -> lastById.put(job.jobId(), job));
        List<JobPosting> compacted = new ArrayList<>(lastById.values());
        compacted.sort(Comparator.comparing(JobPosting::jobId));
        fileStore.replaceAll(compacted);
        rebuildIndexes();
    }

    private synchronized void rebuildIndexes() {
        idIndex.clear();
        lineCounter.set(0);
        fileStore.forEach(job -> {
            long line = lineCounter.incrementAndGet();
            idIndex.put(job.jobId(), line);
        });
    }
}

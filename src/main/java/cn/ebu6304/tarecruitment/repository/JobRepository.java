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
import java.util.function.Predicate;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

public class JobRepository {
    private final JsonlFileStore<JobPosting> fileStore;
    private final Map<String, Long> idIndex = new ConcurrentHashMap<>();
    private final AtomicLong physicalLineCounter = new AtomicLong(0);

    public JobRepository(JsonlFileStore<JobPosting> fileStore) {
        this.fileStore = fileStore;
        rebuildIndexes();
    }

    public synchronized boolean createIfAbsent(JobPosting jobPosting) {
        String jobId = jobPosting.jobId();
        if (idIndex.containsKey(jobId)) {
            Optional<JobPosting> existing = findCurrentByJobId(jobId);
            if (existing.isPresent()) {
                return false;
            }
            throw new IllegalStateException("Job index is stale for jobId=" + jobId);
        }
        fileStore.append(jobPosting);
        long nextLine = physicalLineCounter.incrementAndGet();
        idIndex.put(jobId, nextLine);
        return true;
    }

    public synchronized boolean existsOpenJob(String jobId) {
        return findCurrentByJobId(jobId)
                .map(job -> "OPEN".equalsIgnoreCase(job.status()))
                .orElse(false);
    }

    public synchronized Optional<JobPosting> findById(String jobId) {
        return findCurrentByJobId(jobId);
    }

    public synchronized List<JobPosting> list(String query, String status, int page, int size) {
        String normalizedQuery = query == null ? "" : query.trim().toLowerCase(Locale.ROOT);
        String normalizedStatus = status == null ? "" : status.trim().toUpperCase(Locale.ROOT);
        return filterAndPaginateCurrentJobs(page, size, job -> {
            boolean queryMatch = normalizedQuery.isEmpty()
                    || job.title().toLowerCase(Locale.ROOT).contains(normalizedQuery)
                    || job.moduleCode().toLowerCase(Locale.ROOT).contains(normalizedQuery)
                    || job.requiredSkills().toLowerCase(Locale.ROOT).contains(normalizedQuery);
            boolean statusMatch = normalizedStatus.isEmpty() || normalizedStatus.equals(job.status().toUpperCase(Locale.ROOT));
            return queryMatch && statusMatch;
        });
    }

    public synchronized long count(String query, String status) {
        String normalizedQuery = query == null ? "" : query.trim().toLowerCase(Locale.ROOT);
        String normalizedStatus = status == null ? "" : status.trim().toUpperCase(Locale.ROOT);
        return currentJobsSortedByLine().stream()
                .filter(job -> {
                    boolean queryMatch = normalizedQuery.isEmpty()
                            || job.title().toLowerCase(Locale.ROOT).contains(normalizedQuery)
                            || job.moduleCode().toLowerCase(Locale.ROOT).contains(normalizedQuery)
                            || job.requiredSkills().toLowerCase(Locale.ROOT).contains(normalizedQuery);
                    boolean statusMatch = normalizedStatus.isEmpty() || normalizedStatus.equals(job.status().toUpperCase(Locale.ROOT));
                    return queryMatch && statusMatch;
                })
                .count();
    }

    public synchronized List<JobPosting> listAll() {
        return currentJobsSortedByLine();
    }

    public synchronized Optional<JobPosting> findByJobId(String jobId) {
        return findCurrentByJobId(jobId);
    }

    public synchronized List<JobPosting> listByCreator(String creatorId, int page, int size) {
        return filterAndPaginateCurrentJobs(page, size, job -> job.createdBy().equals(creatorId));
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
        physicalLineCounter.set(0);
        fileStore.forEach(job -> {
            long line = physicalLineCounter.incrementAndGet();
            idIndex.put(job.jobId(), line);
        });
    }

    private Optional<JobPosting> findCurrentByJobId(String jobId) {
        Long line = idIndex.get(jobId);
        if (line == null) {
            return Optional.empty();
        }
        Optional<JobPosting> job = fileStore.readAtLine(line);
        if (job.isPresent() && jobId.equals(job.get().jobId())) {
            return job;
        }
        rebuildIndexes();
        Long rebuiltLine = idIndex.get(jobId);
        if (rebuiltLine == null) {
            return Optional.empty();
        }
        Optional<JobPosting> rebuiltJob = fileStore.readAtLine(rebuiltLine);
        if (rebuiltJob.isPresent() && jobId.equals(rebuiltJob.get().jobId())) {
            return rebuiltJob;
        }
        return Optional.empty();
    }

    private List<JobPosting> filterAndPaginateCurrentJobs(int page, int size, Predicate<JobPosting> filter) {
        int start = (page - 1) * size;
        int end = start + size;
        int matched = 0;
        List<JobPosting> result = new ArrayList<>(size);
        for (JobPosting job : currentJobsSortedByLine()) {
            if (!filter.test(job)) {
                continue;
            }
            if (matched >= start && matched < end) {
                result.add(job);
            }
            matched++;
            if (matched >= end) {
                break;
            }
        }
        return result;
    }

    private List<JobPosting> currentJobsSortedByLine() {
        return currentJobsSortedByLine(true);
    }

    private List<JobPosting> currentJobsSortedByLine(boolean allowRepair) {
        List<Map.Entry<String, Long>> entries = new ArrayList<>(idIndex.entrySet());
        entries.sort(Map.Entry.comparingByValue());
        List<JobPosting> jobs = new ArrayList<>(entries.size());
        boolean hasStaleIndex = false;
        for (Map.Entry<String, Long> entry : entries) {
            Optional<JobPosting> job = fileStore.readAtLine(entry.getValue());
            if (job.isPresent() && entry.getKey().equals(job.get().jobId())) {
                jobs.add(job.get());
            } else {
                hasStaleIndex = true;
            }
        }
        if (hasStaleIndex && allowRepair) {
            rebuildIndexes();
            return currentJobsSortedByLine(false);
        }
        return jobs;
    }
}

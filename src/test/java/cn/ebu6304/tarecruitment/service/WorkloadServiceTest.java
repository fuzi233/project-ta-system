package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class WorkloadServiceTest {

    @Test
    void snapshotShouldCountLatestApplicationStateOnce() throws Exception {
        Path tempDir = Files.createTempDirectory("ta-system-workload");
        ObjectMapper mapper = new ObjectMapper();

        JobRepository jobRepository = new JobRepository(new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
        ApplicationRepository applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));

        JobService jobService = new JobService(jobRepository);
        ApplicationService applicationService = new ApplicationService(applicationRepository, jobRepository);
        WorkloadService workloadService = new WorkloadService(applicationRepository);

        jobService.createJob("job-1", "Algorithms TA", "CS101", "Java", 2, "mo1");
        applicationService.submitApplication("app-1", "taA", "job-1");
        applicationService.submitApplication("app-2", "taA", "job-1");
        applicationService.submitApplication("app-3", "taB", "job-1");

        // app-1 status update appends a new JSONL line; workload should still count this application once.
        applicationService.updateStatus("app-1", "REJECTED");

        WorkloadService.WorkloadSnapshot snapshot = workloadService.snapshot(1);
        WorkloadService.WorkloadEntry taA = snapshot.entries().stream()
                .filter(entry -> entry.applicantId().equals("taA"))
                .findFirst()
                .orElseThrow();

        assertEquals(2L, snapshot.totalApplications());
        assertEquals(0L, snapshot.byApplicant().get("taA"));
        assertEquals(1L, snapshot.byApplicant().get("taB"));
        assertFalse(snapshot.overloaded().containsKey("taA"));
        assertEquals(1L, taA.totalApplications());
        assertEquals(0L, taA.activeApplications());
        assertEquals(1L, taA.statusBreakdown().get("REJECTED"));
    }

    @Test
    void snapshotShouldMarkOverloadedWhenThresholdIsZero() throws Exception {
        Path tempDir = Files.createTempDirectory("ta-system-workload-overload");
        ObjectMapper mapper = new ObjectMapper();

        JobRepository jobRepository = new JobRepository(new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
        ApplicationRepository applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));

        JobService jobService = new JobService(jobRepository);
        ApplicationService applicationService = new ApplicationService(applicationRepository, jobRepository);
        WorkloadService workloadService = new WorkloadService(applicationRepository);

        jobService.createJob("job-1", "Algorithms TA", "CS101", "Java", 2, "mo1");
        applicationService.submitApplication("app-1", "taA", "job-1");

        WorkloadService.WorkloadSnapshot snapshot = workloadService.snapshot(0);
        assertTrue(snapshot.overloaded().containsKey("taA"));
        assertEquals(1L, snapshot.overloaded().get("taA"));
    }
}

package cn.ebu6304.tarecruitment.integration;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import cn.ebu6304.tarecruitment.service.JobService;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;

class PerformanceBaselineTest {

    @Test
    @Disabled("Manual baseline run for acceptance rehearsal")
    void shouldMeasureP95QueryWith10000Records() throws Exception {
        Path tempDir = Files.createTempDirectory("perf");
        ObjectMapper mapper = new ObjectMapper();

        JobRepository jobRepository = new JobRepository(new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
        ApplicationRepository applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));

        JobService jobService = new JobService(jobRepository);
        ApplicationService applicationService = new ApplicationService(applicationRepository, jobRepository);

        jobService.createJob("job-perf", "Perf TA", "CS999", "Java", 5, "mo-perf");

        for (int i = 0; i < 10_000; i++) {
            String applicantId = "ta" + (i % 500);
            applicationService.submitApplication("perf-" + i, applicantId, "job-perf");
        }

        List<Long> samples = new ArrayList<>();
        for (int i = 0; i < 120; i++) {
            long start = System.nanoTime();
            applicationService.queryByApplicant("ta100", 1, 20);
            long durationMs = (System.nanoTime() - start) / 1_000_000;
            samples.add(durationMs);
        }

        Collections.sort(samples);
        long p95 = samples.get((int) Math.floor(samples.size() * 0.95) - 1);
        assertTrue(p95 < 150, "Expected p95 < 150ms but got " + p95 + "ms");
    }
}

package cn.ebu6304.tarecruitment.integration;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import cn.ebu6304.tarecruitment.service.JobService;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

class StatusLifecycleIntegrationTest {

    @Test
    void statusUpdateShouldBeVisibleAcrossQueriesAndStats() throws Exception {
        Path tempDir = Files.createTempDirectory("status-lifecycle");
        ObjectMapper mapper = new ObjectMapper();

        JobRepository jobRepository = new JobRepository(
                new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper)
        );
        ApplicationRepository applicationRepository = new ApplicationRepository(
                new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper)
        );
        JobService jobService = new JobService(jobRepository);
        ApplicationService applicationService = new ApplicationService(applicationRepository, jobRepository);

        jobService.createJob("job-1", "Java TA", "EBU6304", "Java", 2, 10, "2026-01-01", 800, "mo-1");
        applicationService.submitApplication("app-1", "ta-1", "job-1");
        applicationService.updateStatus("app-1", "INTERVIEWED");
        applicationService.updateStatus("app-1", "ACCEPTED");

        assertEquals(1, applicationService.queryByApplicant("ta-1", 1, 10).size());
        assertEquals("ACCEPTED", applicationService.queryByApplicant("ta-1", 1, 10).get(0).status());
        assertEquals(0, applicationService.listCandidatesByJobAndStatus("job-1", "SUBMITTED", 1, 10).size());
        assertEquals(1, applicationService.listCandidatesByJobAndStatus("job-1", "ACCEPTED", 1, 10).size());
        assertEquals(Map.of("ACCEPTED", 1L), applicationService.getJobStatusStats("job-1"));
    }
}

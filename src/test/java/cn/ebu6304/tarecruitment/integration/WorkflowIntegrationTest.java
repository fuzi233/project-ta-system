package cn.ebu6304.tarecruitment.integration;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import cn.ebu6304.tarecruitment.service.JobService;
import cn.ebu6304.tarecruitment.service.WorkloadService;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class WorkflowIntegrationTest {

    @Test
    void fullWorkflowShouldPass() throws Exception {
        Path tempDir = Files.createTempDirectory("workflow");
        ObjectMapper mapper = new ObjectMapper();

        JobRepository jobRepository = new JobRepository(new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
        ApplicationRepository applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));

        JobService jobService = new JobService(jobRepository);
        ApplicationService applicationService = new ApplicationService(applicationRepository, jobRepository);
        WorkloadService workloadService = new WorkloadService(applicationRepository);

        jobService.createJob("job1", "Networks TA", "CS202", "Network,Java", 3, "moA");
        applicationService.submitApplication("app1", "taA", "job1");
        applicationService.submitApplication("app2", "taA", "job1");
        applicationService.submitApplication("app3", "taB", "job1");

        assertEquals(2, applicationService.queryByApplicant("taA", 1, 10).size());
        assertEquals(3, workloadService.snapshot(1).totalApplications());
        assertTrue(workloadService.snapshot(1).overloaded().containsKey("taA"));
    }
}

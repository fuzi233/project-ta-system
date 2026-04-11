package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.common.ApiException;
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
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ApplicationServiceTest {

    @Test
    void submitShouldBeIdempotent() throws Exception {
        Path tempDir = Files.createTempDirectory("ta-system");
        ObjectMapper mapper = new ObjectMapper();

        JsonlFileStore<JobPosting> jobStore = new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper);
        JsonlFileStore<ApplicationRecord> appStore = new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper);

        JobRepository jobRepository = new JobRepository(jobStore);
        ApplicationRepository applicationRepository = new ApplicationRepository(appStore);

        jobRepository.createIfAbsent(new JobPosting("job-1", "Algorithms TA", "CS101", "Java", 2, "OPEN", "mo1", "2026-03-12T00:00:00Z"));

        ApplicationService service = new ApplicationService(applicationRepository, jobRepository);

        ApplicationService.SubmitResponse first = service.submitApplication("app-1", "ta001", "job-1");
        ApplicationService.SubmitResponse second = service.submitApplication("app-1", "ta001", "job-1");

        assertTrue(first.created());
        assertTrue(!second.created());
        assertEquals(1, service.totalApplications());
    }

    @Test
    void submitShouldFailWhenJobNotOpen() throws Exception {
        Path tempDir = Files.createTempDirectory("ta-system-no-job");
        ObjectMapper mapper = new ObjectMapper();

        JobRepository jobRepository = new JobRepository(new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
        ApplicationRepository applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));
        ApplicationService service = new ApplicationService(applicationRepository, jobRepository);

        assertThrows(ApiException.class, () -> service.submitApplication("app-x", "ta001", "job-x"));
    }

    @Test
    void compactShouldDeduplicateByApplicationIdKeepingLast() throws Exception {
        Path tempDir = Files.createTempDirectory("ta-system-compact");
        ObjectMapper mapper = new ObjectMapper();

        JsonlFileStore<ApplicationRecord> appStore = new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper);
        appStore.append(new ApplicationRecord("app-1", "ta001", "job-1", "SUBMITTED", "2026-03-12T00:00:00Z"));
        appStore.append(new ApplicationRecord("app-1", "ta001", "job-1", "ACCEPTED", "2026-03-13T00:00:00Z"));

        ApplicationRepository applicationRepository = new ApplicationRepository(appStore);
        applicationRepository.compact();

        assertEquals(1, applicationRepository.totalCount());
        assertEquals("ACCEPTED", applicationRepository.findByApplicationId("app-1").orElseThrow().status());
    }

    @Test
    void statusUpdateShouldKeepSingleCurrentRecordInQueriesAndCounts() throws Exception {
        Path tempDir = Files.createTempDirectory("ta-system-status-update");
        ObjectMapper mapper = new ObjectMapper();

        JsonlFileStore<JobPosting> jobStore = new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper);
        JsonlFileStore<ApplicationRecord> appStore = new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper);
        JobRepository jobRepository = new JobRepository(jobStore);
        ApplicationRepository applicationRepository = new ApplicationRepository(appStore);
        ApplicationService service = new ApplicationService(applicationRepository, jobRepository);

        jobRepository.createIfAbsent(new JobPosting("job-1", "Algorithms TA", "CS101", "Java", 2, "OPEN", "mo1", "2026-03-12T00:00:00Z"));
        service.submitApplication("app-1", "ta001", "job-1");

        service.updateStatus("app-1", "REVIEWING");

        assertEquals(1, service.totalApplications());
        assertEquals(0, service.listCandidatesByJobAndStatus("job-1", "SUBMITTED", 1, 10).size());
        assertEquals(1, service.listCandidatesByJobAndStatus("job-1", "REVIEWING", 1, 10).size());
        assertEquals(1L, service.statusSummary().getOrDefault("REVIEWING", 0L));
    }
}

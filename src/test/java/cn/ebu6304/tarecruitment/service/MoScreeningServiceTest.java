package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MoScreeningServiceTest {
    private ApplicationService applicationService;
    private ApplicationRepository applicationRepository;

    @BeforeEach
    void setUp() throws Exception {
        Path tmpDir = Files.createTempDirectory("mo-screening-test");
        ObjectMapper mapper = new ObjectMapper();

        JobRepository jobRepository = new JobRepository(new JsonlFileStore<>(tmpDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
        applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tmpDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));
        applicationService = new ApplicationService(applicationRepository, jobRepository);

        jobRepository.createIfAbsent(new JobPosting("JOB001", "SE TA", "EBU6304", "Java,Testing", 2, "OPEN", "mo-001", "2026-04-10T00:00:00Z"));
        jobRepository.createIfAbsent(new JobPosting("JOB002", "ML TA", "EBU6201", "Python,ML", 2, "OPEN", "mo-002", "2026-04-10T00:00:00Z"));

        applicationRepository.saveIfAbsent(new ApplicationRecord("APP001", "user1", "JOB001", "SUBMITTED", "2026-04-07T00:00:00Z"));
        applicationRepository.saveIfAbsent(new ApplicationRecord("APP002", "user2", "JOB001", "REVIEWING", "2026-04-07T00:00:00Z"));
        applicationRepository.saveIfAbsent(new ApplicationRecord("APP003", "user3", "JOB002", "SUBMITTED", "2026-04-07T00:00:00Z"));
    }

    @Test
    void testListCandidatesByJob() {
        List<ApplicationRecord> result = applicationService.listCandidatesByJob("JOB001", 1, 20);
        assertEquals(2, result.size());
    }

    @Test
    void testListCandidatesByJobAndStatus() {
        List<ApplicationRecord> result = applicationService.listCandidatesByJobAndStatus("JOB001", "REVIEWING", 1, 20);
        assertEquals(1, result.size());
        assertEquals("APP002", result.get(0).applicationId());
    }

    @Test
    void testGetJobStats() {
        Map<String, Long> result = applicationService.getJobStats();
        assertEquals(2L, result.get("JOB001"));
        assertEquals(1L, result.get("JOB002"));
    }

    @Test
    void testGetJobStatusStats() {
        Map<String, Long> result = applicationService.getJobStatusStats("JOB001");
        assertEquals(1L, result.get("SUBMITTED"));
        assertEquals(1L, result.get("REVIEWING"));
    }

    @Test
    void testUpdateStatus() {
        ApplicationService.UpdateStatusResponse response = applicationService.updateStatus("APP001", "ACCEPTED");
        assertTrue(response.updated());
        assertEquals("ACCEPTED", response.record().status());
    }

    @Test
    void testUpdateStatusNotFound() {
        assertThrows(Exception.class, () -> applicationService.updateStatus("NONEXISTENT", "ACCEPTED"));
    }
}

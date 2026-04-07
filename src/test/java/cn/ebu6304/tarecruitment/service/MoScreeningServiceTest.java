package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class MoScreeningServiceTest {
    private ApplicationService applicationService;
    private ApplicationRepository applicationRepository;
    private JobRepository jobRepository;

    @BeforeEach
    void setUp() {
        applicationRepository = mock(ApplicationRepository.class);
        jobRepository = mock(JobRepository.class);
        applicationService = new ApplicationService(applicationRepository, jobRepository);
    }

    @Test
    void testListCandidatesByJob() {
        String jobId = "JOB001";
        ApplicationRecord candidate1 = new ApplicationRecord(
                "APP001", "user1", jobId, "SUBMITTED", "2026-04-07T00:00:00Z"
        );
        ApplicationRecord candidate2 = new ApplicationRecord(
                "APP002", "user2", jobId, "SUBMITTED", "2026-04-07T00:00:00Z"
        );
        
        when(applicationRepository.findByJobId(jobId, 1, 20))
                .thenReturn(List.of(candidate1, candidate2));
        
        List<ApplicationRecord> result = applicationService.listCandidatesByJob(jobId, 1, 20);
        
        assertEquals(2, result.size());
        assertEquals("APP001", result.get(0).applicationId());
        verify(applicationRepository).findByJobId(jobId, 1, 20);
    }

    @Test
    void testListCandidatesByJobAndStatus() {
        String jobId = "JOB001";
        String status = "INTERVIEWED";
        ApplicationRecord candidate = new ApplicationRecord(
                "APP001", "user1", jobId, status, "2026-04-07T00:00:00Z"
        );
        
        when(applicationRepository.findByJobIdAndStatus(jobId, status, 1, 20))
                .thenReturn(List.of(candidate));
        
        List<ApplicationRecord> result = applicationService.listCandidatesByJobAndStatus(jobId, status, 1, 20);
        
        assertEquals(1, result.size());
        assertEquals(status, result.get(0).status());
        verify(applicationRepository).findByJobIdAndStatus(jobId, status, 1, 20);
    }

    @Test
    void testGetJobStats() {
        Map<String, Long> stats = Map.of("JOB001", 5L, "JOB002", 3L);
        when(applicationRepository.countByJob()).thenReturn(stats);
        
        Map<String, Long> result = applicationService.getJobStats();
        
        assertEquals(2, result.size());
        assertEquals(5L, result.get("JOB001"));
        verify(applicationRepository).countByJob();
    }

    @Test
    void testGetJobStatusStats() {
        String jobId = "JOB001";
        Map<String, Long> stats = Map.of("SUBMITTED", 2L, "INTERVIEWED", 1L);
        when(applicationRepository.countByJobAndStatus(jobId)).thenReturn(stats);
        
        Map<String, Long> result = applicationService.getJobStatusStats(jobId);
        
        assertEquals(2, result.size());
        assertEquals(2L, result.get("SUBMITTED"));
        verify(applicationRepository).countByJobAndStatus(jobId);
    }

    @Test
    void testUpdateStatus() {
        String appId = "APP001";
        ApplicationRecord updated = new ApplicationRecord(
                appId, "user1", "JOB001", "ACCEPTED", "2026-04-07T00:00:00Z"
        );
        
        when(applicationRepository.updateStatus(appId, "ACCEPTED")).thenReturn(true);
        when(applicationRepository.findByApplicationId(appId)).thenReturn(java.util.Optional.of(updated));
        
        ApplicationService.UpdateStatusResponse response = applicationService.updateStatus(appId, "ACCEPTED");
        
        assertTrue(response.updated());
        assertEquals("ACCEPTED", response.record().status());
        verify(applicationRepository).updateStatus(appId, "ACCEPTED");
    }

    @Test
    void testUpdateStatusNotFound() {
        String appId = "NONEXISTENT";
        when(applicationRepository.updateStatus(appId, "ACCEPTED")).thenReturn(false);
        
        assertThrows(Exception.class, () -> applicationService.updateStatus(appId, "ACCEPTED"));
    }
}

package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JobServiceTest {
    @Test
    void createJobShouldRejectHoursAboveForty() throws Exception {
        JobService service = serviceWithEmptyRepository("job-hours-limit");

        assertThrows(ApiException.class, () -> service.createJob(
                "job-1", "Algorithms TA", "CS101", "Java", 2,
                41, futureDeadline(), 800, "mo1"
        ));
    }

    @Test
    void createJobShouldRejectPastDeadline() throws Exception {
        JobService service = serviceWithEmptyRepository("job-past-deadline");

        assertThrows(ApiException.class, () -> service.createJob(
                "job-1", "Algorithms TA", "CS101", "Java", 2,
                10, LocalDate.now().minusDays(1).toString(), 800, "mo1"
        ));
    }

    @Test
    void updateJobShouldReplaceCurrentJobWhenOwnerMatches() throws Exception {
        JobService service = serviceWithEmptyRepository("job-update");
        service.createJob("job-1", "Algorithms TA", "CS101", "Java", 2, 10, futureDeadline(), 800, "mo1");

        JobService.UpdateJobResponse response = service.updateJob(
                "job-1", "Advanced Algorithms TA", "CS201", "Java,Algorithms", 3,
                12, futureDeadline(), 1200, "mo1"
        );

        JobPosting updated = service.findByJobId("job-1").orElseThrow();
        assertTrue(response.updated());
        assertEquals("Advanced Algorithms TA", updated.title());
        assertEquals("CS201", updated.moduleCode());
        assertEquals(3, updated.slots());
        assertEquals(12, updated.hoursPerWeek());
        assertEquals(1200, updated.monthlyStipend());
    }

    private static JobService serviceWithEmptyRepository(String prefix) throws Exception {
        Path tempDir = Files.createTempDirectory(prefix);
        ObjectMapper mapper = new ObjectMapper();
        JobRepository jobRepository = new JobRepository(new JsonlFileStore<>(tempDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
        return new JobService(jobRepository);
    }

    private static String futureDeadline() {
        return LocalDate.now().plusDays(7).toString();
    }
}

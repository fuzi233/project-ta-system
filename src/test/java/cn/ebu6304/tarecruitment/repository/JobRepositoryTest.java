package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.OffsetDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class JobRepositoryTest {

    @Test
    void listAndCountShouldRespectQueryStatusAndPagination() throws Exception {
        Path tempFile = Files.createTempFile("jobs-repo", ".jsonl");
        JobRepository repository = new JobRepository(new JsonlFileStore<>(tempFile, JobPosting.class, new ObjectMapper()));

        repository.createIfAbsent(job("job-101", "Programming TA", "EBU6304", "Java,Git", "OPEN"));
        repository.createIfAbsent(job("job-102", "Database TA", "CS301", "SQL,MySQL", "OPEN"));
        repository.createIfAbsent(job("job-201", "Archived TA", "OLD101", "Java", "CLOSED"));

        List<JobPosting> byJobId = repository.list("job-101", "OPEN", 1, 10);
        List<JobPosting> firstPage = repository.list("", "OPEN", 1, 1);
        List<JobPosting> secondPage = repository.list("", "OPEN", 2, 1);

        assertEquals(1, byJobId.size());
        assertEquals("job-101", byJobId.getFirst().jobId());
        assertEquals(2L, repository.count("", "OPEN"));
        assertEquals(1, firstPage.size());
        assertEquals(1, secondPage.size());
    }

    private static JobPosting job(String jobId, String title, String moduleCode, String skills, String status) {
        return new JobPosting(
                jobId,
                title,
                moduleCode,
                skills,
                2,
                status,
                "mo-1",
                OffsetDateTime.now().toString()
        );
    }
}

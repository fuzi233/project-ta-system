package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ApplicationRepositoryTest {

    @Test
    void updateStatusShouldRefreshLatestViewAndSummaries() throws Exception {
        Path tempDir = Files.createTempDirectory("app-repo-update");
        Path file = tempDir.resolve("applications.jsonl");
        ApplicationRepository repository = new ApplicationRepository(
                new JsonlFileStore<>(file, ApplicationRecord.class, new ObjectMapper())
        );

        repository.saveIfAbsent(new ApplicationRecord(
                "app-1", "ta-1", "job-1", "SUBMITTED", "2026-04-11T00:00:00Z"
        ));
        assertTrue(repository.updateStatus("app-1", "INTERVIEWED"));

        ApplicationRecord latest = repository.findByApplicationId("app-1").orElseThrow();
        assertEquals("INTERVIEWED", latest.status());
        assertEquals(0, repository.findByJobIdAndStatus("job-1", "SUBMITTED", 1, 10).size());
        assertEquals(1, repository.findByJobIdAndStatus("job-1", "INTERVIEWED", 1, 10).size());
        assertEquals(1L, repository.totalCount());
        assertEquals(1L, repository.statusSummary().get("INTERVIEWED"));
    }

    @Test
    void updateStatusShouldReturnFalseWhenMissingOrUnchanged() throws Exception {
        Path tempDir = Files.createTempDirectory("app-repo-missing");
        ApplicationRepository repository = new ApplicationRepository(
                new JsonlFileStore<>(tempDir.resolve("applications.jsonl"), ApplicationRecord.class, new ObjectMapper())
        );

        repository.saveIfAbsent(new ApplicationRecord(
                "app-1", "ta-1", "job-1", "SUBMITTED", "2026-04-11T00:00:00Z"
        ));

        assertFalse(repository.updateStatus("missing", "ACCEPTED"));
        assertFalse(repository.updateStatus("app-1", "SUBMITTED"));
    }

    @Test
    void compactShouldKeepOnlyLatestVersionPerApplicationId() throws Exception {
        Path tempDir = Files.createTempDirectory("app-repo-compact");
        Path file = tempDir.resolve("applications.jsonl");
        ApplicationRepository repository = new ApplicationRepository(
                new JsonlFileStore<>(file, ApplicationRecord.class, new ObjectMapper())
        );

        repository.saveIfAbsent(new ApplicationRecord(
                "app-1", "ta-1", "job-1", "SUBMITTED", "2026-04-11T00:00:00Z"
        ));
        repository.saveIfAbsent(new ApplicationRecord(
                "app-2", "ta-2", "job-1", "SUBMITTED", "2026-04-11T00:00:00Z"
        ));
        repository.updateStatus("app-1", "INTERVIEWED");
        repository.updateStatus("app-1", "ACCEPTED");
        assertEquals(4, Files.readAllLines(file).size());

        repository.compact();

        assertEquals(2, Files.readAllLines(file).size());
        assertEquals("ACCEPTED", repository.findByApplicationId("app-1").orElseThrow().status());
        assertEquals(Map.of("ta-1", 1L, "ta-2", 1L), repository.workloadByApplicant());
    }
}

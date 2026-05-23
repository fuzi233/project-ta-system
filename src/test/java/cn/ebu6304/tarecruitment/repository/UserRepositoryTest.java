package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UserRepositoryTest {

    @Test
    void shouldFindByRoleAndLoginKeyUsingIdentifierOrEmail() throws Exception {
        Path file = Files.createTempFile("users-repo", ".jsonl");
        UserRepository repository = new UserRepository(
                new JsonlFileStore<>(file, UserProfile.class, new ObjectMapper())
        );

        repository.upsert(new UserProfile(
                "ta-001",
                "Alice",
                "TA",
                "2023000001",
                "alice@example.com",
                "hash",
                "Java",
                "",
                "2026-04-11T00:00:00Z"
        ));

        assertTrue(repository.findByRoleAndLoginKey("TA", "2023000001").isPresent());
        assertTrue(repository.findByRoleAndLoginKey("TA", "alice@example.com").isPresent());
    }

    @Test
    void shouldUpdateIndexesAfterUpsert() throws Exception {
        Path file = Files.createTempFile("users-repo-upsert", ".jsonl");
        UserRepository repository = new UserRepository(
                new JsonlFileStore<>(file, UserProfile.class, new ObjectMapper())
        );

        repository.upsert(new UserProfile(
                "ta-002",
                "Bob",
                "TA",
                "2023000002",
                "bob-old@example.com",
                "hash",
                "SQL",
                "",
                "2026-04-11T00:00:00Z"
        ));
        repository.upsert(new UserProfile(
                "ta-002",
                "Bob",
                "TA",
                "2023000002",
                "bob-new@example.com",
                "hash2",
                "SQL",
                "",
                "2026-04-11T00:01:00Z"
        ));

        assertTrue(repository.existsByEmail("bob-new@example.com"));
        assertFalse(repository.existsByEmail("bob-old@example.com"));
        assertEquals("ta-002", repository.findByRoleAndIdentifier("TA", "2023000002").orElseThrow().userId());
    }
}

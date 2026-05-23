package cn.ebu6304.tarecruitment.storage;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JsonlFileStoreTest {

    @Test
    void appendAndReadPageShouldWork() throws Exception {
        Path file = Files.createTempFile("applications", ".jsonl");
        JsonlFileStore<ApplicationRecord> store = new JsonlFileStore<>(file, ApplicationRecord.class, new ObjectMapper());

        store.append(new ApplicationRecord("a1", "ta1", "j1", "SUBMITTED", "2026-03-12T00:00:00Z"));
        store.append(new ApplicationRecord("a2", "ta1", "j2", "SUBMITTED", "2026-03-12T00:00:00Z"));
        store.append(new ApplicationRecord("a3", "ta2", "j3", "SUBMITTED", "2026-03-12T00:00:00Z"));

        List<ApplicationRecord> page = store.readPage(1, 10, item -> item.applicantId().equals("ta1"));
        assertEquals(2, page.size());
        assertEquals("a1", page.get(0).applicationId());
        assertEquals("a2", page.get(1).applicationId());

        assertTrue(store.readAtLine(2).isPresent());
        assertEquals("a2", store.readAtLine(2).orElseThrow().applicationId());
    }

    @Test
    void trailingCorruptLineShouldNotBreakReads() throws Exception {
        Path file = Files.createTempFile("applications-corrupt-tail", ".jsonl");
        JsonlFileStore<ApplicationRecord> store = new JsonlFileStore<>(file, ApplicationRecord.class, new ObjectMapper());

        store.append(new ApplicationRecord("a1", "ta1", "j1", "SUBMITTED", "2026-03-12T00:00:00Z"));
        Files.writeString(file, "{\"applicationId\":", StandardCharsets.UTF_8, StandardOpenOption.APPEND);

        List<ApplicationRecord> page = store.readPage(1, 10, item -> true);
        assertEquals(1, page.size());
        assertEquals("a1", page.get(0).applicationId());
        assertTrue(store.readAtLine(1).isPresent());
    }
}

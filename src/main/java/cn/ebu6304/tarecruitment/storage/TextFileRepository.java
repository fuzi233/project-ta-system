package cn.ebu6304.tarecruitment.storage;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;

public class TextFileRepository {
    private final Path filePath;

    public TextFileRepository(String filePath) {
        this.filePath = Path.of(filePath);
        ensureFileExists();
    }

    public List<ApplicationRecord> loadApplications() {
        try {
            List<String> lines = Files.readAllLines(filePath);
            List<ApplicationRecord> records = new ArrayList<>();
            for (String line : lines) {
                if (line.isBlank()) {
                    continue;
                }
                String[] parts = line.split(",", -1);
                if (parts.length == 3) {
                    records.add(new ApplicationRecord(parts[0], parts[1], parts[2]));
                }
            }
            return records;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read applications file", e);
        }
    }

    public void saveApplication(ApplicationRecord record) {
        String line = record.applicantId() + "," + record.jobId() + "," + record.status() + System.lineSeparator();
        try {
            Files.writeString(filePath, line, StandardOpenOption.APPEND);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to write applications file", e);
        }
    }

    private void ensureFileExists() {
        try {
            Files.createDirectories(filePath.getParent());
            if (Files.notExists(filePath)) {
                Files.createFile(filePath);
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to initialize data file", e);
        }
    }
}

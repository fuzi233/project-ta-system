package cn.ebu6304.tarecruitment.storage;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;
import java.util.function.Predicate;

public class JsonlFileStore<T> {
    private final Path filePath;
    private final Class<T> valueType;
    private final ObjectMapper objectMapper;

    public JsonlFileStore(Path filePath, Class<T> valueType, ObjectMapper objectMapper) {
        this.filePath = filePath;
        this.valueType = valueType;
        this.objectMapper = objectMapper;
        ensureFileExists();
    }

    public synchronized void append(T record) {
        withExclusiveLock(() -> {
            String line = objectMapper.writeValueAsString(record) + System.lineSeparator();
            byte[] bytes = line.getBytes(StandardCharsets.UTF_8);
            try (FileChannel channel = FileChannel.open(filePath, StandardOpenOption.CREATE, StandardOpenOption.WRITE, StandardOpenOption.APPEND)) {
                ByteBuffer buffer = ByteBuffer.wrap(bytes);
                while (buffer.hasRemaining()) {
                    channel.write(buffer);
                }
                channel.force(true);
            }
            return null;
        });
    }

    public synchronized List<T> readPage(int page, int size, Predicate<T> filter) {
        if (page < 1 || size < 1) {
            return List.of();
        }
        int start = (page - 1) * size;
        int end = start + size;
        int matched = 0;
        List<T> result = new ArrayList<>(size);
        try (BufferedReader reader = Files.newBufferedReader(filePath, StandardCharsets.UTF_8)) {
            String line;
            long physicalLine = 0;
            while ((line = reader.readLine()) != null) {
                physicalLine++;
                if (line.isBlank()) {
                    continue;
                }
                T value = parseOrNullIfTrailingCorrupt(reader, line, physicalLine);
                if (value == null) {
                    break;
                }
                if (!filter.test(value)) {
                    continue;
                }
                if (matched >= start && matched < end) {
                    result.add(value);
                }
                matched++;
                if (matched >= end) {
                    break;
                }
            }
            return result;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read page from JSONL: " + filePath, e);
        }
    }

    public synchronized Optional<T> readAtLine(long lineNumber) {
        if (lineNumber < 1) {
            return Optional.empty();
        }
        long current = 0;
        try (BufferedReader reader = Files.newBufferedReader(filePath, StandardCharsets.UTF_8)) {
            String line;
            long physicalLine = 0;
            while ((line = reader.readLine()) != null) {
                physicalLine++;
                if (line.isBlank()) {
                    continue;
                }
                current++;
                if (current == lineNumber) {
                    T value = parseOrNullIfTrailingCorrupt(reader, line, physicalLine);
                    return Optional.ofNullable(value);
                }
            }
            return Optional.empty();
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read line from JSONL: " + filePath, e);
        }
    }

    public synchronized void forEach(Consumer<T> consumer) {
        try (BufferedReader reader = Files.newBufferedReader(filePath, StandardCharsets.UTF_8)) {
            String line;
            long physicalLine = 0;
            while ((line = reader.readLine()) != null) {
                physicalLine++;
                if (line.isBlank()) {
                    continue;
                }
                T value = parseOrNullIfTrailingCorrupt(reader, line, physicalLine);
                if (value == null) {
                    break;
                }
                consumer.accept(value);
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to stream JSONL: " + filePath, e);
        }
    }

    public synchronized long count(Predicate<T> filter) {
        final long[] count = {0L};
        forEach(value -> {
            if (filter.test(value)) {
                count[0]++;
            }
        });
        return count[0];
    }

    public synchronized void replaceAll(List<T> records) {
        withExclusiveLock(() -> {
            Path temp = filePath.resolveSibling(filePath.getFileName() + ".tmp");
            try (BufferedWriter writer = Files.newBufferedWriter(
                    temp,
                    StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.TRUNCATE_EXISTING,
                    StandardOpenOption.WRITE
            )) {
                for (T record : records) {
                    writer.write(objectMapper.writeValueAsString(record));
                    writer.newLine();
                }
            } catch (IOException e) {
                throw new IllegalStateException("Failed to write temporary compact file: " + temp, e);
            }

            try (FileChannel channel = FileChannel.open(temp, StandardOpenOption.READ)) {
                channel.force(true);
            } catch (IOException e) {
                throw new IllegalStateException("Failed to fsync temporary compact file: " + temp, e);
            }

            try {
                Files.move(temp, filePath, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            } catch (AtomicMoveNotSupportedException e) {
                try {
                    Files.move(temp, filePath, StandardCopyOption.REPLACE_EXISTING);
                } catch (IOException ioException) {
                    bestEffortDelete(temp);
                    throw new IllegalStateException("Failed to replace compact file: " + filePath, ioException);
                }
            } catch (IOException e) {
                bestEffortDelete(temp);
                throw new IllegalStateException("Failed to atomically replace file: " + filePath, e);
            }
            return null;
        });
    }

    private T parseOrNullIfTrailingCorrupt(BufferedReader reader, String line, long physicalLine) throws IOException {
        try {
            return objectMapper.readValue(line, valueType);
        } catch (IOException parseException) {
            reader.mark(1024 * 1024);
            boolean atEof = reader.readLine() == null;
            if (atEof) {
                return null;
            }
            throw new IllegalStateException("Corrupt JSONL at " + filePath + " physicalLine=" + physicalLine, parseException);
        }
    }

    private synchronized <R> R withExclusiveLock(IoSupplier<R> supplier) {
        try {
            Path lockFilePath = filePath.resolveSibling(filePath.getFileName() + ".lock");
            try (FileChannel lockChannel = FileChannel.open(lockFilePath, StandardOpenOption.CREATE, StandardOpenOption.WRITE);
                 FileLock ignored = lockChannel.lock()) {
                return supplier.get();
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to lock file store: " + filePath, e);
        }
    }

    private void bestEffortDelete(Path path) {
        try {
            Files.deleteIfExists(path);
        } catch (IOException ignored) {
        }
    }

    @FunctionalInterface
    private interface IoSupplier<R> {
        R get() throws IOException;
    }

    private void ensureFileExists() {
        try {
            Path parent = filePath.getParent();
            if (parent != null) {
                Files.createDirectories(parent);
            }
            if (Files.notExists(filePath)) {
                Files.createFile(filePath);
            }
        } catch (IOException e) {
            throw new IllegalStateException("Failed to initialize file store: " + filePath, e);
        }
    }
}

package cn.ebu6304.tarecruitment.ai;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

public record AiRuntimeConfig(String apiKey, String model, String endpoint) {
    private static final String DEFAULT_MODEL = "gpt-5.3";
    private static final String DEFAULT_ENDPOINT = "https://api.openai.com/v1/chat/completions";
    private static final String DEFAULT_CONFIG_PATH = "config/ai.local.properties";

    public static AiRuntimeConfig load() {
        Properties properties = loadProperties();

        String apiKey = firstNonBlank(
                System.getenv("OPENAI_API_KEY"),
                properties.getProperty("openai.api.key"),
                ""
        );
        String model = firstNonBlank(
                System.getenv("OPENAI_MODEL"),
                properties.getProperty("openai.model"),
                DEFAULT_MODEL
        );
        String endpoint = firstNonBlank(
                System.getenv("OPENAI_API_ENDPOINT"),
                properties.getProperty("openai.api.endpoint"),
                DEFAULT_ENDPOINT
        );

        return new AiRuntimeConfig(apiKey, model, endpoint);
    }

    private static Properties loadProperties() {
        Properties properties = new Properties();
        String configuredPath = System.getProperty("ta.ai.config", DEFAULT_CONFIG_PATH);
        Path path = Path.of(configuredPath);
        if (!Files.exists(path)) {
            return properties;
        }

        try (InputStream inputStream = Files.newInputStream(path)) {
            properties.load(inputStream);
        } catch (IOException ignored) {
            // Keep startup resilient; fallback to env/default values.
        }
        return properties;
    }

    private static String firstNonBlank(String first, String second, String fallback) {
        if (first != null && !first.isBlank()) {
            return first.trim();
        }
        if (second != null && !second.isBlank()) {
            return second.trim();
        }
        return fallback;
    }
}

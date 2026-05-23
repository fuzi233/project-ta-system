package cn.ebu6304.tarecruitment.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;

public class OpenAiChatProvider implements AiProvider {
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;
    private final String apiKey;
    private final String model;
    private final URI endpoint;

    public OpenAiChatProvider(ObjectMapper objectMapper, String apiKey, String model, String endpoint) {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();
        this.objectMapper = objectMapper;
        this.apiKey = apiKey;
        this.model = model;
        this.endpoint = URI.create(normalizeEndpoint(endpoint));
    }

    @Override
    public String name() {
        return "openai:" + model;
    }

    @Override
    public String generate(String systemInstruction, String userPrompt) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("OPENAI_API_KEY is missing");
        }

        Map<String, Object> body = Map.of(
                "model", model,
                "messages", new Object[]{
                        Map.of("role", "system", "content", systemInstruction),
                        Map.of("role", "user", "content", userPrompt)
                },
                "temperature", 0.2
        );

        final String json;
        try {
            json = objectMapper.writeValueAsString(body);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to build OpenAI request", e);
        }

        HttpRequest request = HttpRequest.newBuilder(endpoint)
                .timeout(Duration.ofSeconds(12))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(json))
                .build();

        final HttpResponse<String> response;
        try {
            response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("OpenAI request interrupted", e);
        } catch (IOException e) {
            throw new IllegalStateException("OpenAI request failed", e);
        }

        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("OpenAI request failed with status " + response.statusCode());
        }

        try {
            JsonNode root = objectMapper.readTree(response.body());
            JsonNode content = root.path("choices").path(0).path("message").path("content");
            if (content.isMissingNode() || content.asText().isBlank()) {
                throw new IllegalStateException("OpenAI response has empty content");
            }
            return content.asText().trim();
        } catch (IOException e) {
            throw new IllegalStateException("Failed to parse OpenAI response", e);
        }
    }

    static String normalizeEndpoint(String rawEndpoint) {
        if (rawEndpoint == null || rawEndpoint.isBlank()) {
            return "https://api.openai.com/v1/chat/completions";
        }
        String endpoint = rawEndpoint.trim();
        String lower = endpoint.toLowerCase();
        if (lower.endsWith("/chat/completions") || lower.endsWith("/responses")) {
            return endpoint;
        }
        if (lower.endsWith("/v1/")) {
            return endpoint + "chat/completions";
        }
        if (lower.endsWith("/v1")) {
            return endpoint + "/chat/completions";
        }
        if (lower.endsWith("/")) {
            return endpoint + "chat/completions";
        }
        return endpoint + "/chat/completions";
    }
}

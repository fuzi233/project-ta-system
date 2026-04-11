package cn.ebu6304.tarecruitment.ai;

import com.fasterxml.jackson.databind.ObjectMapper;

public final class AiProviderFactory {
    private AiProviderFactory() {
    }

    public static AiProvider fromRuntimeConfig(ObjectMapper objectMapper) {
        AiRuntimeConfig config = AiRuntimeConfig.load();
        if (config.apiKey() == null || config.apiKey().isBlank()) {
            return new RuleBasedAiProvider();
        }
        return new OpenAiChatProvider(objectMapper, config.apiKey(), config.model(), config.endpoint());
    }
}

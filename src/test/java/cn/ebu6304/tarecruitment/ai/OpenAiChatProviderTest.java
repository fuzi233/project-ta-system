package cn.ebu6304.tarecruitment.ai;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class OpenAiChatProviderTest {

    @Test
    void shouldNormalizeEndpointFromV1Base() {
        assertEquals(
                "https://api2.aigcbest.top/v1/chat/completions",
                OpenAiChatProvider.normalizeEndpoint("https://api2.aigcbest.top/v1/")
        );
        assertEquals(
                "https://api2.aigcbest.top/v1/chat/completions",
                OpenAiChatProvider.normalizeEndpoint("https://api2.aigcbest.top/v1")
        );
    }

    @Test
    void shouldKeepFullEndpointUnchanged() {
        assertEquals(
                "https://api.openai.com/v1/chat/completions",
                OpenAiChatProvider.normalizeEndpoint("https://api.openai.com/v1/chat/completions")
        );
    }
}

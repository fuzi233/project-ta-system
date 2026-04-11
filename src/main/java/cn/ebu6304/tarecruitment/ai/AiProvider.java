package cn.ebu6304.tarecruitment.ai;

public interface AiProvider {
    String name();

    String generate(String systemInstruction, String userPrompt);
}

package cn.ebu6304.tarecruitment.ai;

public class RuleBasedAiProvider implements AiProvider {
    @Override
    public String name() {
        return "rule-based";
    }

    @Override
    public String generate(String systemInstruction, String userPrompt) {
        return "Heuristic analysis generated locally. "
                + "The recommendation is based on skill overlap, missing skills, and current workload.";
    }
}

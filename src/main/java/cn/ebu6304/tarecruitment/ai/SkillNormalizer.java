package cn.ebu6304.tarecruitment.ai;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public final class SkillNormalizer {
    private static final Map<String, String> ALIAS = new LinkedHashMap<>();

    static {
        ALIAS.put("oop", "object-oriented programming");
        ALIAS.put("o-o-p", "object-oriented programming");
        ALIAS.put("object oriented programming", "object-oriented programming");
        ALIAS.put("machine-learning", "machine learning");
        ALIAS.put("ml", "machine learning");
        ALIAS.put("nlp", "natural language processing");
        ALIAS.put("js", "javascript");
        ALIAS.put("java se", "java");
        ALIAS.put("py", "python");
    }

    private SkillNormalizer() {
    }

    public static List<String> normalizeList(String rawSkills) {
        if (rawSkills == null || rawSkills.isBlank()) {
            return List.of();
        }
        Set<String> normalized = new LinkedHashSet<>();
        Arrays.stream(rawSkills.split("[,;/|]"))
                .map(String::trim)
                .filter(token -> !token.isEmpty())
                .map(SkillNormalizer::normalizeToken)
                .forEach(normalized::add);
        return new ArrayList<>(normalized);
    }

    private static String normalizeToken(String token) {
        String normalized = token.trim().toLowerCase(Locale.ROOT);
        return ALIAS.getOrDefault(normalized, normalized);
    }
}

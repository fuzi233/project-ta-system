package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.ai.RuleBasedAiProvider;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.repository.UserRepository;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AiServiceTest {

    @Test
    void matchShouldReturnMissingSkillsAndScore() throws Exception {
        Fixture fixture = new Fixture();
        fixture.userRepository.upsert(new UserProfile("ta1", "Alice", "TA", "Java, OOP", "2026-04-10T00:00:00Z"));
        fixture.jobRepository.createIfAbsent(new JobPosting("job1", "AI TA", "CS6304", "Java, Machine Learning", 2, "OPEN", "mo1", "2026-04-10T00:00:00Z"));

        AiService service = fixture.aiService();
        AiService.MatchInsight insight = service.match("ta1", "job1");

        assertTrue(insight.matchedSkills().contains("java"));
        assertTrue(insight.missingSkills().contains("machine learning"));
        assertEquals("rule-based", insight.provider());
    }

    @Test
    void workloadSuggestionShouldPreferLowerWorkloadWhenFitIsSimilar() throws Exception {
        Fixture fixture = new Fixture();
        fixture.userRepository.upsert(new UserProfile("taLow", "LowLoad", "TA", "Java, Data Analysis", "2026-04-10T00:00:00Z"));
        fixture.userRepository.upsert(new UserProfile("taHigh", "HighLoad", "TA", "Java, Data Analysis", "2026-04-10T00:00:00Z"));
        fixture.jobRepository.createIfAbsent(new JobPosting("job2", "Data TA", "CS7001", "Java, Data Analysis", 1, "OPEN", "mo2", "2026-04-10T00:00:00Z"));

        for (int i = 0; i < 4; i++) {
            fixture.applicationRepository.saveIfAbsent(new ApplicationRecord(
                    "high-" + i,
                    "taHigh",
                    "job2",
                    "SUBMITTED",
                    "2026-04-10T00:00:00Z"
            ));
        }

        AiService service = fixture.aiService();
        AiService.WorkloadSuggestion suggestion = service.workloadSuggestion("job2", 2);

        assertEquals(2, suggestion.candidates().size());
        assertEquals("taLow", suggestion.candidates().get(0).applicantId());
    }

    private static final class Fixture {
        private final JobRepository jobRepository;
        private final UserRepository userRepository;
        private final ApplicationRepository applicationRepository;

        private Fixture() throws Exception {
            Path tmpDir = Files.createTempDirectory("ai-service-test");
            ObjectMapper mapper = new ObjectMapper();
            this.jobRepository = new JobRepository(new JsonlFileStore<>(tmpDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
            this.userRepository = new UserRepository(new JsonlFileStore<>(tmpDir.resolve("users.jsonl"), UserProfile.class, mapper));
            this.applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tmpDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));
        }

        private AiService aiService() {
            return new AiService(jobRepository, userRepository, applicationRepository, new RuleBasedAiProvider());
        }
    }
}

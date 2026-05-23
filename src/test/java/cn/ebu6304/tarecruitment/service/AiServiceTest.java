package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.ai.RuleBasedAiProvider;
import cn.ebu6304.tarecruitment.model.AttachmentRecord;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.repository.AttachmentRepository;
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
        fixture.userRepository.upsert(new UserProfile(
                "ta1",
                "Alice",
                "TA",
                "ta001",
                "ta001@bupt.edu.cn",
                "hash",
                "Java, OOP",
                "Built Java coursework systems and supported lab sessions.",
                "2026-04-10T00:00:00Z"
        ));
        fixture.jobRepository.createIfAbsent(new JobPosting("job1", "AI TA", "CS6304", "Java, Machine Learning", 2, 10, "2026-01-01", 800, "OPEN", "mo1", "2026-04-10T00:00:00Z"));

        AiService service = fixture.aiService();
        AiService.MatchInsight insight = service.match("ta1", "job1");

        assertTrue(insight.matchedSkills().contains("java"));
        assertTrue(insight.missingSkills().contains("machine learning"));
        assertEquals("rule-based", insight.provider());
    }

    @Test
    void workloadSuggestionShouldPreferLowerWorkloadWhenFitIsSimilar() throws Exception {
        Fixture fixture = new Fixture();
        fixture.userRepository.upsert(new UserProfile(
                "taLow", "LowLoad", "TA", "taLow", "low@bupt.edu.cn", "hash", "Java, Data Analysis",
                "Practical data analytics assignment and tutoring experience.",
                "2026-04-10T00:00:00Z"
        ));
        fixture.userRepository.upsert(new UserProfile(
                "taHigh", "HighLoad", "TA", "taHigh", "high@bupt.edu.cn", "hash", "Java, Data Analysis",
                "Solid profile with multiple coding assignments.",
                "2026-04-10T00:00:00Z"
        ));
        fixture.jobRepository.createIfAbsent(new JobPosting("job2", "Data TA", "CS7001", "Java, Data Analysis", 1, 10, "2026-01-01", 800, "OPEN", "mo2", "2026-04-10T00:00:00Z"));

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

    @Test
    void hrAssessmentShouldIncludeResumeSummaryAndExplanation() throws Exception {
        Fixture fixture = new Fixture();
        fixture.userRepository.upsert(new UserProfile(
                "ta10", "ResumeUser", "TA", "ta010", "ta010@bupt.edu.cn", "hash",
                "Java, Software Engineering, Testing",
                "Served as a peer tutor for software engineering labs, led code review sessions, and delivered a full Java web prototype.",
                "2026-04-10T00:00:00Z"
        ));
        fixture.jobRepository.createIfAbsent(new JobPosting("job10", "SE TA", "EBU6304", "Java, Software Engineering, Testing", 2, 10, "2026-01-01", 800, "OPEN", "mo1", "2026-04-10T00:00:00Z"));

        AiService.HrCandidateInsight insight = fixture.aiService().hrAssessCandidate("ta10", "job10");

        assertTrue(insight.resumeSummary() != null && !insight.resumeSummary().isBlank());
        assertTrue(insight.explanation() != null && !insight.explanation().isBlank());
        assertTrue(insight.score() >= 0 && insight.score() <= 100);
    }

    private static final class Fixture {
        private final JobRepository jobRepository;
        private final UserRepository userRepository;
        private final ApplicationRepository applicationRepository;
        private final AttachmentService attachmentService;

        private Fixture() throws Exception {
            Path tmpDir = Files.createTempDirectory("ai-service-test");
            ObjectMapper mapper = new ObjectMapper();
            this.jobRepository = new JobRepository(new JsonlFileStore<>(tmpDir.resolve("jobs.jsonl"), JobPosting.class, mapper));
            this.userRepository = new UserRepository(new JsonlFileStore<>(tmpDir.resolve("users.jsonl"), UserProfile.class, mapper));
            this.applicationRepository = new ApplicationRepository(new JsonlFileStore<>(tmpDir.resolve("applications.jsonl"), ApplicationRecord.class, mapper));
            AttachmentRepository attachmentRepository = new AttachmentRepository(
                    new JsonlFileStore<>(tmpDir.resolve("attachments.jsonl"), AttachmentRecord.class, mapper)
            );
            this.attachmentService = new AttachmentService(attachmentRepository, tmpDir.resolve("uploads"));
        }

        private AiService aiService() {
            return new AiService(jobRepository, userRepository, applicationRepository, attachmentService, new RuleBasedAiProvider());
        }
    }
}

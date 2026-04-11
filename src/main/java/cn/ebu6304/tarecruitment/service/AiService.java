package cn.ebu6304.tarecruitment.service;

import cn.ebu6304.tarecruitment.ai.AiProvider;
import cn.ebu6304.tarecruitment.ai.RuleBasedAiProvider;
import cn.ebu6304.tarecruitment.ai.SkillNormalizer;
import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.repository.UserRepository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class AiService {
    private final JobRepository jobRepository;
    private final UserRepository userRepository;
    private final ApplicationRepository applicationRepository;
    private final AiProvider aiProvider;
    private final AiProvider fallbackProvider;

    public AiService(
            JobRepository jobRepository,
            UserRepository userRepository,
            ApplicationRepository applicationRepository,
            AiProvider aiProvider
    ) {
        this.jobRepository = jobRepository;
        this.userRepository = userRepository;
        this.applicationRepository = applicationRepository;
        this.aiProvider = aiProvider;
        this.fallbackProvider = new RuleBasedAiProvider();
    }

    public MatchInsight match(String applicantId, String jobId) {
        String normalizedApplicantId = Validators.requireNonBlank(applicantId, "applicantId");
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");

        UserProfile applicant = userRepository.findById(normalizedApplicantId)
                .orElseThrow(() -> new ApiException(404, "Applicant not found: " + normalizedApplicantId));
        JobPosting job = jobRepository.findById(normalizedJobId)
                .orElseThrow(() -> new ApiException(404, "Job not found: " + normalizedJobId));

        return calculateInsight(
                applicant,
                job,
                applicationRepository.workloadByApplicant(),
                true
        );
    }

    public MissingSkillsInsight missingSkills(String applicantId, String jobId) {
        MatchInsight insight = match(applicantId, jobId);
        List<String> suggestions = buildSuggestions(insight.missingSkills());

        String basePrompt = "Missing skill analysis for applicant " + insight.applicantId()
                + " against job " + insight.jobId() + "."
                + " Missing skills: " + String.join(", ", insight.missingSkills())
                + ". Provide concise learning steps for this semester.";

        ProviderReply providerReply = requestProvider(
                "You are an assistant helping teaching-assistant candidates improve employability.",
                basePrompt,
                "Focus on missing skill remediation and short, practical advice."
        );

        return new MissingSkillsInsight(
                insight.applicantId(),
                insight.jobId(),
                insight.missingSkills(),
                suggestions,
                providerReply.text(),
                providerReply.provider()
        );
    }

    public HrCandidateInsight hrAssessCandidate(String candidateUserId, String jobId) {
        String normalizedUserId = Validators.requireNonBlank(candidateUserId, "candidateUserId");
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");

        UserProfile candidate = userRepository.findById(normalizedUserId)
                .orElseThrow(() -> new ApiException(404, "Candidate not found: " + normalizedUserId));
        JobPosting job = jobRepository.findById(normalizedJobId)
                .orElseThrow(() -> new ApiException(404, "Job not found: " + normalizedJobId));

        MatchInsight matchInsight = calculateInsight(
                candidate,
                job,
                applicationRepository.workloadByApplicant(),
                true
        );
        String resumeText = resolvedResume(candidate);

        ProviderReply summaryReply = requestProvider(
                "You are an HR assistant. Summarize CVs in 3 concise bullet points.",
                "Candidate profile: name=" + candidate.displayName()
                        + ", skills=" + candidate.skills()
                        + ", resume=" + resumeText,
                "Summarize this candidate's background, practical project evidence, and teaching support potential."
        );

        ProviderReply explanationReply = requestProvider(
                "You are an explainable TA recruitment advisor.",
                "Job=" + job.title() + "(" + job.jobId() + "), requiredSkills=" + job.requiredSkills()
                        + "; candidate=" + candidate.userId() + ", matched=" + matchInsight.matchedSkills()
                        + ", missing=" + matchInsight.missingSkills()
                        + ", workload=" + matchInsight.workload()
                        + ", score=" + matchInsight.score(),
                "Explain why this score is reasonable and what HR should verify in interview."
        );

        return new HrCandidateInsight(
                candidate.userId(),
                candidate.displayName(),
                candidate.role(),
                candidate.identifier(),
                candidate.email(),
                candidate.skills(),
                resumeText,
                summaryReply.text(),
                matchInsight.score(),
                matchInsight.workload(),
                matchInsight.matchedSkills(),
                matchInsight.missingSkills(),
                explanationReply.text(),
                explanationReply.provider()
        );
    }

    public WorkloadSuggestion workloadSuggestion(String jobId, int limit) {
        String normalizedJobId = Validators.requireNonBlank(jobId, "jobId");
        int normalizedLimit = Math.max(1, Math.min(limit, 20));

        JobPosting job = jobRepository.findById(normalizedJobId)
                .orElseThrow(() -> new ApiException(404, "Job not found: " + normalizedJobId));

        List<UserProfile> allTaCandidates = userRepository.listByRole("TA");
        if (allTaCandidates.isEmpty()) {
            allTaCandidates = userRepository.listAll();
        }

        List<CandidateSuggestion> candidates = new ArrayList<>();
        Map<String, Long> workloadMap = applicationRepository.workloadByApplicant();
        for (UserProfile candidate : allTaCandidates) {
            MatchInsight insight = calculateInsight(candidate, job, workloadMap, false);
            candidates.add(new CandidateSuggestion(
                    candidate.userId(),
                    candidate.displayName(),
                    insight.score(),
                    insight.workload(),
                    insight.matchedSkills(),
                    insight.missingSkills(),
                    insight.reasoning()
            ));
        }

        candidates.sort(Comparator
                .comparingInt(CandidateSuggestion::score).reversed()
                .thenComparingLong(CandidateSuggestion::currentWorkload)
                .thenComparing(CandidateSuggestion::applicantId));

        List<CandidateSuggestion> topCandidates = candidates.stream().limit(normalizedLimit).collect(Collectors.toList());

        String shortList = topCandidates.stream()
                .map(item -> item.applicantId() + "(score=" + item.score() + ", workload=" + item.currentWorkload() + ")")
                .collect(Collectors.joining("; "));

        ProviderReply providerReply = requestProvider(
                "You assist an academic admin team in making fair TA allocation decisions.",
                "Given job " + job.jobId() + " (" + job.title() + ") and candidates: " + shortList,
                "Explain why the shortlist is balanced in terms of skill fit and workload fairness."
        );

        return new WorkloadSuggestion(
                normalizedJobId,
                topCandidates,
                providerReply.text(),
                providerReply.provider()
        );
    }

    private MatchInsight calculateInsight(
            UserProfile applicant,
            JobPosting job,
            Map<String, Long> workloadMap,
            boolean enrichReasoning
    ) {
        List<String> applicantSkills = SkillNormalizer.normalizeList(applicant.skills());
        List<String> requiredSkills = SkillNormalizer.normalizeList(job.requiredSkills());

        Set<String> applicantSet = new LinkedHashSet<>(applicantSkills);
        Set<String> requiredSet = new LinkedHashSet<>(requiredSkills);

        List<String> matched = requiredSet.stream()
                .filter(applicantSet::contains)
                .collect(Collectors.toList());

        List<String> missing = requiredSet.stream()
                .filter(skill -> !applicantSet.contains(skill))
                .collect(Collectors.toList());

        long workload = workloadMap.getOrDefault(applicant.userId(), 0L);

        int fitScore = requiredSet.isEmpty() ? 100 : (matched.size() * 100 / requiredSet.size());
        int workloadPenalty = (int) Math.min(25, workload * 4);
        int finalScore = Math.max(0, Math.min(100, fitScore - workloadPenalty));

        String reasoningText;
        String providerName;
        if (enrichReasoning) {
            String prompt = "Applicant=" + applicant.userId()
                    + ", job=" + job.jobId()
                    + ", matchedSkills=" + matched
                    + ", missingSkills=" + missing
                    + ", workload=" + workload
                    + ", score=" + finalScore + "."
                    + " Return one concise recommendation sentence.";

            ProviderReply providerReply = requestProvider(
                    "You are an explainable matching assistant for TA recruitment.",
                    prompt,
                    "Emphasize concrete evidence (skills + workload) and keep it concise."
            );
            reasoningText = providerReply.text();
            providerName = providerReply.provider();
        } else {
            reasoningText = "Rule-based shortlist candidate: matched="
                    + matched.size() + ", missing=" + missing.size()
                    + ", workload=" + workload + ", score=" + finalScore + ".";
            providerName = "rule-based";
        }

        return new MatchInsight(
                applicant.userId(),
                job.jobId(),
                finalScore,
                workload,
                matched,
                missing,
                reasoningText,
                providerName
        );
    }

    private String resolvedResume(UserProfile candidate) {
        if (candidate.resumeText() != null && !candidate.resumeText().isBlank()) {
            return candidate.resumeText().trim();
        }
        return "No full CV text provided. Skills available: " + candidate.skills();
    }

    private ProviderReply requestProvider(String systemInstruction, String userPrompt, String fallbackSuffix) {
        try {
            String text = aiProvider.generate(systemInstruction, userPrompt);
            if (text != null && !text.isBlank()) {
                return new ProviderReply(text.trim(), aiProvider.name());
            }
        } catch (Exception ignored) {
            // Falls through to deterministic fallback to keep demo stable.
        }

        String fallback = fallbackProvider.generate(systemInstruction, userPrompt)
                + " " + fallbackSuffix;
        return new ProviderReply(fallback, fallbackProvider.name());
    }

    private List<String> buildSuggestions(List<String> missingSkills) {
        Map<String, String> templates = new HashMap<>();
        templates.put("machine learning", "Complete one intro ML project and document your model evaluation.");
        templates.put("object-oriented programming", "Refactor one feature using clear interfaces and unit tests.");
        templates.put("java", "Practice Java collections, exception handling, and file I/O with mini tasks.");
        templates.put("natural language processing", "Build a small text classification pipeline and compare baselines.");

        List<String> suggestions = new ArrayList<>();
        for (String skill : missingSkills) {
            String key = skill.toLowerCase(Locale.ROOT);
            String suggestion = templates.getOrDefault(
                    key,
                    "Add " + skill + " to your weekly plan with one practical assignment and evidence."
            );
            suggestions.add(skill + ": " + suggestion);
        }
        return suggestions;
    }

    private record ProviderReply(String text, String provider) {
    }

    public record MatchInsight(
            String applicantId,
            String jobId,
            int score,
            long workload,
            List<String> matchedSkills,
            List<String> missingSkills,
            String reasoning,
            String provider
    ) {
    }

    public record MissingSkillsInsight(
            String applicantId,
            String jobId,
            List<String> missingSkills,
            List<String> learningSuggestions,
            String summary,
            String provider
    ) {
    }

    public record HrCandidateInsight(
            String candidateUserId,
            String displayName,
            String role,
            String identifier,
            String email,
            String skills,
            String resumeText,
            String resumeSummary,
            int score,
            long workload,
            List<String> matchedSkills,
            List<String> missingSkills,
            String explanation,
            String provider
    ) {
    }

    public record WorkloadSuggestion(
            String jobId,
            List<CandidateSuggestion> candidates,
            String summary,
            String provider
    ) {
    }

    public record CandidateSuggestion(
            String applicantId,
            String displayName,
            int score,
            long currentWorkload,
            List<String> matchedSkills,
            List<String> missingSkills,
            String reason
    ) {
    }
}

package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.UserProfile;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@WebServlet(name = "MoCandidateDetailServlet", urlPatterns = "/mo/candidate-detail")
public class MoCandidateDetailServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_MO);
            String candidateUserId = Validators.requireNonBlank(request.getParameter("candidateUserId"), "candidateUserId");
            String jobId = Validators.requireNonBlank(request.getParameter("jobId"), "jobId");
            String applicationId = request.getParameter("applicationId");

            var job = appContext.jobService().findByJobId(jobId)
                    .orElseThrow(() -> new ApiException(404, "Job not found: " + jobId));
            if (!job.createdBy().equals(current.userId())) {
                throw new ApiException(403, "MO can only view candidates of own jobs");
            }

            ApplicationRecord application = resolveApplication(jobId, candidateUserId, applicationId);

            UserProfile candidate = appContext.userRepository().findById(candidateUserId)
                    .orElseThrow(() -> new ApiException(404, "Candidate not found: " + candidateUserId));

            Map<String, Object> candidateMap = new LinkedHashMap<>();
            candidateMap.put("userId", candidate.userId());
            candidateMap.put("displayName", candidate.displayName());
            candidateMap.put("identifier", candidate.identifier());
            candidateMap.put("email", candidate.email());
            candidateMap.put("skills", candidate.skills());
            candidateMap.put("resumeText", candidate.resumeText());
            candidateMap.put("updatedAt", candidate.updatedAt());

            Map<String, Object> applicationMap = new LinkedHashMap<>();
            applicationMap.put("applicationId", application.applicationId());
            applicationMap.put("status", application.status());
            applicationMap.put("submittedAt", application.submittedAt());
            applicationMap.put("jobId", application.jobId());
            applicationMap.put("attachments", appContext.attachmentService()
                    .listByApplicationId(application.applicationId())
                    .stream()
                    .map(item -> {
                        Map<String, Object> brief = new LinkedHashMap<>();
                        brief.put("attachmentId", item.attachmentId());
                        brief.put("attachmentType", item.attachmentType());
                        brief.put("originalFilename", item.originalFilename());
                        brief.put("sizeBytes", item.sizeBytes());
                        brief.put("uploadedAt", item.uploadedAt());
                        brief.put("hasExtractedText", item.extractedText() != null && !item.extractedText().isBlank());
                        return brief;
                    })
                    .toList());

            Map<String, Object> jobMap = new LinkedHashMap<>();
            jobMap.put("jobId", job.jobId());
            jobMap.put("title", job.title());
            jobMap.put("moduleCode", job.moduleCode());
            jobMap.put("requiredSkills", job.requiredSkills());
            jobMap.put("slots", job.slots());
            jobMap.put("status", job.status());

            writeJson(response, 200, Map.of(
                    "candidate", candidateMap,
                    "application", applicationMap,
                    "job", jobMap
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    private ApplicationRecord resolveApplication(String jobId, String candidateUserId, String applicationId) {
        if (applicationId != null && !applicationId.isBlank()) {
            Optional<ApplicationRecord> selected = appContext.applicationService().findByApplicationId(applicationId.trim());
            if (selected.isEmpty()) {
                throw new ApiException(404, "Application not found: " + applicationId);
            }
            ApplicationRecord record = selected.get();
            if (!record.jobId().equals(jobId) || !record.applicantId().equals(candidateUserId)) {
                throw new ApiException(404, "Application does not match candidate/job");
            }
            return record;
        }

        List<ApplicationRecord> candidates = appContext.applicationService().listCandidatesByJob(jobId, 1, 5000);
        return candidates.stream()
                .filter(item -> candidateUserId.equals(item.applicantId()))
                .max((a, b) -> Long.compare(parseEpoch(a.submittedAt()), parseEpoch(b.submittedAt())))
                .orElseThrow(() -> new ApiException(404, "Candidate has not applied to this job"));
    }

    private static long parseEpoch(String value) {
        if (value == null || value.isBlank()) {
            return 0L;
        }
        try {
            return OffsetDateTime.parse(value).toInstant().toEpochMilli();
        } catch (Exception ignored) {
            return 0L;
        }
    }
}

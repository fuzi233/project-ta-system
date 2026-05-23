package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.service.AiService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "MoCandidateAssessmentServlet", urlPatterns = "/mo/candidate-assessment")
public class MoCandidateAssessmentServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_MO);
            AssessmentRequest payload = readJson(request, AssessmentRequest.class);
            String candidateUserId = Validators.requireNonBlank(payload.candidateUserId(), "candidateUserId");
            String jobId = Validators.requireNonBlank(payload.jobId(), "jobId");

            var job = appContext.jobService().findByJobId(jobId)
                    .orElseThrow(() -> new ApiException(404, "Job not found: " + jobId));
            if (!job.createdBy().equals(current.userId())) {
                throw new ApiException(403, "MO can only assess candidates of own jobs");
            }

            boolean applied = appContext.applicationService()
                    .listCandidatesByJob(jobId, 1, 5000)
                    .stream()
                    .anyMatch(item -> candidateUserId.equals(item.applicantId()));
            if (!applied) {
                throw new ApiException(404, "Candidate has not applied to this job");
            }

            AiService.HrCandidateInsight insight = appContext.aiService().hrAssessCandidate(candidateUserId, jobId);
            writeJson(response, 200, Map.of("insight", insight));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record AssessmentRequest(String candidateUserId, String jobId) {
    }
}

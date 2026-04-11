package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.service.AiService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AiHrAssessmentServlet", urlPatterns = "/ai/hr-assessment")
public class AiHrAssessmentServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            requireRole(request, AuthSession.ROLE_ADMIN);
            HrAssessmentRequest payload = readJson(request, HrAssessmentRequest.class);
            AiService.HrCandidateInsight insight = appContext.aiService().hrAssessCandidate(
                    payload.candidateUserId(),
                    payload.jobId()
            );
            writeJson(response, 200, Map.of("insight", insight));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record HrAssessmentRequest(String candidateUserId, String jobId) {
    }
}

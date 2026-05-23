package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.service.AiService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AiMatchServlet", urlPatterns = "/ai/match")
public class AiMatchServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireAnyRole(request, AuthSession.ROLE_TA, AuthSession.ROLE_MO, AuthSession.ROLE_ADMIN);
            MatchRequest payload = readJson(request, MatchRequest.class);
            if (AuthSession.ROLE_TA.equalsIgnoreCase(current.role())
                    && !current.userId().equals(payload.applicantId())) {
                throw new ApiException(403, "TA can only analyze self profile");
            }
            AiService.MatchInsight insight = appContext.aiService().match(payload.applicantId(), payload.jobId());
            writeJson(response, 200, Map.of(
                    "applicantId", insight.applicantId(),
                    "jobId", insight.jobId(),
                    "score", insight.score(),
                    "workload", insight.workload(),
                    "matchedSkills", insight.matchedSkills(),
                    "missingSkills", insight.missingSkills(),
                    "reasoning", insight.reasoning(),
                    "provider", insight.provider()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record MatchRequest(String applicantId, String jobId) {
    }
}

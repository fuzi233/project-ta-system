package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.service.AiService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AiMissingSkillsServlet", urlPatterns = "/ai/missing-skills")
public class AiMissingSkillsServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            MissingRequest payload = readJson(request, MissingRequest.class);
            AiService.MissingSkillsInsight insight = appContext.aiService().missingSkills(payload.applicantId(), payload.jobId());
            writeJson(response, 200, Map.of(
                    "applicantId", insight.applicantId(),
                    "jobId", insight.jobId(),
                    "missingSkills", insight.missingSkills(),
                    "learningSuggestions", insight.learningSuggestions(),
                    "summary", insight.summary(),
                    "provider", insight.provider()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record MissingRequest(String applicantId, String jobId) {
    }
}

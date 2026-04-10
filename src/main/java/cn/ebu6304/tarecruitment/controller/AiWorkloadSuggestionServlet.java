package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.service.AiService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AiWorkloadSuggestionServlet", urlPatterns = "/ai/workload-suggestion")
public class AiWorkloadSuggestionServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String jobId = Validators.requireNonBlank(request.getParameter("jobId"), "jobId");
            int limit = readIntParameter(request, "limit", 5);
            AiService.WorkloadSuggestion suggestion = appContext.aiService().workloadSuggestion(jobId, limit);
            writeJson(response, 200, Map.of(
                    "jobId", suggestion.jobId(),
                    "candidates", suggestion.candidates(),
                    "summary", suggestion.summary(),
                    "provider", suggestion.provider()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }
}

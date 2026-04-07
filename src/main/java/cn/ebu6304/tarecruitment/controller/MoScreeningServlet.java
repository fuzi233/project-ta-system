package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MoScreeningServlet", urlPatterns = "/mo/candidates")
public class MoScreeningServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String jobId = request.getParameter("jobId");
            String status = request.getParameter("status");
            int page = readIntParameter(request, "page", 1);
            int size = readIntParameter(request, "size", 20);

            ApplicationService appService = appContext.applicationService();
            List<ApplicationRecord> candidates;

            if (jobId == null || jobId.isBlank()) {
                writeJson(response, 400, Map.of("error", "jobId is required"));
                return;
            }

            if (status != null && !status.isBlank()) {
                candidates = appService.listCandidatesByJobAndStatus(jobId, status, page, size);
            } else {
                candidates = appService.listCandidatesByJob(jobId, page, size);
            }

            writeJson(response, 200, Map.of(
                    "jobId", jobId,
                    "status", status != null ? status : "ALL",
                    "page", page,
                    "size", size,
                    "count", candidates.size(),
                    "candidates", candidates
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }
}

package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.model.JobPosting;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "JobServlet", urlPatterns = "/jobs")
public class JobServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String q = request.getParameter("q");
            String status = request.getParameter("status");
            int page = readIntParameter(request, "page", 1);
            int size = readIntParameter(request, "size", 10);

            List<JobPosting> jobs = appContext.jobService().listJobs(q, status, page, size);
            writeJson(response, 200, Map.of(
                    "page", page,
                    "size", size,
                    "items", jobs
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }
}

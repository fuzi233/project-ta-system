package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.service.WorkloadService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AdminWorkloadServlet", urlPatterns = "/admin/workload")
public class AdminWorkloadServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            long threshold = 3L;
            String value = request.getParameter("threshold");
            if (value != null && !value.isBlank()) {
                threshold = Long.parseLong(value.trim());
            }
            WorkloadService.WorkloadSnapshot snapshot = appContext.workloadService().snapshot(threshold);
            writeJson(response, 200, Map.of(
                    "totalApplications", snapshot.totalApplications(),
                    "byApplicant", snapshot.byApplicant(),
                    "overloaded", snapshot.overloaded(),
                    "threshold", threshold
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }
}

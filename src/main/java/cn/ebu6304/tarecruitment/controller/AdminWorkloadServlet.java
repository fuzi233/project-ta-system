package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ValidationException;
import cn.ebu6304.tarecruitment.service.WorkloadService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminWorkloadServlet", urlPatterns = "/admin/workload")
public class AdminWorkloadServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            requireRole(request, AuthSession.ROLE_ADMIN);
            int threshold = readIntParameter(request, "threshold", 3);
            if (threshold < 0) {
                throw new ValidationException("threshold must be >= 0");
            }

            boolean onlyOverloaded = Boolean.parseBoolean(request.getParameter("onlyOverloaded"));
            WorkloadService.WorkloadSnapshot snapshot = appContext.workloadService().snapshot(threshold);
            List<WorkloadService.WorkloadEntry> entries = onlyOverloaded
                    ? snapshot.entries().stream().filter(WorkloadService.WorkloadEntry::overloaded).toList()
                    : snapshot.entries();

            writeJson(response, 200, Map.of(
                    "totalApplications", snapshot.totalApplications(),
                    "totalApplicants", snapshot.entries().size(),
                    "byApplicant", snapshot.byApplicant(),
                    "overloaded", snapshot.overloaded(),
                    "overloadedCount", snapshot.overloaded().size(),
                    "threshold", snapshot.threshold(),
                    "onlyOverloaded", onlyOverloaded,
                    "entries", entries
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }
}

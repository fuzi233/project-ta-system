package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ValidationException;
import cn.ebu6304.tarecruitment.service.WorkloadService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
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
            List<Map<String, Object>> displayEntries = entries.stream()
                    .map(entry -> {
                        Map<String, Object> row = new LinkedHashMap<>();
                        row.put("applicantId", entry.applicantId());
                        row.put("applicantName", appContext.userRepository()
                                .findById(entry.applicantId())
                                .map(user -> user.displayName())
                                .filter(name -> name != null && !name.isBlank())
                                .orElse(entry.applicantId()));
                        row.put("totalApplications", entry.totalApplications());
                        row.put("activeApplications", entry.activeApplications());
                        row.put("overloaded", entry.overloaded());
                        row.put("overloadBy", entry.overloadBy());
                        row.put("statusBreakdown", entry.statusBreakdown());
                        return row;
                    })
                    .toList();

            writeJson(response, 200, Map.of(
                    "totalApplications", snapshot.totalApplications(),
                    "totalApplicants", snapshot.entries().size(),
                    "byApplicant", snapshot.byApplicant(),
                    "overloaded", snapshot.overloaded(),
                    "overloadedCount", snapshot.overloaded().size(),
                    "threshold", snapshot.threshold(),
                    "onlyOverloaded", onlyOverloaded,
                    "entries", displayEntries
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }
}

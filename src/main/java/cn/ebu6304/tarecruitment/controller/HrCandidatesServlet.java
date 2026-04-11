package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.model.UserProfile;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "HrCandidatesServlet", urlPatterns = "/hr/candidates")
public class HrCandidatesServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            requireRole(request, AuthSession.ROLE_ADMIN);

            String candidateUserId = request.getParameter("candidateUserId");
            if (candidateUserId != null && !candidateUserId.isBlank()) {
                String normalizedUserId = Validators.requireNonBlank(candidateUserId, "candidateUserId");
                UserProfile user = appContext.userRepository().findById(normalizedUserId)
                        .orElseThrow(() -> new ApiException(404, "Candidate not found: " + normalizedUserId));

                long workload = appContext.workloadService().snapshot(999).byApplicant().getOrDefault(user.userId(), 0L);
                writeJson(response, 200, Map.of(
                        "candidate", toCandidateDetail(user, workload)
                ));
                return;
            }

            List<Map<String, Object>> items = appContext.userRepository().listByRole("TA").stream()
                    .map(user -> {
                        long workload = appContext.workloadService().snapshot(999).byApplicant().getOrDefault(user.userId(), 0L);
                        return toCandidateSummary(user, workload);
                    })
                    .collect(Collectors.toList());

            writeJson(response, 200, Map.of("items", items, "count", items.size()));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    private Map<String, Object> toCandidateSummary(UserProfile user, long workload) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("candidateUserId", user.userId());
        item.put("displayName", user.displayName());
        item.put("identifier", user.identifier());
        item.put("email", user.email());
        item.put("skills", user.skills());
        item.put("workload", workload);
        return item;
    }

    private Map<String, Object> toCandidateDetail(UserProfile user, long workload) {
        Map<String, Object> item = toCandidateSummary(user, workload);
        item.put("role", user.role());
        item.put("resumeText", user.resumeText());
        item.put("updatedAt", user.updatedAt());
        return item;
    }
}

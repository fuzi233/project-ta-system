package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "MoScreeningServlet", urlPatterns = "/mo/candidates")
public class MoScreeningServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_MO);
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

            var ownedJob = appContext.jobService().findByJobId(jobId)
                    .orElseThrow(() -> new ApiException(404, "jobId not found"));
            if (!ownedJob.createdBy().equals(current.userId())) {
                throw new ApiException(403, "MO can only manage jobs created by self");
            }

            if (status != null && !status.isBlank()) {
                candidates = appService.listCandidatesByJobAndStatus(jobId, status, page, size);
            } else {
                candidates = appService.listCandidatesByJob(jobId, page, size);
            }

            List<Map<String, Object>> detailedCandidates = candidates.stream()
                    .map(item -> {
                        Map<String, Object> row = new LinkedHashMap<>();
                        row.put("applicationId", item.applicationId());
                        row.put("applicantId", item.applicantId());
                        row.put("jobId", item.jobId());
                        row.put("status", item.status());
                        row.put("submittedAt", item.submittedAt());
                        List<Map<String, Object>> attachments = appContext.attachmentService()
                                .listByApplicationId(item.applicationId())
                                .stream()
                                .map(attachment -> {
                                    Map<String, Object> brief = new LinkedHashMap<>();
                                    brief.put("attachmentId", attachment.attachmentId());
                                    brief.put("attachmentType", attachment.attachmentType());
                                    brief.put("originalFilename", attachment.originalFilename());
                                    brief.put("sizeBytes", attachment.sizeBytes());
                                    brief.put("uploadedAt", attachment.uploadedAt());
                                    brief.put("hasExtractedText", attachment.extractedText() != null && !attachment.extractedText().isBlank());
                                    return brief;
                                })
                                .toList();
                        row.put("attachments", attachments);
                        appContext.userRepository().findById(item.applicantId()).ifPresent(user -> {
                            row.put("displayName", user.displayName());
                            row.put("identifier", user.identifier());
                            row.put("email", user.email());
                            row.put("skills", user.skills());
                            row.put("resumeText", user.resumeText());
                            row.put("profileUpdatedAt", user.updatedAt());
                        });
                        return row;
                    })
                    .toList();

            writeJson(response, 200, Map.of(
                    "jobId", jobId,
                    "owner", current.userId(),
                    "status", status != null ? status : "ALL",
                    "page", page,
                    "size", size,
                    "count", detailedCandidates.size(),
                    "candidates", detailedCandidates
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }
}

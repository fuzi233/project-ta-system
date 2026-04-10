package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "MoStatusUpdateServlet", urlPatterns = "/mo/applications")
public class MoStatusUpdateServlet extends BaseServlet {
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
        SessionUser current = requireRole(request, AuthSession.ROLE_MO);
            UpdateStatusRequest payload = readJson(request, UpdateStatusRequest.class);
            ApplicationService appService = appContext.applicationService();

        var application = appService.findByApplicationId(payload.applicationId())
            .orElseThrow(() -> new ApiException(404, "Application not found"));
        var job = appContext.jobService().findByJobId(application.jobId())
            .orElseThrow(() -> new ApiException(404, "Job not found for application"));
        if (!job.createdBy().equals(current.userId())) {
        throw new ApiException(403, "MO can only manage applications for own jobs");
        }
            
            ApplicationService.UpdateStatusResponse updateResponse = appService.updateStatus(
                    payload.applicationId(),
                    payload.status()
            );
            
            writeJson(response, 200, Map.of(
                    "updated", updateResponse.updated(),
                    "record", updateResponse.record()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record UpdateStatusRequest(
            String applicationId,
            String status
    ) {
    }
}

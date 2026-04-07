package cn.ebu6304.tarecruitment.controller;

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
            UpdateStatusRequest payload = readJson(request, UpdateStatusRequest.class);
            ApplicationService appService = appContext.applicationService();
            
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

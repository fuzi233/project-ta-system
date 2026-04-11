package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ApplicationServlet", urlPatterns = "/applications")
public class ApplicationServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_TA);
            SubmitApplicationRequest payload = readJson(request, SubmitApplicationRequest.class);
            ApplicationService.SubmitResponse submitResponse = appContext.applicationService().submitApplication(
                    payload.applicationId(),
                    current.userId(),
                    payload.jobId()
            );
            int status = submitResponse.created() ? 201 : 200;
            writeJson(response, status, Map.of(
                    "created", submitResponse.created(),
                    "record", submitResponse.record()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_TA);
            int page = readIntParameter(request, "page", 1);
            int size = readIntParameter(request, "size", 10);
            List<ApplicationRecord> items = appContext.applicationService().queryByApplicant(current.userId(), page, size);
            writeJson(response, 200, Map.of(
                    "applicantId", current.userId(),
                    "page", page,
                    "size", size,
                    "count", items.size(),
                    "items", items
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record SubmitApplicationRequest(String applicationId, String applicantId, String jobId) {
    }
}

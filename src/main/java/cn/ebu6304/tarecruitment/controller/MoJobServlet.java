package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.service.JobService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "MoJobServlet", urlPatterns = "/mo/jobs")
public class MoJobServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireRole(request, AuthSession.ROLE_MO);
            CreateJobRequest payload = readJson(request, CreateJobRequest.class);
            JobService.CreateJobResponse createJobResponse = appContext.jobService().createJob(
                    payload.jobId(),
                    payload.title(),
                    payload.moduleCode(),
                    payload.requiredSkills(),
                    payload.slots(),
                    current.userId()
            );
            int status = createJobResponse.created() ? 201 : 200;
            writeJson(response, status, Map.of(
                    "created", createJobResponse.created(),
                    "record", createJobResponse.record()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record CreateJobRequest(
            String jobId,
            String title,
            String moduleCode,
            String requiredSkills,
            int slots,
            String createdBy
    ) {
    }
}

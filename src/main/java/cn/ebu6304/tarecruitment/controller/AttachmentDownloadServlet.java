package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.AttachmentRecord;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "AttachmentDownloadServlet", urlPatterns = "/attachments/download")
public class AttachmentDownloadServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireAnyRole(request, AuthSession.ROLE_TA, AuthSession.ROLE_MO, AuthSession.ROLE_ADMIN);
            String attachmentId = Validators.requireNonBlank(request.getParameter("attachmentId"), "attachmentId");

            AttachmentRecord record = appContext.attachmentService().findByAttachmentId(attachmentId)
                    .orElseThrow(() -> new ApiException(404, "Attachment not found: " + attachmentId));

            authorize(current, record);

            byte[] bytes = appContext.attachmentService().readFileBytes(record);
            String contentType = record.contentType() == null || record.contentType().isBlank()
                    ? "application/octet-stream"
                    : record.contentType();

            response.setStatus(200);
            response.setContentType(contentType);
            response.setHeader(
                    "Content-Disposition",
                    "inline; filename=\"" + safeHeaderFilename(record.originalFilename()) + "\""
            );
            response.getOutputStream().write(bytes);
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    private void authorize(SessionUser current, AttachmentRecord record) {
        if (AuthSession.ROLE_ADMIN.equalsIgnoreCase(current.role())) {
            return;
        }
        if (AuthSession.ROLE_TA.equalsIgnoreCase(current.role())) {
            if (!record.applicantId().equals(current.userId())) {
                throw new ApiException(403, "TA can only access own attachments");
            }
            return;
        }
        if (AuthSession.ROLE_MO.equalsIgnoreCase(current.role())) {
            var job = appContext.jobService().findByJobId(record.jobId())
                    .orElseThrow(() -> new ApiException(404, "Job not found for attachment"));
            if (!job.createdBy().equals(current.userId())) {
                throw new ApiException(403, "MO can only access attachments for own jobs");
            }
            return;
        }
        throw new ApiException(403, "Insufficient permissions");
    }

    private String safeHeaderFilename(String input) {
        if (input == null || input.isBlank()) {
            return "attachment.bin";
        }
        return input.replaceAll("[\\r\\n\\\"]", "_");
    }
}

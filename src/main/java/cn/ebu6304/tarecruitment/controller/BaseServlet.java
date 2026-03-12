package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.bootstrap.AppContext;
import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.ValidationException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

public abstract class BaseServlet extends HttpServlet {
    protected final AppContext appContext = AppContext.getInstance();
    protected final ObjectMapper objectMapper = appContext.objectMapper();

    protected <T> T readJson(HttpServletRequest request, Class<T> type) throws IOException {
        return objectMapper.readValue(request.getInputStream(), type);
    }

    protected void writeJson(HttpServletResponse response, int status, Object payload) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        objectMapper.writeValue(response.getOutputStream(), payload);
    }

    protected int readIntParameter(HttpServletRequest request, String key, int defaultValue) {
        String raw = request.getParameter(key);
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            throw new ValidationException(key + " must be an integer");
        }
    }

    protected void handleError(HttpServletResponse response, Exception error) throws IOException {
        if (error instanceof ValidationException validationException) {
            writeJson(response, 400, Map.of("error", validationException.getMessage()));
            return;
        }
        if (error instanceof ApiException apiException) {
            writeJson(response, apiException.getHttpStatus(), Map.of("error", apiException.getMessage()));
            return;
        }
        writeJson(response, 500, Map.of("error", "Internal server error", "detail", error.getMessage()));
    }
}

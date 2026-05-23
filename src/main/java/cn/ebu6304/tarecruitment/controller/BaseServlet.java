package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.bootstrap.AppContext;
import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.ValidationException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

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

    protected SessionUser requireAuthenticated(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            throw new ApiException(401, "Not authenticated");
        }
        String userId = (String) session.getAttribute(AuthSession.ATTR_USER_ID);
        String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
        String displayName = (String) session.getAttribute(AuthSession.ATTR_DISPLAY_NAME);
        String identifier = (String) session.getAttribute(AuthSession.ATTR_IDENTIFIER);
        if (userId == null || role == null) {
            throw new ApiException(401, "Not authenticated");
        }
        return new SessionUser(userId, role, displayName, identifier);
    }

    protected SessionUser requireRole(HttpServletRequest request, String role) {
        SessionUser user = requireAuthenticated(request);
        if (!role.equalsIgnoreCase(user.role())) {
            throw new ApiException(403, "Insufficient permissions for this operation");
        }
        return user;
    }

    protected SessionUser requireAnyRole(HttpServletRequest request, String... roles) {
        SessionUser user = requireAuthenticated(request);
        if (roles == null || roles.length == 0) {
            return user;
        }
        Set<String> allowed = new HashSet<>();
        Arrays.stream(roles)
                .filter(item -> item != null && !item.isBlank())
                .forEach(item -> allowed.add(item.trim().toUpperCase()));
        if (!allowed.contains(user.role().toUpperCase())) {
            throw new ApiException(403, "Insufficient permissions for this operation");
        }
        return user;
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

    protected record SessionUser(String userId, String role, String displayName, String identifier) {
    }
}

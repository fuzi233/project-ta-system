package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.AuthValidators;
import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Passwords;
import cn.ebu6304.tarecruitment.common.Validators;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

@WebServlet(name = "AuthLoginServlet", urlPatterns = "/auth/login")
public class AuthLoginServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            LoginRequest payload = readJson(request, LoginRequest.class);

        String role = AuthValidators.normalizeRole(payload.role());
            String identifier = Validators.requireNonBlank(payload.identifier(), "identifier").trim();
            String password = Validators.requireNonBlank(payload.password(), "password").trim();

        AuthValidators.validateIdentifierByRole(role, identifier);

            var account = appContext.userRepository().findByRoleAndLoginKey(role, identifier)
            .filter(item -> Passwords.sha256(password).equals(item.passwordHash()))
                    .orElseThrow(() -> new ApiException(401, "Invalid credentials for selected role"));

            HttpSession session = request.getSession(true);
            session.setMaxInactiveInterval(30 * 60);
        session.setAttribute(AuthSession.ATTR_USER_ID, account.userId());
        session.setAttribute(AuthSession.ATTR_ROLE, account.role());
        session.setAttribute(AuthSession.ATTR_DISPLAY_NAME, account.displayName());
            session.setAttribute(AuthSession.ATTR_IDENTIFIER, identifier);

            writeJson(response, 200, Map.of(
                    "message", "Login successful",
            "userId", account.userId(),
            "displayName", account.displayName(),
            "role", account.role(),
            "redirect", resolveLandingPage(account.role())
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    private static String resolveLandingPage(String role) {
        if (AuthSession.ROLE_TA.equals(role)) {
            return "jobs.jsp";
        }
        if (AuthSession.ROLE_MO.equals(role)) {
            return "mo.jsp";
        }
        return "admin.jsp";
    }

    public record LoginRequest(String role, String identifier, String password) {
    }
}
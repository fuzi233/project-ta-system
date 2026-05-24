package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.common.AuthValidators;
import cn.ebu6304.tarecruitment.common.ApiException;
import cn.ebu6304.tarecruitment.common.Passwords;
import cn.ebu6304.tarecruitment.common.Validators;
import cn.ebu6304.tarecruitment.model.UserProfile;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "AuthRegisterServlet", urlPatterns = "/auth/register")
public class AuthRegisterServlet extends BaseServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            RegisterRequest payload = readJson(request, RegisterRequest.class);

            String role = AuthValidators.normalizeRole(payload.role());
            String displayName = Validators.requireNonBlank(payload.name(), "name").trim();
            String email = Validators.requireNonBlank(payload.email(), "email").trim().toLowerCase(Locale.ROOT);
            String identifier = Validators.requireNonBlank(payload.identifier(), "identifier").trim();
            String password = Validators.requireNonBlank(payload.password(), "password").trim();

            if (!AuthSession.ROLE_TA.equals(role)) {
                throw new ApiException(403, "Only TA self-registration is available. MO and HR accounts are created internally.");
            }
            if (!AuthValidators.isEmail(email)) {
                throw new ApiException(400, "Invalid email format");
            }
            if (!AuthValidators.isBuptEmail(email)) {
                throw new ApiException(400, "TA registration email must end with @bupt.edu.cn");
            }
            AuthValidators.validateIdentifierByRole(role, identifier);
            if (password.length() < 8) {
                throw new ApiException(400, "Password must be at least 8 characters");
            }

            if (appContext.userRepository().existsByRoleAndIdentifier(role, identifier)) {
                throw new ApiException(409, "Credential identifier already exists for this role");
            }
            if (appContext.userRepository().existsByEmail(email)) {
                throw new ApiException(409, "Email already registered");
            }

            String userId = role.toLowerCase(Locale.ROOT) + "-" + UUID.randomUUID().toString().substring(0, 8);
            UserProfile profile = new UserProfile(
                    userId,
                    displayName,
                    role,
                    identifier,
                    email,
                    Passwords.sha256(password),
                    "",
                    "",
                    OffsetDateTime.now().toString()
            );
            appContext.userRepository().upsert(profile);

            writeJson(response, 201, Map.of(
                    "message", "Register successful",
                    "userId", profile.userId(),
                    "role", profile.role()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    public record RegisterRequest(String name, String role, String identifier, String email, String password) {
    }
}

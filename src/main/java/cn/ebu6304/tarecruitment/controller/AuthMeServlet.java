package cn.ebu6304.tarecruitment.controller;

import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.common.AuthValidators;
import cn.ebu6304.tarecruitment.common.ApiException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.Locale;
import java.util.Map;

@WebServlet(name = "AuthMeServlet", urlPatterns = "/auth/me")
public class AuthMeServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireAuthenticated(request);
            UserProfile profile = appContext.userRepository().findById(current.userId())
                    .orElseThrow(() -> new IllegalStateException("Current user profile not found"));
            writeJson(response, 200, Map.of(
                    "userId", profile.userId(),
                    "role", profile.role(),
                    "displayName", profile.displayName(),
                    "identifier", profile.identifier(),
                    "email", profile.email(),
                    "skills", profile.skills() == null ? "" : profile.skills(),
                    "resumeText", profile.resumeText() == null ? "" : profile.resumeText()
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            SessionUser current = requireAuthenticated(request);
            UpdateProfileRequest payload = readJson(request, UpdateProfileRequest.class);
            UserProfile existing = appContext.userRepository().findById(current.userId())
                    .orElseThrow(() -> new IllegalStateException("Current user profile not found"));

            String displayName = normalize(payload.displayName(), existing.displayName());
            String email = normalize(payload.email(), existing.email()).toLowerCase(Locale.ROOT);
            String skills = normalize(payload.skills(), existing.skills());
            String resumeText = normalize(payload.resumeText(), existing.resumeText());

            if (displayName.isBlank()) {
                throw new ApiException(400, "Display name is required");
            }
            if (!AuthValidators.isEmail(email)) {
                throw new ApiException(400, "Invalid email format");
            }
            boolean emailBelongsToOtherUser = appContext.userRepository().listAll().stream()
                    .anyMatch(user -> !user.userId().equals(existing.userId())
                            && user.email() != null
                            && user.email().equalsIgnoreCase(email));
            if (emailBelongsToOtherUser) {
                throw new ApiException(409, "Email already registered");
            }

            UserProfile updated = new UserProfile(
                    existing.userId(),
                    displayName,
                    existing.role(),
                    existing.identifier(),
                    email,
                    existing.passwordHash(),
                    skills,
                    resumeText,
                    OffsetDateTime.now().toString()
            );
            appContext.userRepository().upsert(updated);
            request.getSession().setAttribute(AuthSession.ATTR_DISPLAY_NAME, updated.displayName());
            writeJson(response, 200, Map.of(
                    "message", "Profile updated",
                    "profile", Map.of(
                            "userId", updated.userId(),
                            "role", updated.role(),
                            "displayName", updated.displayName(),
                            "identifier", updated.identifier(),
                            "email", updated.email(),
                            "skills", updated.skills() == null ? "" : updated.skills(),
                            "resumeText", updated.resumeText() == null ? "" : updated.resumeText()
                    )
            ));
        } catch (Exception e) {
            handleError(response, e);
        }
    }

    private static String normalize(String preferred, String fallback) {
        if (preferred != null) {
            return preferred.trim();
        }
        return fallback == null ? "" : fallback.trim();
    }

    public record UpdateProfileRequest(String displayName, String email, String skills, String resumeText) {
    }
}

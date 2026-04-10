package cn.ebu6304.tarecruitment.common;

import cn.ebu6304.tarecruitment.controller.AuthSession;

import java.util.Locale;

public final class AuthValidators {
    private AuthValidators() {
    }

    public static String normalizeRole(String role) {
        String normalized = Validators.requireNonBlank(role, "role").trim().toUpperCase(Locale.ROOT);
        if (!AuthSession.ROLE_TA.equals(normalized)
                && !AuthSession.ROLE_MO.equals(normalized)
                && !AuthSession.ROLE_ADMIN.equals(normalized)) {
            throw new ApiException(400, "Unsupported role");
        }
        return normalized;
    }

    public static void validateIdentifierByRole(String role, String identifier) {
        boolean valid;
        switch (role) {
            case AuthSession.ROLE_TA -> valid = identifier.matches("^[0-9]{10}$") || isEmail(identifier);
            case AuthSession.ROLE_MO -> valid = identifier.matches("^[A-Za-z]{3}[0-9]{4}$") || isEmail(identifier);
            case AuthSession.ROLE_ADMIN -> valid = identifier.matches("^[A-Za-z][A-Za-z0-9_]{2,}$");
            default -> throw new ApiException(400, "Unsupported role");
        }
        if (!valid) {
            throw new ApiException(400, "Identifier format does not match selected role");
        }
    }

    public static boolean isEmail(String email) {
        return email != null && email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    }
}

package cn.ebu6304.tarecruitment.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class AuthSession {
    public static final String ATTR_USER_ID = "auth.userId";
    public static final String ATTR_ROLE = "auth.role";
    public static final String ATTR_DISPLAY_NAME = "auth.displayName";
    public static final String ATTR_IDENTIFIER = "auth.identifier";

    public static final String ROLE_TA = "TA";
    public static final String ROLE_MO = "MO";
    public static final String ROLE_ADMIN = "ADMIN";

    private AuthSession() {
    }

    public static String currentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (String) session.getAttribute(ATTR_USER_ID);
    }

    public static String currentRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (String) session.getAttribute(ATTR_ROLE);
    }
}
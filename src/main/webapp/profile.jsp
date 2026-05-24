<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String userId = (String) session.getAttribute(AuthSession.ATTR_USER_ID);
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (userId == null || role == null) {
        response.sendRedirect("index.jsp?login=1");
        return;
    }
    boolean isTa = AuthSession.ROLE_TA.equalsIgnoreCase(role);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>My Profile - TA Recruitment</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        :root {
            --text: #102039;
            --muted: #4c5e7a;
            --line: #d6e4ff;
            --primary: #1575ff;
            --accent: #00b7a5;
            --shadow: 0 24px 50px rgba(16, 32, 57, 0.15);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            background: radial-gradient(circle at 20% 15%, #ffffff 0%, #eef3ff 45%, #d9e8ff 100%);
            font-family: "SF Pro Text", "SF Pro Display", "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: var(--text);
        }

        .page {
            max-width: 1080px;
            margin: 40px auto;
            padding: 0 24px;
        }

        .shell {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid var(--line);
            border-radius: 24px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .topbar {
            height: 72px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 28px;
            border-bottom: 1px solid var(--line);
            background: rgba(255,255,255,0.96);
        }

        .brand {
            font-size: 1rem;
            font-weight: 700;
            color: #16315b;
        }

        .nav {
            display: flex;
            gap: 32px;
            align-items: center;
        }

        .nav a {
            text-decoration: none;
            color: var(--muted);
            font-size: .95rem;
            font-weight: 500;
            padding: 24px 0 20px;
            border-bottom: 3px solid transparent;
        }

        .nav a.active {
            color: #16315b;
            border-bottom-color: #1575ff;
        }

        .content {
            padding: 30px 34px 40px;
        }

        .breadcrumb {
            font-size: 15px;
            color: var(--muted);
            margin-bottom: 18px;
        }

        .breadcrumb a {
            color: var(--muted);
            text-decoration: none;
        }

        .title {
            margin: 0 0 18px;
            font-size: 40px;
            font-weight: 800;
            color: #0e3369;
        }

        .divider {
            height: 1px;
            background: var(--line);
            margin-bottom: 22px;
        }

        .profile-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        .field {
            margin-bottom: 16px;
        }

        .field label {
            display: block;
            margin-bottom: 7px;
            color: #16315b;
            font-weight: 700;
        }

        .input,
        .textarea {
            width: 100%;
            border: 1px solid #c2d6ff;
            border-radius: 12px;
            background: #fff;
            color: #16315b;
            font-size: 16px;
            padding: 12px 14px;
            font-family: inherit;
        }

        .textarea {
            min-height: 120px;
            resize: vertical;
        }

        .readonly {
            background: #f8fbff;
            color: #4c5e7a;
        }

        .panel {
            border: 1px solid var(--line);
            border-radius: 18px;
            background: #fff;
            padding: 20px;
        }

        .actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 18px;
        }

        .btn {
            min-width: 140px;
            height: 46px;
            border-radius: 12px;
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn.primary {
            border: 0;
            color: #fff;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
        }

        .message {
            display: none;
            margin-top: 14px;
            padding: 12px 14px;
            border-radius: 12px;
            border: 1px solid #bdd8f6;
            background: #eef6ff;
            color: #1f5f8b;
            font-weight: 700;
        }

        .message.error {
            border-color: #e8c4c4;
            background: #fff7f7;
            color: #9a4a4a;
        }

        @media (max-width: 760px) {
            .profile-grid { grid-template-columns: 1fr; }
            .topbar { height: auto; flex-direction: column; gap: 10px; padding: 18px; }
            .nav { flex-wrap: wrap; justify-content: center; gap: 16px; }
            .title { font-size: 32px; }
        }
    </style>
</head>
<body>
<div class="bg-orb orb-a"></div>
<div class="bg-orb orb-b"></div>
<div class="page">
    <div class="shell">
        <header class="topbar">
            <div class="brand">TA Recruitment System</div>
            <nav class="nav">
                <% if (isTa) { %>
                <a href="jobs.jsp">Job List</a>
                <a href="applications.jsp">My Applications</a>
                <a href="profile.jsp" class="active">Profile</a>
                <% } else { %>
                <a href="mo.jsp">MO Workspace</a>
                <a href="admin.jsp">HR Workspace</a>
                <a href="profile.jsp" class="active">Profile</a>
                <% } %>
                <a href="javascript:void(0)" onclick="signOut()">Sign Out</a>
            </nav>
        </header>

        <main class="content">
            <div class="breadcrumb">
                <a href="<%= isTa ? "jobs.jsp" : "index.jsp" %>">Back</a> &nbsp;›&nbsp; Profile
            </div>
            <h1 class="title">My Profile</h1>
            <div class="divider"></div>

            <form id="profileForm" class="panel">
                <div class="profile-grid">
                    <div class="field">
                        <label for="displayName">Display Name</label>
                        <input id="displayName" class="input" type="text" required>
                    </div>
                    <div class="field">
                        <label for="role">Role</label>
                        <input id="role" class="input readonly" type="text" readonly>
                    </div>
                    <div class="field">
                        <label for="identifier">Login Identifier</label>
                        <input id="identifier" class="input readonly" type="text" readonly>
                    </div>
                    <div class="field">
                        <label for="email">Email</label>
                        <input id="email" class="input" type="email" required>
                    </div>
                </div>
                <div class="field">
                    <label for="skills">Skills</label>
                    <input id="skills" class="input" type="text" placeholder="Java, SQL, HTML/CSS">
                </div>
                <div class="field">
                    <label for="resumeText">Resume / Experience Summary</label>
                    <textarea id="resumeText" class="textarea" placeholder="Briefly describe your TA-related experience."></textarea>
                </div>
                <div class="actions">
                    <button class="btn primary" type="submit">Save Profile</button>
                    <a class="btn" href="<%= isTa ? "jobs.jsp" : "index.jsp" %>">Back</a>
                </div>
                <div id="message" class="message"></div>
            </form>
        </main>
    </div>
</div>

<script>
    function isEmailValid(value) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(value || "").trim());
    }

    function showMessage(text, isError) {
        const message = document.getElementById("message");
        message.textContent = text;
        message.className = "message" + (isError ? " error" : "");
        message.style.display = "block";
    }

    async function api(url, options = {}) {
        const response = await fetch(url, {
            headers: {"Content-Type": "application/json"},
            ...options
        });
        const text = await response.text();
        const body = text ? JSON.parse(text) : {};
        if (!response.ok) {
            throw new Error(body.error || ("HTTP " + response.status));
        }
        return body;
    }

    async function loadProfile() {
        const profile = await api("/auth/me");
        document.getElementById("displayName").value = profile.displayName || "";
        document.getElementById("role").value = profile.role || "";
        document.getElementById("identifier").value = profile.identifier || "";
        document.getElementById("email").value = profile.email || "";
        document.getElementById("skills").value = profile.skills || "";
        document.getElementById("resumeText").value = profile.resumeText || "";
    }

    document.getElementById("profileForm").addEventListener("submit", async (event) => {
        event.preventDefault();
        const displayName = document.getElementById("displayName").value.trim();
        const email = document.getElementById("email").value.trim();
        if (!displayName) {
            showMessage("Display name is required.", true);
            return;
        }
        if (!isEmailValid(email)) {
            showMessage("Please enter a valid email address.", true);
            return;
        }
        try {
            await api("/auth/me", {
                method: "POST",
                body: JSON.stringify({
                    displayName,
                    email,
                    skills: document.getElementById("skills").value.trim(),
                    resumeText: document.getElementById("resumeText").value.trim()
                })
            });
            showMessage("Profile saved successfully.", false);
        } catch (error) {
            showMessage(error.message, true);
        }
    });

    async function signOut() {
        await fetch("auth/logout", {method: "POST"});
        window.location.href = "index.jsp?login=1";
    }

    loadProfile().catch(error => showMessage(error.message, true));
</script>
</body>
</html>

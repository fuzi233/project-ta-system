<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String userId = (String) session.getAttribute(AuthSession.ATTR_USER_ID);
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    String displayName = (String) session.getAttribute(AuthSession.ATTR_DISPLAY_NAME);
    String identifier = (String) session.getAttribute(AuthSession.ATTR_IDENTIFIER);
    if (userId == null || role == null) {
        String qs = request.getQueryString(); String target = request.getRequestURI().substring(request.getContextPath().length()) + (qs != null ? "?" + qs : ""); response.sendRedirect("index.jsp?redirect=" + java.net.URLEncoder.encode(target, "UTF-8"));
        return;
    }
    String roleUpper = role.toUpperCase();
    String workspaceLink = "index.jsp";
    String workspaceLabel = "Back to Home";
    if (AuthSession.ROLE_TA.equalsIgnoreCase(roleUpper)) {
        workspaceLink = "jobs.jsp";
        workspaceLabel = "Go to Job List";
    } else if (AuthSession.ROLE_MO.equalsIgnoreCase(roleUpper)) {
        workspaceLink = "mo.jsp";
        workspaceLabel = "Go to MO Workspace";
    } else if (AuthSession.ROLE_ADMIN.equalsIgnoreCase(roleUpper)) {
        workspaceLink = "admin.jsp";
        workspaceLabel = "Go to HR Workspace";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>My Profile - TA Recruitment</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        body {
            margin: 0;
            background: radial-gradient(circle at 20% 15%, #ffffff 0%, #eef3ff 45%, #d9e8ff 100%);
            font-family: "SF Pro Text", "SF Pro Display", "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            color: #102039;
        }

        .page {
            max-width: 960px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid #d6e4ff;
            border-radius: 20px;
            box-shadow: 0 24px 50px rgba(16, 32, 57, 0.15);
            padding: 28px;
        }

        .title {
            margin: 0 0 18px;
            font-size: clamp(1.9rem, 2.8vw, 2.5rem);
            color: #0e3369;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }

        .item {
            background: rgba(248, 251, 255, 0.92);
            border: 1px solid #d6e4ff;
            border-radius: 14px;
            padding: 14px 16px;
        }

        .item-label {
            font-size: .82rem;
            color: #4c5e7a;
            margin-bottom: 6px;
        }

        .item-value {
            font-size: .98rem;
            font-weight: 600;
            color: #16315b;
            word-break: break-all;
        }

        .actions {
            display: flex;
            gap: 12px;
            margin-top: 18px;
            flex-wrap: wrap;
        }

        .btn-link {
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 42px;
            padding: 0 16px;
            border-radius: 10px;
            border: 1px solid #c2d6ff;
            color: #16315b;
            background: rgba(255, 255, 255, 0.9);
            font-weight: 600;
        }

        .btn-link.primary {
            border: none;
            color: #fff;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
        }

        @media (max-width: 700px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="bg-orb orb-a"></div>
<div class="bg-orb orb-b"></div>
<div class="page">
    <section class="card">
        <h1 class="title">My Profile</h1>
        <div class="grid">
            <div class="item">
                <div class="item-label">Display Name</div>
                <div class="item-value"><%= displayName == null ? "-" : displayName %></div>
            </div>
            <div class="item">
                <div class="item-label">Role</div>
                <div class="item-value"><%= roleUpper %></div>
            </div>
            <div class="item">
                <div class="item-label">User ID</div>
                <div class="item-value"><%= userId %></div>
            </div>
            <div class="item">
                <div class="item-label">Login Identifier</div>
                <div class="item-value"><%= identifier == null ? "-" : identifier %></div>
            </div>
        </div>
        <div class="actions">
            <a class="btn-link primary" href="<%= workspaceLink %>"><%= workspaceLabel %></a>
            <a class="btn-link" href="index.jsp">Exit</a>
        </div>
    </section>
</div>
</body>
</html>

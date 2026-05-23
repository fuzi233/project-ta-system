<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String userId = (String) session.getAttribute(AuthSession.ATTR_USER_ID);
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    String displayName = (String) session.getAttribute(AuthSession.ATTR_DISPLAY_NAME);
    String identifier = (String) session.getAttribute(AuthSession.ATTR_IDENTIFIER);
    if (userId == null || role == null) {
        response.sendRedirect("index.jsp");
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
            background: linear-gradient(180deg, #edf2f7 0%, #e9eef5 100%);
            font-family: "Segoe UI", Arial, sans-serif;
            color: #1f2937;
        }

        .page {
            max-width: 960px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .card {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid #dbe3ec;
            border-radius: 20px;
            box-shadow: 0 10px 24px rgba(31, 41, 55, 0.08);
            padding: 28px;
        }

        .title {
            margin: 0 0 18px;
            font-size: 34px;
            color: #10213f;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }

        .item {
            background: #f8fbff;
            border: 1px solid #dde6f1;
            border-radius: 14px;
            padding: 14px 16px;
        }

        .item-label {
            font-size: 13px;
            color: #64748b;
            margin-bottom: 6px;
        }

        .item-value {
            font-size: 16px;
            font-weight: 600;
            color: #1e293b;
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
            border: 1px solid #cbd5e1;
            color: #334155;
            background: #fff;
            font-weight: 600;
        }

        .btn-link.primary {
            border: none;
            color: #fff;
            background: linear-gradient(135deg, #4c74dd 0%, #47b7ba 100%);
        }

        @media (max-width: 700px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
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
            <a class="btn-link" href="index.jsp">Back to Login</a>
        </div>
    </section>
</div>
</body>
</html>

<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_ADMIN.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruit - HR Workspace</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        .hr-grid {
            display: grid;
            grid-template-columns: 1.1fr 1fr;
            gap: 1rem;
        }

        .hr-stack {
            display: grid;
            gap: .8rem;
        }

        .hr-toolbar {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: .65rem;
        }

        .hr-side {
            display: flex;
            align-items: flex-start;
            gap: .8rem;
        }

        .hr-ai-btn {
            position: sticky;
            top: 1rem;
            min-width: 154px;
        }

        @media (max-width: 980px) {
            .hr-grid {
                grid-template-columns: 1fr;
            }
            .hr-toolbar {
                grid-template-columns: 1fr;
            }
            .hr-side {
                flex-direction: column;
            }
            .hr-ai-btn {
                position: static;
                width: 100%;
            }
        }
    </style>
</head>
<body>
<main class="shell">
    <a class="link" href="index.jsp">← Back to Login</a>

    <section class="glass card">
        <h1>HR Candidate Review Workspace</h1>
        <p class="subtitle">Select a candidate and job, then click AI to summarize CV and output match score with explanation.</p>
    </section>

    <section class="hr-grid">
        <div class="glass card hr-stack">
            <h2>Candidate & Job</h2>
            <div class="hr-toolbar">
                <select id="hr-candidate-select"></select>
                <select id="hr-job-select"></select>
            </div>
            <div class="hr-side">
                <pre id="hr-candidate-output" class="panel" style="flex:1">Loading candidate list...</pre>
                <button id="hr-ai-analyze-btn" class="btn hr-ai-btn" type="button">AI Analyze</button>
            </div>
        </div>

        <div class="glass card hr-stack">
            <h2>AI Decision Support</h2>
            <pre id="hr-ai-output" class="panel">No AI analysis yet.</pre>
        </div>
    </section>

    <section class="glass card">
        <h2>Workload Dashboard</h2>
        <form id="admin-form" class="inline-form">
            <input type="number" min="1" id="threshold" placeholder="threshold (default 3)"/>
            <button class="btn" type="submit">Refresh</button>
        </form>
        <pre id="admin-output" class="panel">No data loaded.</pre>
    </section>
</main>
<script src="assets/js/app.js"></script>
</body>
</html>

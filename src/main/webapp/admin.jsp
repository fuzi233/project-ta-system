<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

        .hr-detail-panel,
        .hr-ai-panel {
            min-height: 220px;
            white-space: normal;
        }

        .hr-detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: .75rem;
        }

        .hr-detail-item {
            border: 1px solid #d6e4ff;
            border-radius: 12px;
            background: rgba(255, 255, 255, .82);
            padding: .75rem .85rem;
        }

        .hr-detail-item.full {
            grid-column: 1 / -1;
        }

        .hr-detail-label {
            margin: 0 0 .28rem;
            font-size: .78rem;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            color: #58708f;
        }

        .hr-detail-value {
            color: #16315b;
            font-weight: 600;
            line-height: 1.5;
            word-break: break-word;
            white-space: pre-wrap;
        }

        .hr-ai-section + .hr-ai-section {
            margin-top: 1rem;
            padding-top: 1rem;
            border-top: 1px solid #dfe9fb;
        }

        .hr-ai-section h3 {
            margin: 0 0 .45rem;
            color: #12396a;
            font-size: 1rem;
        }

        .hr-ai-copy {
            margin: 0;
            color: #27486f;
            line-height: 1.6;
            white-space: pre-wrap;
        }

        .hr-ai-list {
            margin: .2rem 0 0;
            padding-left: 1.1rem;
            color: #27486f;
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
            .hr-detail-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="bg-orb orb-a"></div>
<div class="bg-orb orb-b"></div>
<main class="shell">
    <a class="link" href="javascript:void(0)" onclick="signOut()">Sign Out</a>

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
                <div id="hr-candidate-output" class="panel hr-detail-panel" style="flex:1">Loading candidate list...</div>
                <button id="hr-ai-analyze-btn" class="btn hr-ai-btn" type="button">AI Analyze</button>
            </div>
        </div>

        <div class="glass card hr-stack">
            <h2>AI Decision Support</h2>
            <div id="hr-ai-output" class="panel hr-ai-panel">No AI analysis yet.</div>
        </div>
    </section>

    <section class="glass card">
        <h2>Workload Dashboard</h2>
        <p class="subtitle">Monitor TA workload, filter by threshold, and identify overloaded applicants.</p>
        <form id="admin-form" class="inline-form">
            <input type="number" min="0" id="threshold" value="3" placeholder="threshold (default 3)"/>
            <label class="checkbox-line">
                <input type="checkbox" id="only-overloaded"/>
                <span>Show only overloaded</span>
            </label>
            <button class="btn" type="submit">Refresh</button>
        </form>
        <p id="admin-hint" class="hint">Loading workload data...</p>

        <div class="stats-grid">
            <article class="glass stat-card">
                <p class="stat-label">Applications</p>
                <p class="stat-value" id="stat-total-applications">-</p>
            </article>
            <article class="glass stat-card">
                <p class="stat-label">Applicants</p>
                <p class="stat-value" id="stat-total-applicants">-</p>
            </article>
            <article class="glass stat-card">
                <p class="stat-label">Overloaded</p>
                <p class="stat-value" id="stat-overloaded">-</p>
            </article>
        </div>

        <div class="table-wrap">
            <table class="admin-table">
                <thead>
                <tr>
                    <th>Applicant</th>
                    <th>Active Workload</th>
                    <th>Total Applications</th>
                    <th>Status Breakdown</th>
                    <th>Warning</th>
                </tr>
                </thead>
                <tbody id="admin-table-body">
                <tr>
                    <td colspan="5" class="empty-note">No data loaded.</td>
                </tr>
                </tbody>
            </table>
        </div>
    </section>
</main>
<script>
    async function signOut() {
        await fetch("auth/logout", {method: "POST"});
        window.location.href = "index.jsp?login=1";
    }
</script>
<script src="assets/js/app.js?v=5"></script>
</body>
</html>

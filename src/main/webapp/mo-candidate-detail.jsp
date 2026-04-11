<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_MO.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>MO Candidate Detail</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        .detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: .75rem;
        }

        .detail-item {
            border: 1px solid #d6e4ff;
            border-radius: 12px;
            background: rgba(255, 255, 255, .78);
            padding: .7rem .8rem;
        }

        .detail-label {
            font-size: .78rem;
            color: #4c5e7a;
            margin-bottom: .25rem;
            text-transform: uppercase;
            letter-spacing: .05em;
        }

        .detail-value {
            color: #153a68;
            font-weight: 600;
            word-break: break-word;
        }

        .ai-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: .75rem;
        }

        .ai-card {
            border: 1px solid #d6e4ff;
            border-radius: 12px;
            background: rgba(255, 255, 255, .78);
            padding: .8rem;
        }

        .ai-title {
            margin: 0 0 .45rem;
            color: #10325b;
            font-size: 1rem;
        }

        .ai-text {
            margin: 0;
            color: #1f3f66;
            line-height: 1.5;
            white-space: pre-wrap;
        }

        .chip {
            display: inline-flex;
            border-radius: 999px;
            padding: .22rem .56rem;
            font-size: .76rem;
            background: #e7f0ff;
            color: #1f4a84;
            margin: 0 .35rem .35rem 0;
        }

        @media (max-width: 900px) {
            .detail-grid,
            .ai-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<main class="shell narrow">
    <a class="link" href="mo.jsp">&larr; Back to MO Workspace</a>

    <section class="glass card">
        <h1>Candidate Detail</h1>
        <p class="subtitle">View profile and trigger AI one-click summary for this job application.</p>
    </section>

    <section class="glass card">
        <h2>Candidate + Application</h2>
        <div id="candidateDetailGrid" class="detail-grid">
            <div class="detail-item"><div class="detail-label">Name</div><div id="detailName" class="detail-value">-</div></div>
            <div class="detail-item"><div class="detail-label">User ID</div><div id="detailUserId" class="detail-value">-</div></div>
            <div class="detail-item"><div class="detail-label">Identifier</div><div id="detailIdentifier" class="detail-value">-</div></div>
            <div class="detail-item"><div class="detail-label">Email</div><div id="detailEmail" class="detail-value">-</div></div>
            <div class="detail-item"><div class="detail-label">Application Status</div><div id="detailStatus" class="detail-value">-</div></div>
            <div class="detail-item"><div class="detail-label">Submitted At</div><div id="detailSubmittedAt" class="detail-value">-</div></div>
            <div class="detail-item"><div class="detail-label">Job</div><div id="detailJob" class="detail-value">-</div></div>
            <div class="detail-item"><div class="detail-label">Module</div><div id="detailModule" class="detail-value">-</div></div>
        </div>
        <div style="margin-top:.75rem;">
            <div class="detail-label">Skills</div>
            <div id="detailSkills"></div>
        </div>
        <div style="margin-top:.75rem;">
            <div class="detail-label">Resume Text</div>
            <pre id="detailResume" class="panel">Loading candidate detail...</pre>
        </div>
        <div style="margin-top:.8rem; display:flex; gap:.6rem; flex-wrap:wrap;">
            <button id="aiAssessBtn" class="btn" type="button">AI One-click Summary</button>
            <span id="aiHint" class="hint"></span>
        </div>
    </section>

    <section class="glass card">
        <h2>AI Assessment</h2>
        <div class="ai-grid">
            <div class="ai-card">
                <h3 class="ai-title">Match Overview</h3>
                <p id="aiScore" class="ai-text">No AI result yet.</p>
                <p id="aiReasoning" class="ai-text"></p>
            </div>
            <div class="ai-card">
                <h3 class="ai-title">Missing Skills & Suggestions</h3>
                <div id="aiMissingSkills"></div>
                <p id="aiSuggestions" class="ai-text"></p>
            </div>
        </div>
    </section>
</main>
<script src="assets/js/mo-candidate-detail.js?v=2"></script>
</body>
</html>

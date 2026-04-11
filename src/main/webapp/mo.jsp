<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    String userId = (String) session.getAttribute(AuthSession.ATTR_USER_ID);
    if (role == null || !AuthSession.ROLE_MO.equalsIgnoreCase(role) || userId == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruit - MO Workspace</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        .mo-tabs {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: .7rem;
            margin: .8rem 0 1rem;
        }

        .mo-tab {
            min-height: 48px;
            border-radius: 14px;
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, .78);
            color: #1a355f;
            font-weight: 700;
            cursor: pointer;
        }

        .mo-tab.active {
            border: none;
            color: #fff;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
        }

        .mo-panel {
            display: none;
        }

        .mo-panel.active {
            display: block;
        }

        .review-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: .9rem;
        }

        .job-block {
            border: 1px solid #d6e4ff;
            border-radius: 14px;
            background: rgba(255, 255, 255, .74);
            overflow: hidden;
        }

        .job-head {
            display: flex;
            justify-content: space-between;
            gap: .8rem;
            padding: .8rem .9rem;
            background: rgba(234, 243, 255, 0.85);
            border-bottom: 1px solid #dfe9fb;
            align-items: center;
            flex-wrap: wrap;
        }

        .job-title {
            margin: 0;
            font-size: 1rem;
            color: #12396a;
        }

        .job-sub {
            margin: .2rem 0 0;
            font-size: .85rem;
            color: #496487;
        }

        .candidate-list {
            display: flex;
            flex-direction: column;
            gap: .55rem;
            padding: .75rem;
        }

        .candidate-row {
            border: 1px solid #e4edff;
            border-radius: 12px;
            padding: .65rem .7rem;
            display: grid;
            grid-template-columns: minmax(160px, 2fr) minmax(130px, 1fr) minmax(180px, 1.2fr) auto;
            gap: .65rem;
            align-items: center;
            background: rgba(255, 255, 255, .9);
        }

        .candidate-main {
            font-size: .92rem;
            color: #1a355f;
        }

        .candidate-actions {
            display: flex;
            gap: .45rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .candidate-actions .btn,
        .candidate-actions .btn.ghost {
            padding: .45rem .65rem;
            font-size: .84rem;
        }

        .mini-select {
            height: 36px;
            border-radius: 10px;
            border: 1px solid #c2d6ff;
            padding: 0 .55rem;
            min-width: 135px;
            background: rgba(255, 255, 255, .9);
        }

        .empty-inline {
            color: #4c5e7a;
            font-size: .9rem;
            padding: .35rem .1rem;
        }

        @media (max-width: 980px) {
            .candidate-row {
                grid-template-columns: 1fr;
            }
            .candidate-actions {
                justify-content: flex-start;
            }
        }
    </style>
</head>
<body data-mo-user-id="<%= userId %>">
<main class="shell">
    <a class="link" href="index.jsp">&larr; Home</a>

    <section class="glass hero">
        <p class="eyebrow">MO Workspace</p>
        <h1>Teaching Assistant Recruitment Console</h1>
        <p class="subtitle">Review applications by job first, then drill down to candidate detail and trigger AI summary in one click.</p>
    </section>

    <section class="glass card">
        <div class="mo-tabs">
            <button id="tabReview" class="mo-tab active" type="button">Job Applications Review</button>
            <button id="tabCreate" class="mo-tab" type="button">Create New Job</button>
        </div>

        <div id="panelReview" class="mo-panel active">
            <div style="display:flex; gap:.6rem; flex-wrap:wrap; margin-bottom:.75rem;">
                <button id="reviewRefreshBtn" class="btn ghost" type="button">Refresh Review Data</button>
                <select id="reviewJobSelect" class="mini-select">
                    <option value="">All Jobs</option>
                </select>
                <input id="reviewJobSearch" list="reviewJobOptions" type="text" placeholder="Search by jobId/title/module"/>
                <datalist id="reviewJobOptions"></datalist>
                <button id="reviewClearFilterBtn" class="btn ghost" type="button">Clear Filter</button>
                <div id="reviewHint" class="hint">Loading jobs and applications...</div>
            </div>
            <p class="hint" style="margin-top:-.25rem;">
                Note: each submission creates one application record; use Detail + AI to review the exact candidate snapshot and attachments.
            </p>
            <div id="reviewList" class="review-grid"></div>
        </div>

        <div id="panelCreate" class="mo-panel">
            <h2>Create New Job</h2>
            <form id="mo-job-form" class="stack-form">
                <input type="text" name="jobId" placeholder="jobId (e.g. job-101)" required/>
                <input type="text" name="title" placeholder="title" required/>
                <input type="text" name="moduleCode" placeholder="moduleCode" required/>
                <input type="text" name="requiredSkills" placeholder="requiredSkills (comma separated)" required/>
                <input type="number" name="slots" placeholder="slots" min="1" required/>
                <button class="btn" type="submit">Create Job</button>
            </form>
            <pre id="mo-output" class="panel"></pre>
        </div>
    </section>
</main>
<script src="assets/js/mo-page.js?v=5"></script>
</body>
</html>

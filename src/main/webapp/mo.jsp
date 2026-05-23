<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    String userId = (String) session.getAttribute(AuthSession.ATTR_USER_ID);
    if (role == null || !AuthSession.ROLE_MO.equalsIgnoreCase(role) || userId == null) {
        String qs = request.getQueryString(); String target = request.getRequestURI().substring(request.getContextPath().length()) + (qs != null ? "?" + qs : ""); response.sendRedirect("index.jsp?redirect=" + java.net.URLEncoder.encode(target, "UTF-8"));
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

        .review-toolbar {
            display: flex;
            gap: .6rem;
            flex-wrap: wrap;
            margin-bottom: .75rem;
        }

        .review-toolbar .mini-select,
        .review-toolbar input[type="text"] {
            width: 250px;
            height: auto;
            border-radius: 12px;
            padding: .78rem 1rem;
            font-size: inherit;
            font-weight: 600;
        }

        .job-block {
            border: 1px solid #d6e4ff;
            border-radius: 14px;
            background: rgba(255, 255, 255, .74);
            overflow: hidden;
        }

        .job-block.collapsed {
            background: rgba(247, 250, 255, .88);
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

        .job-head-main {
            display: flex;
            flex-direction: column;
            gap: .5rem;
            flex: 1 1 360px;
            min-width: 260px;
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

        .job-head-summary {
            display: flex;
            flex-wrap: wrap;
            gap: .45rem;
        }

        .job-stat {
            display: inline-flex;
            align-items: center;
            gap: .3rem;
            border-radius: 999px;
            padding: .28rem .65rem;
            font-size: .8rem;
            font-weight: 700;
            border: 1px solid #d3e4ff;
            color: #1a4e88;
            background: rgba(255, 255, 255, .88);
        }

        .job-stat.pending {
            color: #8a5400;
            background: rgba(255, 237, 204, .95);
            border-color: #ffd58a;
        }

        .job-stat.accepted {
            color: #0b6a46;
            background: rgba(219, 247, 234, .95);
            border-color: #9be2bf;
        }

        .job-stat.rejected {
            color: #8a2130;
            background: rgba(255, 226, 230, .95);
            border-color: #ffc0ca;
        }

        .job-head-actions {
            display: flex;
            align-items: center;
            gap: .5rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .job-focus {
            border-radius: 999px;
            padding: .28rem .65rem;
            font-size: .8rem;
            font-weight: 700;
            color: #0d5f78;
            background: rgba(204, 246, 255, .95);
            border: 1px solid #9adff2;
        }

        .job-toggle {
            min-height: 38px;
            padding: .45rem .85rem;
            font-size: .84rem;
        }

        .job-block.collapsed .candidate-list {
            display: none;
        }

        .match-note {
            color: #3e618e;
            font-size: .82rem;
            font-weight: 600;
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

        .create-help {
            margin: .25rem 0 .9rem;
            color: #58708f;
            font-size: .9rem;
        }

        .form-feedback {
            margin-top: .85rem;
            padding: .8rem .9rem;
            border-radius: 12px;
            font-size: .92rem;
            line-height: 1.5;
            border: 1px solid #d7e4ff;
            background: rgba(255, 255, 255, .82);
            color: #1b3f70;
            display: none;
        }

        .form-feedback.show {
            display: block;
        }

        .form-feedback.success {
            border-color: #9fe1c0;
            background: rgba(230, 250, 239, .96);
            color: #0f6543;
        }

        .form-feedback.error {
            border-color: #ffbec9;
            background: rgba(255, 236, 239, .96);
            color: #92233b;
        }

        .create-form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: .85rem;
        }

        .create-form-grid .full-span {
            grid-column: 1 / -1;
        }

        .field-label {
            display: block;
            margin: 0 0 .35rem;
            color: #264c7d;
            font-size: .88rem;
            font-weight: 700;
        }

        .skill-builder {
            padding: .9rem;
            border-radius: 14px;
            border: 1px solid #d7e4ff;
            background: rgba(249, 252, 255, .92);
        }

        .skill-builder-top {
            display: grid;
            grid-template-columns: minmax(180px, 1fr) minmax(220px, 1.3fr) auto;
            gap: .65rem;
            align-items: end;
        }

        .skill-chip-list {
            display: flex;
            flex-wrap: wrap;
            gap: .5rem;
            margin-top: .8rem;
            min-height: 20px;
        }

        .skill-chip {
            display: inline-flex;
            align-items: center;
            gap: .45rem;
            padding: .35rem .65rem;
            border-radius: 999px;
            background: rgba(227, 239, 255, .95);
            color: #1c4d87;
            border: 1px solid #bcd5ff;
            font-size: .85rem;
            font-weight: 700;
        }

        .skill-chip-remove {
            border: none;
            background: transparent;
            color: inherit;
            cursor: pointer;
            font-size: .95rem;
            line-height: 1;
            padding: 0;
        }

        .form-note {
            margin: .65rem 0 0;
            color: #58708f;
            font-size: .84rem;
        }

        @media (max-width: 980px) {
            .candidate-row {
                grid-template-columns: 1fr;
            }
            .candidate-actions {
                justify-content: flex-start;
            }

            .create-form-grid,
            .skill-builder-top {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body data-mo-user-id="<%= userId %>">
<main class="shell">
    <a class="link" href="index.jsp">&larr; Exit</a>

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
            <div class="review-toolbar">
                <button id="reviewRefreshBtn" class="btn ghost" type="button">Refresh Review Data</button>
                <select id="reviewJobSelect" class="mini-select">
                    <option value="">All Jobs</option>
                </select>
                <input id="reviewJobSearch" list="reviewJobOptions" type="text" placeholder="Search job title/module/candidate/application id"/>
                <datalist id="reviewJobOptions"></datalist>
                <button id="reviewClearFilterBtn" class="btn ghost" type="button">Clear Filter</button>
                <div id="reviewHint" class="hint">Loading jobs and applications...</div>
            </div>
            <div class="filter-group review-status-filters" role="tablist" aria-label="Application status filter">
                <button type="button" class="filter-btn active" data-review-status="">
                    All <span class="badge-count" data-review-count="all">0</span>
                </button>
                <button type="button" class="filter-btn" data-review-status="SUBMITTED">
                    Pending <span class="badge-count" data-review-count="submitted">0</span>
                </button>
                <button type="button" class="filter-btn" data-review-status="INTERVIEWED">
                    Interviewed <span class="badge-count" data-review-count="interviewed">0</span>
                </button>
                <button type="button" class="filter-btn" data-review-status="ACCEPTED">
                    Accepted <span class="badge-count" data-review-count="accepted">0</span>
                </button>
                <button type="button" class="filter-btn" data-review-status="REJECTED">
                    Rejected <span class="badge-count" data-review-count="rejected">0</span>
                </button>
            </div>
            <p class="hint" style="margin-top:-.25rem;">
                Note: each submission creates one application record. Review by clear actions only: Mark Interviewed, Approve, or Reject.
            </p>
            <div id="reviewList" class="review-grid"></div>
        </div>

        <div id="panelCreate" class="mo-panel">
            <h2>Create New Job</h2>
            <p class="create-help">Create a new job posting with structured skills and workload details so the AI matching engine can score candidates more accurately.</p>
            <form id="mo-job-form" class="stack-form">
                <div class="create-form-grid">
                    <div>
                        <label class="field-label" for="jobIdInput">Job ID</label>
                        <input id="jobIdInput" type="text" name="jobId" placeholder="e.g. job-101" required/>
                    </div>
                    <div>
                        <label class="field-label" for="jobTitleInput">Job Title</label>
                        <input id="jobTitleInput" type="text" name="title" placeholder="e.g. Operating Systems TA" required/>
                    </div>
                    <div>
                        <label class="field-label" for="moduleCodeInput">Module Code</label>
                        <input id="moduleCodeInput" type="text" name="moduleCode" placeholder="e.g. EBU6304" required/>
                    </div>
                    <div>
                        <label class="field-label" for="slotsInput">Open Slots</label>
                        <input id="slotsInput" type="number" name="slots" placeholder="e.g. 3" min="1" required/>
                    </div>

                    <div class="full-span skill-builder">
                        <label class="field-label" for="commonSkillSelect">Required Skills</label>
                        <div class="skill-builder-top">
                            <div>
                                <label class="field-label" for="commonSkillSelect">Choose Skill</label>
                                <select id="commonSkillSelect" class="mini-select">
                                    <option value="">Select a common skill</option>
                                </select>
                            </div>
                            <div>
                                <label class="field-label" for="customSkillInput">Custom Skill</label>
                                <input id="customSkillInput" type="text" placeholder="e.g. Operating Systems"/>
                            </div>
                            <div>
                                <label class="field-label" for="addSkillBtn">&nbsp;</label>
                                <button id="addSkillBtn" class="btn ghost" type="button">Add Required Skill</button>
                            </div>
                        </div>
                        <input id="requiredSkillsInput" type="hidden" name="requiredSkills" required/>
                        <div id="selectedSkills" class="skill-chip-list"></div>
                        <p class="form-note">These skills will be used by the AI matching engine.</p>
                    </div>

                    <div>
                        <label class="field-label" for="hoursPerWeekInput">Hours per Week</label>
                        <input id="hoursPerWeekInput" type="number" name="hoursPerWeek" placeholder="e.g. 8" min="1" required/>
                    </div>
                    <div>
                        <label class="field-label" for="applicationDeadlineInput">Application Deadline</label>
                        <input id="applicationDeadlineInput" type="text" name="applicationDeadline" placeholder="e.g. 2026/5/24" required/>
                    </div>
                    <div>
                        <label class="field-label" for="monthlyStipendInput">Monthly Stipend (Yuan)</label>
                        <input id="monthlyStipendInput" type="number" name="monthlyStipend" placeholder="e.g. 2500" min="1" required/>
                    </div>
                    <div class="full-span">
                        <button class="btn" type="submit">Create Job</button>
                    </div>
                </div>
            </form>
            <div id="mo-output" class="form-feedback" role="status" aria-live="polite"></div>
        </div>
    </section>
</main>
<script src="assets/js/mo-page.js?v=8"></script>
</body>
</html>

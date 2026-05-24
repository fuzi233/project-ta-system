<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_TA.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Applications - TA Recruitment System</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        :root {
            --bg: #eef3ff;
            --panel: rgba(255, 255, 255, 0.92);
            --text: #102039;
            --muted: #4c5e7a;
            --line: #d6e4ff;
            --primary: #1575ff;
            --primary-dark: #0094ff;
            --accent: #00b7a5;
            --shadow: 0 24px 50px rgba(16, 32, 57, 0.15);

            --pending-bg: #f6edd8;
            --pending-text: #8a6d1d;

            --accepted-bg: #dfeedd;
            --accepted-text: #3f6c45;

            --rejected-bg: #f5dddd;
            --rejected-text: #9a4a4a;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "SF Pro Text", "SF Pro Display", "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: radial-gradient(circle at 20% 15%, #ffffff 0%, #eef3ff 45%, #d9e8ff 100%);
            color: var(--text);
        }

        .page {
            max-width: 1280px;
            margin: 40px auto;
            padding: 0 24px;
        }

        .shell {
            background: rgba(255, 255, 255, 0.95);
            border: 1px solid #d6e4ff;
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
            margin-bottom: 22px;
        }

        .breadcrumb a {
            color: var(--muted);
            text-decoration: none;
        }

        .title {
            margin: 0 0 22px;
            font-size: 46px;
            font-weight: 800;
            color: #0e3369;
        }

        .divider {
            height: 1px;
            background: #d6e4ff;
            margin-bottom: 20px;
        }

        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            margin-bottom: 26px;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            flex-wrap: wrap;
            gap: 0;
            border: 1px solid #c2d6ff;
            border-radius: 12px;
            overflow: hidden;
            background: rgba(255, 255, 255, .88);
        }

        .filter-btn {
            height: 50px;
            min-width: 120px;
            border: none;
            background: transparent;
            color: #486287;
            font-size: .95rem;
            font-weight: 600;
            border-right: 1px solid #c2d6ff;
            cursor: pointer;
            position: relative;
        }

        .filter-btn:last-child {
            border-right: none;
        }

        .filter-btn:hover {
            background: rgba(21, 117, 255, 0.08);
        }

        .filter-btn.active {
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
        }

        .badge-count {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 24px;
            height: 24px;
            padding: 0 6px;
            border-radius: 999px;
            margin-left: 6px;
            font-size: 13px;
            background: rgba(16, 32, 57, 0.1);
            color: inherit;
        }

        .filter-btn.active .badge-count {
            background: rgba(255, 255, 255, 0.28);
            color: #fff;
        }

        .sort-box {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 18px;
            color: var(--muted);
        }

        .sort-select {
            height: 50px;
            min-width: 220px;
            border: 1px solid #c2d6ff;
            border-radius: 12px;
            padding: 0 16px;
            font-size: .95rem;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
        }

        .application-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .application-card {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid #d6e4ff;
            border-radius: 16px;
            padding: 24px 26px;
            box-shadow: 0 8px 18px rgba(16, 32, 57, 0.06);
            display: flex;
            justify-content: space-between;
            gap: 20px;
            align-items: center;
        }

        .application-main h2 {
            margin: 0 0 12px;
            font-size: 22px;
            font-weight: 800;
            color: #16315b;
        }

        .application-meta {
            font-size: 16px;
            color: var(--muted);
            line-height: 1.8;
        }

        .status-row {
            margin-top: 8px;
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }

        .status-note {
            font-size: 14px;
            color: var(--muted);
        }

        .status-tag {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 15px;
            font-weight: 600;
        }

        .pending {
            background: var(--pending-bg);
            color: var(--pending-text);
        }

        .accepted {
            background: var(--accepted-bg);
            color: var(--accepted-text);
        }

        .rejected {
            background: var(--rejected-bg);
            color: var(--rejected-text);
        }

        .application-actions {
            display: flex;
            gap: 12px;
            flex-shrink: 0;
            flex-wrap: wrap;
        }

        .action-btn {
            min-width: 132px;
            height: 52px;
            border-radius: 12px;
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-size: .95rem;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .action-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .action-btn.withdraw {
            background: #fff7f7;
            color: #9a4a4a;
            border-color: #e8c4c4;
        }

        .action-btn:disabled {
            background: #d8e1ef;
            border-color: #d8e1ef;
            color: #7a8aa3;
            cursor: not-allowed;
            box-shadow: none;
            transform: none;
        }

        .application-detail {
            display: none;
            margin-top: 16px;
            padding: 16px;
            border: 1px solid #d6e4ff;
            border-radius: 14px;
            background: #f8fbff;
            color: #16315b;
        }

        .application-detail.show {
            display: block;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            margin-bottom: 14px;
        }

        .detail-item {
            padding: 10px 12px;
            border: 1px solid #dbe8ff;
            border-radius: 11px;
            background: #fff;
        }

        .detail-label {
            margin-bottom: 4px;
            color: #6b7280;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
        }

        .detail-value {
            color: #16315b;
            font-weight: 700;
            word-break: break-word;
        }

        .attachment-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
            padding: 10px 12px;
            border: 1px solid #dbe8ff;
            border-radius: 11px;
            background: #fff;
            margin-top: 8px;
        }

        .attachment-row a {
            color: #1575ff;
            font-weight: 800;
            text-decoration: none;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 0;
            margin-top: 24px;
        }

        .page-btn {
            width: 46px;
            height: 42px;
            border: 1px solid #d0d9e4;
            background: #fff;
            color: var(--muted);
            font-size: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
        }

        .page-btn:first-child {
            border-radius: 10px 0 0 10px;
        }

        .page-btn:last-child {
            border-radius: 0 10px 10px 0;
        }

        .page-btn.active {
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
        }

        .empty-box {
            display: none;
            text-align: center;
            padding: 38px 20px 8px;
            color: var(--muted);
            font-size: 18px;
        }

        @media (max-width: 960px) {
            .application-card {
                flex-direction: column;
                align-items: flex-start;
            }

            .application-actions {
                width: 100%;
                flex-wrap: wrap;
            }
        }

        @media (max-width: 720px) {
            .page {
                padding: 0 14px;
                margin: 20px auto;
            }

            .topbar {
                flex-direction: column;
                height: auto;
                gap: 10px;
                padding: 18px;
            }

            .nav {
                gap: 16px;
                flex-wrap: wrap;
                justify-content: center;
            }

            .content {
                padding: 24px 18px 30px;
            }

            .title {
                font-size: 34px;
            }

            .filter-group {
                width: 100%;
            }

            .filter-btn {
                min-width: 96px;
                flex: 1;
            }

            .sort-box {
                width: 100%;
                flex-direction: column;
                align-items: flex-start;
            }

            .sort-select {
                width: 100%;
            }

            .application-actions {
                flex-direction: column;
            }

            .action-btn {
                width: 100%;
            }
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
                <a href="jobs.jsp">Job List</a>
                <a href="applications.jsp" class="active">My Applications</a>
                <a href="profile.jsp">Profile</a>
                <a href="javascript:void(0)" onclick="signOut()">Sign Out</a>
            </nav>
        </header>

        <main class="content">
            <div class="breadcrumb">
                <a href="index.jsp">Home</a> &nbsp;›&nbsp; My Applications
            </div>

            <h1 class="title">My Applications</h1>
            <div class="divider"></div>

            <div class="toolbar">
                <div class="filter-group">
                    <button id="filterAll" class="filter-btn active" type="button">
                        All <span id="countAll" class="badge-count">0</span>
                    </button>
                    <button id="filterPending" class="filter-btn" type="button">
                        Pending <span id="countPending" class="badge-count">0</span>
                    </button>
                    <button id="filterAccepted" class="filter-btn" type="button">
                        Accepted <span id="countAccepted" class="badge-count">0</span>
                    </button>
                    <button id="filterRejected" class="filter-btn" type="button">
                        Rejected <span id="countRejected" class="badge-count">0</span>
                    </button>
                    <button id="filterWithdrawn" class="filter-btn" type="button">
                        Withdrawn <span id="countWithdrawn" class="badge-count">0</span>
                    </button>
                </div>

                <div class="sort-box">
                    <span>Sort by:</span>
                    <select id="sortSelect" class="sort-select">
                        <option value="recent">Most Recent</option>
                        <option value="oldest">Oldest First</option>
                    </select>
                </div>
            </div>

            <section id="applicationList" class="application-list"></section>

            <div id="emptyBox" class="empty-box">No applications found for this status.</div>
        </main>
    </div>
</div>

<script>
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

    const pendingStatuses = new Set(["SUBMITTED"]);
    const statusClassMap = {
        SUBMITTED: "pending",
        INTERVIEWED: "pending",
        ACCEPTED: "accepted",
        REJECTED: "rejected",
        WITHDRAWN: "rejected"
    };
    const statusLabelMap = {
        SUBMITTED: "Pending",
        INTERVIEWED: "Interviewed",
        ACCEPTED: "Accepted",
        REJECTED: "Rejected",
        WITHDRAWN: "Withdrawn"
    };
    const statusNoteMap = {
        SUBMITTED: "Waiting for review",
        INTERVIEWED: "Interview completed",
        WITHDRAWN: "Withdrawn by applicant"
    };

    const applicationListEl = document.getElementById("applicationList");
    const emptyBoxEl = document.getElementById("emptyBox");
    const sortSelectEl = document.getElementById("sortSelect");
    const countEls = {
        all: document.getElementById("countAll"),
        pending: document.getElementById("countPending"),
        accepted: document.getElementById("countAccepted"),
        rejected: document.getElementById("countRejected")
        ,withdrawn: document.getElementById("countWithdrawn")
    };
    const filterButtons = {
        all: document.getElementById("filterAll"),
        pending: document.getElementById("filterPending"),
        accepted: document.getElementById("filterAccepted"),
        rejected: document.getElementById("filterRejected"),
        withdrawn: document.getElementById("filterWithdrawn")
    };

    let applications = [];
    let jobsById = {};
    let currentFilter = "all";

    function parseTime(value) {
        const t = Date.parse(value || "");
        return Number.isNaN(t) ? 0 : t;
    }

    function formatDate(value) {
        const t = parseTime(value);
        if (!t) {
            return "-";
        }
        return new Date(t).toLocaleDateString("en-US", {
            month: "short",
            day: "numeric",
            year: "numeric"
        });
    }

    function normalizeStatus(status) {
        const upper = (status || "").toUpperCase();
        return statusLabelMap[upper] ? upper : "SUBMITTED";
    }

    function toFilterBucket(status) {
        if (pendingStatuses.has(status)) {
            return "pending";
        }
        if (status === "INTERVIEWED") {
            return "interviewed";
        }
        if (status === "ACCEPTED") {
            return "accepted";
        }
        if (status === "REJECTED") {
            return "rejected";
        }
        if (status === "WITHDRAWN") {
            return "withdrawn";
        }
        return "pending";
    }

    function updateCounts() {
        let pending = 0;
        let accepted = 0;
        let rejected = 0;
        let withdrawn = 0;
        for (const item of applications) {
            const status = normalizeStatus(item.status);
            const bucket = toFilterBucket(status);
            if (bucket === "pending") {
                pending++;
            } else if (bucket === "accepted") {
                accepted++;
            } else if (bucket === "rejected") {
                rejected++;
            } else if (bucket === "withdrawn") {
                withdrawn++;
            }
        }
        countEls.all.textContent = String(applications.length);
        countEls.pending.textContent = String(pending);
        countEls.accepted.textContent = String(accepted);
        countEls.rejected.textContent = String(rejected);
        countEls.withdrawn.textContent = String(withdrawn);
    }

    function getVisibleApplications() {
        const filtered = applications.filter((item) => {
            if (currentFilter === "all") {
                return true;
            }
            return toFilterBucket(normalizeStatus(item.status)) === currentFilter;
        });
        filtered.sort((a, b) => {
            const diff = parseTime(b.submittedAt) - parseTime(a.submittedAt);
            if (sortSelectEl.value === "oldest") {
                return -diff;
            }
            return diff;
        });
        return filtered;
    }

    function renderApplications() {
        const visible = getVisibleApplications();
        applicationListEl.innerHTML = "";
        if (visible.length === 0) {
            emptyBoxEl.style.display = "block";
            return;
        }
        emptyBoxEl.style.display = "none";

        for (const item of visible) {
            const status = normalizeStatus(item.status);
            const cssClass = statusClassMap[status] || "pending";
            const statusLabel = statusLabelMap[status] || status;
            const job = jobsById[item.jobId] || {};

            const card = document.createElement("article");
            card.className = "application-card";

            const main = document.createElement("div");
            main.className = "application-main";

            const title = document.createElement("h2");
            title.textContent = job.title || item.jobId;
            main.appendChild(title);

            const meta = document.createElement("div");
            meta.className = "application-meta";
            const course = document.createElement("div");
            const moduleCode = job.moduleCode || "-";
            course.textContent = "Course: " + moduleCode;
            meta.appendChild(course);
            main.appendChild(meta);

            const statusRow = document.createElement("div");
            statusRow.className = "status-row";
            const statusTag = document.createElement("span");
            statusTag.className = "status-tag " + cssClass;
            statusTag.textContent = statusLabel;
            statusRow.appendChild(statusTag);
            const statusNoteText = statusNoteMap[status];
            if (statusNoteText) {
                const statusNote = document.createElement("span");
                statusNote.className = "status-note";
                statusNote.textContent = statusNoteText;
                statusRow.appendChild(statusNote);
            }
            const applied = document.createElement("span");
            applied.className = "application-meta";
            applied.textContent = "Applied: " + formatDate(item.submittedAt);
            statusRow.appendChild(applied);
            main.appendChild(statusRow);

            const actions = document.createElement("div");
            actions.className = "application-actions";
            const viewBtn = document.createElement("a");
            viewBtn.className = "action-btn";
            viewBtn.href = "javascript:void(0)";
            viewBtn.textContent = "View Detail";
            actions.appendChild(viewBtn);

            const withdrawBtn = document.createElement("button");
            withdrawBtn.className = "action-btn withdraw";
            withdrawBtn.type = "button";
            withdrawBtn.textContent = "Withdraw";
            withdrawBtn.disabled = !["SUBMITTED", "INTERVIEWED"].includes(status);
            withdrawBtn.addEventListener("click", () => withdrawApplication(item.applicationId));
            actions.appendChild(withdrawBtn);

            const detail = document.createElement("div");
            detail.className = "application-detail";
            const attachments = Array.isArray(item.attachments) ? item.attachments : [];
            detail.innerHTML = ""
                + "<div class=\"detail-grid\">"
                + "<div class=\"detail-item\"><div class=\"detail-label\">Job ID</div><div class=\"detail-value\">" + escapeHtml(item.jobId) + "</div></div>"
                + "<div class=\"detail-item\"><div class=\"detail-label\">Module</div><div class=\"detail-value\">" + escapeHtml(job.moduleCode || "-") + "</div></div>"
                + "<div class=\"detail-item\"><div class=\"detail-label\">Skills</div><div class=\"detail-value\">" + escapeHtml(job.requiredSkills || "-") + "</div></div>"
                + "<div class=\"detail-item\"><div class=\"detail-label\">Deadline</div><div class=\"detail-value\">" + escapeHtml(formatDate(job.applicationDeadline || job.createdAt)) + "</div></div>"
                + "</div>"
                + "<div class=\"detail-label\">Submitted Attachments</div>"
                + (attachments.length ? attachments.map(renderAttachment).join("") : "<div class=\"attachment-row\">No attachment uploaded.</div>");

            viewBtn.addEventListener("click", () => {
                detail.classList.toggle("show");
                viewBtn.textContent = detail.classList.contains("show") ? "Hide Detail" : "View Detail";
            });

            card.appendChild(main);
            card.appendChild(actions);
            main.appendChild(detail);
            applicationListEl.appendChild(card);
        }
    }

    function escapeHtml(value) {
        return String(value ?? "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'", "&#39;");
    }

    function renderAttachment(attachment) {
        const type = escapeHtml(attachment.attachmentType || "FILE");
        const filename = escapeHtml(attachment.originalFilename || "Attachment");
        const id = encodeURIComponent(attachment.attachmentId || "");
        return "<div class=\"attachment-row\">"
            + "<span><strong>" + type + "</strong> · " + filename + "</span>"
            + "<a href=\"attachments/download?attachmentId=" + id + "\" target=\"_blank\">Open</a>"
            + "</div>";
    }

    async function withdrawApplication(applicationId) {
        if (!window.confirm("Withdraw this application? This action will remove it from active review.")) {
            return;
        }
        await api("/applications?applicationId=" + encodeURIComponent(applicationId), {method: "DELETE"});
        await boot();
    }

    function setActiveFilter(nextFilter) {
        currentFilter = nextFilter;
        Object.entries(filterButtons).forEach(([key, btn]) => {
            if (!btn) {
                return;
            }
            if (key === nextFilter) {
                btn.classList.add("active");
            } else {
                btn.classList.remove("active");
            }
        });
        renderApplications();
    }

    async function loadJobs() {
        const data = await api("/jobs?page=1&size=200");
        jobsById = {};
        for (const item of (data.items || [])) {
            jobsById[item.jobId] = item;
        }
    }

    async function loadApplications() {
        const data = await api("/applications?page=1&size=200");
        applications = data.items || [];
    }

    async function boot() {
        try {
            await Promise.all([loadJobs(), loadApplications()]);
            updateCounts();
            setActiveFilter("all");
        } catch (error) {
            applicationListEl.innerHTML = "";
            emptyBoxEl.style.display = "block";
            emptyBoxEl.textContent = error.message;
        }
    }

    filterButtons.all.addEventListener("click", () => setActiveFilter("all"));
    filterButtons.pending.addEventListener("click", () => setActiveFilter("pending"));
    filterButtons.accepted.addEventListener("click", () => setActiveFilter("accepted"));
    filterButtons.rejected.addEventListener("click", () => setActiveFilter("rejected"));
    filterButtons.withdrawn.addEventListener("click", () => setActiveFilter("withdrawn"));
    sortSelectEl.addEventListener("change", renderApplications);

    async function signOut() {
        await fetch("auth/logout", {method: "POST"});
        window.location.href = "index.jsp?login=1";
    }

    boot();
</script>
</body>
</html>

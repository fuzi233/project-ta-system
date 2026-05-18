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
    <title>Available Jobs - TA Recruitment System</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        :root {
            --bg: #eef2f6;
            --panel: #ffffff;
            --text: #1f2937;
            --muted: #6b7280;
            --line: #d7dee8;
            --primary: #9cb8d3;
            --primary-dark: #7f9fbe;
            --shadow: 0 10px 24px rgba(31, 41, 55, 0.08);
            --radius-lg: 22px;
            --radius-md: 14px;
            --radius-sm: 10px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: linear-gradient(180deg, #edf2f7 0%, #e9eef5 100%);
            color: var(--text);
        }

        .page {
            max-width: 1280px;
            margin: 40px auto;
            padding: 0 24px;
        }

        .shell {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid #e2e8f0;
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
            background: rgba(255,255,255,0.95);
        }

        .brand {
            font-size: 18px;
            font-weight: 700;
            color: #334155;
        }

        .nav {
            display: flex;
            gap: 32px;
            align-items: center;
        }

        .nav a {
            text-decoration: none;
            color: #475569;
            font-size: 16px;
            font-weight: 500;
            padding: 24px 0 20px;
            border-bottom: 3px solid transparent;
        }

        .nav a.active {
            color: #0f172a;
            border-bottom-color: #718096;
        }

        .content {
            padding: 36px 34px 40px;
        }

        .page-title {
            margin: 0 0 28px;
            font-size: 48px;
            font-weight: 800;
            color: #10213f;
        }

        .toolbar {
            display: grid;
            grid-template-columns: 1.8fr 0.8fr 0.8fr 0.8fr auto;
            gap: 12px;
            margin-bottom: 28px;
        }

        .input,
        .select,
        .btn {
            height: 54px;
            border-radius: 12px;
            border: 1px solid #ced8e3;
            background: #fff;
            font-size: 16px;
        }

        .input,
        .select {
            padding: 0 16px;
            color: #334155;
        }

        .btn {
            padding: 0 22px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .btn-filter {
            background: #f8fafc;
            color: #334155;
        }

        .btn-primary {
            background: linear-gradient(135deg, #9db7d0 0%, #86a8c5 100%);
            color: #fff;
            border: none;
        }

        .btn:disabled {
            cursor: not-allowed;
            opacity: 0.6;
            transform: none;
            box-shadow: none;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin: 8px 0 28px;
        }

        .selection-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 24px;
            padding: 18px 20px;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            background: #f8fbfe;
        }

        .selection-status {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .selection-count {
            font-size: 18px;
            font-weight: 700;
            color: #1e293b;
        }

        .selection-message {
            min-height: 20px;
            font-size: 14px;
            color: #64748b;
        }

        .selection-message.error {
            color: #b42318;
        }

        .job-list {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .job-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            padding: 28px 28px;
            box-shadow: 0 6px 16px rgba(15, 23, 42, 0.04);
        }

        .job-select {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            min-width: 110px;
            color: #475569;
            font-size: 16px;
            font-weight: 600;
        }

        .job-select input {
            width: 18px;
            height: 18px;
            accent-color: #86a8c5;
            cursor: pointer;
        }

        .job-main {
            flex: 1;
        }

        .job-main h2 {
            margin: 0 0 14px;
            font-size: 24px;
            font-weight: 800;
            color: #1e293b;
        }

        .job-meta {
            display: flex;
            flex-direction: column;
            gap: 8px;
            color: #64748b;
            font-size: 18px;
        }

        .job-actions {
            display: flex;
            gap: 14px;
            flex-shrink: 0;
        }

        .action-btn {
            min-width: 132px;
            height: 52px;
            border-radius: 12px;
            border: 1px solid #ccd6e2;
            background: #fff;
            color: #334155;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }

        .action-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .action-btn.primary {
            background: linear-gradient(135deg, #9db7d0 0%, #86a8c5 100%);
            color: #fff;
            border: none;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 0;
            margin-top: 26px;
        }

        .page-btn {
            width: 46px;
            height: 42px;
            border: 1px solid #d0d9e4;
            background: #fff;
            color: #475569;
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
            background: #a6bfd8;
            color: #fff;
        }

        .empty-tip {
            display: none;
            text-align: center;
            padding: 36px 0 12px;
            color: #64748b;
            font-size: 18px;
        }

        @media (max-width: 1024px) {
            .toolbar {
                grid-template-columns: 1fr 1fr;
            }

            .selection-toolbar {
                flex-direction: column;
                align-items: stretch;
            }

            .job-card {
                flex-direction: column;
                align-items: flex-start;
            }

            .job-actions {
                width: 100%;
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

            .page-title {
                font-size: 34px;
            }

            .toolbar {
                grid-template-columns: 1fr;
            }

            .selection-toolbar {
                padding: 16px;
            }

            .job-actions {
                flex-direction: column;
            }

            .action-btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<div class="page">
    <div class="shell">
        <header class="topbar">
            <div class="brand">TA Recruitment System</div>
            <nav class="nav">
                <a href="index.jsp">Home</a>
                <a href="jobs.jsp" class="active">Job List</a>
                <a href="applications.jsp">My Applications</a>
                <a href="profile.jsp">Profile</a>
            </nav>
        </header>

        <main class="content">
            <h1 class="page-title">Available Jobs</h1>

            <div class="toolbar">
                <input id="searchInput" class="input" type="text" placeholder="Search jobs...">
                <select id="typeFilter" class="select">
                    <option value="">All Modules</option>
                    <option value="programming">Programming</option>
                    <option value="database">Database</option>
                    <option value="web">Web</option>
                </select>
                <select id="skillFilter" class="select">
                    <option value="">All Skills</option>
                    <option value="java">Java</option>
                    <option value="sql">SQL</option>
                    <option value="html">HTML/CSS</option>
                </select>
                <select id="pageSizeSelect" class="select">
                    <option value="5">5 / page</option>
                    <option value="10" selected>10 / page</option>
                    <option value="20">20 / page</option>
                </select>
                <button id="filterBtn" class="btn btn-filter" type="button">Filter</button>
            </div>

            <div class="divider"></div>

            <div class="selection-toolbar">
                <div class="selection-status">
                    <div id="selectionCount" class="selection-count">0 jobs selected</div>
                    <div id="selectionMessage" class="selection-message" aria-live="polite"></div>
                </div>
                <button id="applySelectedBtn" class="btn btn-primary" type="button">Apply to Selected Jobs</button>
            </div>

            <section id="jobList" class="job-list"></section>

            <div id="emptyTip" class="empty-tip">No jobs match your current filters.</div>

            <div id="pagination" class="pagination"></div>
        </main>
    </div>
</div>

<script>
    const state = {
        page: 1,
        size: 10,
        total: 0,
        items: []
    };

    const jobListEl = document.getElementById("jobList");
    const emptyTipEl = document.getElementById("emptyTip");
    const paginationEl = document.getElementById("pagination");
    const searchInputEl = document.getElementById("searchInput");
    const typeFilterEl = document.getElementById("typeFilter");
    const skillFilterEl = document.getElementById("skillFilter");
    const pageSizeSelectEl = document.getElementById("pageSizeSelect");
    const filterBtnEl = document.getElementById("filterBtn");
    const selectionCountEl = document.getElementById("selectionCount");
    const selectionMessageEl = document.getElementById("selectionMessage");
    const applySelectedBtnEl = document.getElementById("applySelectedBtn");
    const selectedJobIds = new Set();

    async function api(url) {
        const response = await fetch(url, {
            headers: {"Content-Type": "application/json"}
        });
        const text = await response.text();
        let body = {};
        try {
            body = text ? JSON.parse(text) : {};
        } catch (_) {
            body = {error: text || ("HTTP " + response.status)};
        }
        if (!response.ok) {
            throw new Error(body.error || ("HTTP " + response.status));
        }
        return body;
    }

    function buildQuery() {
        return [
            searchInputEl.value.trim(),
            typeFilterEl.value,
            skillFilterEl.value
        ].filter(Boolean).join(" ");
    }

    function fmtDate(value) {
        const timestamp = Date.parse(value || "");
        if (Number.isNaN(timestamp)) {
            return "-";
        }
        return new Date(timestamp).toLocaleString("en-US", {
            year: "numeric",
            month: "short",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit"
        });
    }

    function renderSelectionSummary() {
        const count = selectedJobIds.size;
        selectionCountEl.textContent = count + (count === 1 ? " job selected" : " jobs selected");
        applySelectedBtnEl.style.opacity = count === 0 ? "0.85" : "1";
    }

    function setSelectionMessage(message, isError) {
        selectionMessageEl.textContent = message || "";
        selectionMessageEl.className = "selection-message" + (message && isError ? " error" : "");
    }

    function renderJobs() {
        jobListEl.innerHTML = "";
        if (!state.items.length) {
            emptyTipEl.style.display = "block";
            return;
        }
        emptyTipEl.style.display = "none";

        state.items.forEach((job) => {
            const card = document.createElement("article");
            card.className = "job-card";

            const selector = document.createElement("label");
            selector.className = "job-select";

            const checkbox = document.createElement("input");
            checkbox.type = "checkbox";
            checkbox.checked = selectedJobIds.has(job.jobId);
            checkbox.addEventListener("change", () => {
                if (checkbox.checked) {
                    selectedJobIds.add(job.jobId);
                } else {
                    selectedJobIds.delete(job.jobId);
                }
                setSelectionMessage("", false);
                renderSelectionSummary();
            });
            selector.appendChild(checkbox);

            const selectorText = document.createElement("span");
            selectorText.textContent = "Select";
            selector.appendChild(selectorText);

            const main = document.createElement("div");
            main.className = "job-main";

            const title = document.createElement("h2");
            title.textContent = job.title + " (" + job.jobId + ")";
            main.appendChild(title);

            const meta = document.createElement("div");
            meta.className = "job-meta";
            meta.innerHTML = ""
                + "<div>Module: " + (job.moduleCode || "-") + "</div>"
                + "<div>Required Skills: " + (job.requiredSkills || "-") + "</div>"
                + "<div>Slots: " + String(job.slots ?? "-") + " | Status: " + (job.status || "-") + "</div>"
                + "<div>Posted At: " + fmtDate(job.createdAt) + "</div>";
            main.appendChild(meta);

            const actions = document.createElement("div");
            actions.className = "job-actions";

            const detailLink = document.createElement("a");
            detailLink.className = "action-btn";
            detailLink.href = "job-detail.jsp?jobId=" + encodeURIComponent(job.jobId);
            detailLink.textContent = "View Details";
            actions.appendChild(detailLink);

            const applyLink = document.createElement("a");
            applyLink.className = "action-btn primary";
            applyLink.href = "apply.jsp?jobId=" + encodeURIComponent(job.jobId);
            applyLink.textContent = "Apply";
            actions.appendChild(applyLink);

            card.appendChild(selector);
            card.appendChild(main);
            card.appendChild(actions);
            jobListEl.appendChild(card);
        });
    }

    function renderPagination() {
        paginationEl.innerHTML = "";
        const totalPages = Math.max(1, Math.ceil(state.total / state.size));
        if (totalPages <= 1) {
            return;
        }

        const addButton = (label, targetPage, isActive, disabled) => {
            const btn = document.createElement("button");
            btn.type = "button";
            btn.className = "page-btn" + (isActive ? " active" : "");
            btn.textContent = label;
            btn.disabled = disabled;
            btn.style.cursor = disabled ? "not-allowed" : "pointer";
            btn.addEventListener("click", async () => {
                if (disabled || targetPage === state.page) {
                    return;
                }
                state.page = targetPage;
                await loadJobs();
            });
            paginationEl.appendChild(btn);
        };

        addButton("‹", state.page - 1, false, state.page <= 1);

        const start = Math.max(1, state.page - 1);
        const end = Math.min(totalPages, start + 2);
        for (let page = start; page <= end; page++) {
            addButton(String(page), page, page === state.page, false);
        }

        addButton("›", state.page + 1, false, state.page >= totalPages);
    }

    async function loadJobs() {
        const query = buildQuery();
        state.size = Math.max(1, Number(pageSizeSelectEl.value) || 10);
        const url = "/jobs?status=OPEN&page=" + encodeURIComponent(state.page)
            + "&size=" + encodeURIComponent(state.size)
            + "&q=" + encodeURIComponent(query);
        const data = await api(url);
        state.total = Number(data.total || 0);
        state.items = data.items || [];

        const totalPages = Math.max(1, Math.ceil(state.total / state.size));
        if (state.page > totalPages) {
            state.page = totalPages;
            return loadJobs();
        }

        renderJobs();
        renderPagination();
    }

    async function applyFilters() {
        state.page = 1;
        await loadJobs();
    }

    applySelectedBtnEl.addEventListener("click", () => {
        if (selectedJobIds.size === 0) {
            setSelectionMessage("Please select at least one job before applying.", true);
            renderSelectionSummary();
            return;
        }

        setSelectionMessage("", false);
        const ids = Array.from(selectedJobIds);
        window.location.href = "apply.jsp?jobIds=" + encodeURIComponent(ids.join(","));
    });
    filterBtnEl.addEventListener("click", applyFilters);
    pageSizeSelectEl.addEventListener("change", applyFilters);
    searchInputEl.addEventListener("keydown", async (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            await applyFilters();
        }
    });

    loadJobs().catch((error) => {
        jobListEl.innerHTML = "";
        emptyTipEl.textContent = error.message;
        emptyTipEl.style.display = "block";
        paginationEl.innerHTML = "";
    });
    renderSelectionSummary();
</script>
</body>
</html>

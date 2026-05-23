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
            --bg: #eef3ff;
            --panel: rgba(255, 255, 255, 0.92);
            --text: #102039;
            --muted: #4c5e7a;
            --line: #d6e4ff;
            --primary: #1575ff;
            --primary-dark: #0094ff;
            --accent: #00b7a5;
            --shadow: 0 24px 50px rgba(16, 32, 57, 0.15);
            --radius-lg: 22px;
            --radius-md: 14px;
            --radius-sm: 10px;
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
            background: rgba(255, 255, 255, 0.92);
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
            background: rgba(255,255,255,0.95);
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
            color: #16315b;
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
            color: #16315b;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin: 8px 0 28px;
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
            color: var(--muted);
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
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-size: .95rem;
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
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            border: none;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-top: 26px;
            flex-wrap: wrap;
        }

        .page-btn {
            min-width: 48px;
            height: 44px;
            border: 1px solid #c2d6ff;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-size: 16px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.06);
            transition: all 0.2s ease;
        }

        .page-btn:hover:not(:disabled) {
            transform: translateY(-1px);
            box-shadow: 0 12px 22px rgba(21, 117, 255, 0.14);
        }

        .page-btn.active {
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            border-color: transparent;
        }

        .page-btn:disabled {
            color: #9aa8bd;
            background: #edf2f7;
            cursor: not-allowed;
        }

        .empty-tip {
            display: none;
            text-align: center;
            padding: 36px 0 12px;
            color: var(--muted);
            font-size: 18px;
        }

        @media (max-width: 1024px) {
            .toolbar {
                grid-template-columns: 1fr 1fr;
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
<div class="bg-orb orb-a"></div>
<div class="bg-orb orb-b"></div>
<div class="page">
    <a class="link" href="index.jsp">&larr; Exit</a>
    <div class="shell">
        <header class="topbar">
            <div class="brand">TA Recruitment System</div>
            <nav class="nav">
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
                    <option value="">All</option>
                    <option value="programming">Programming</option>
                    <option value="database">Database</option>
                    <option value="web">Web</option>
                </select>
                <select id="skillFilter" class="select">
                    <option value="">Skills</option>
                    <option value="java">Java</option>
                    <option value="sql">SQL</option>
                    <option value="html">HTML/CSS</option>
                </select>
                <select id="semesterFilter" class="select">
                    <option value="">Semester</option>
                    <option value="spring">Spring</option>
                    <option value="autumn">Autumn</option>
                </select>
                <button class="btn btn-filter" onclick="filterJobs()">Filter</button>
            </div>

            <div class="divider"></div>

            <section id="jobList" class="job-list">
                <article class="job-card">
                    <div class="job-main">
                        <h2>Loading jobs...</h2>
                        <div class="job-meta">
                            <div>Please wait while the latest MO postings are loaded.</div>
                        </div>
                    </div>
                </article>
            </section>

            <div id="emptyTip" class="empty-tip">No jobs match your current filters.</div>

            <div id="pagination" class="pagination"></div>
        </main>
    </div>
</div>

<script>
    const state = {
        jobs: [],
        filteredJobs: [],
        page: 1,
        pageSize: 5
    };

    function escapeHtml(value) {
        return String(value ?? "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'", "&#39;");
    }

    async function api(url) {
        const response = await fetch(url, {headers: {"Content-Type": "application/json"}});
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

    function parseTime(value) {
        const time = Date.parse(value || "");
        return Number.isNaN(time) ? 0 : time;
    }

    function fmtDate(value) {
        const time = Date.parse(value || "");
        if (Number.isNaN(time)) {
            return value || "Not set";
        }
        return new Date(time).toLocaleDateString("en-US", {
            year: "numeric",
            month: "short",
            day: "numeric"
        });
    }

    function matchesText(value, keyword) {
        return String(value || "").toLowerCase().includes(keyword);
    }

    function filterJobs() {
        const keyword = document.getElementById("searchInput").value.trim().toLowerCase();
        const type = document.getElementById("typeFilter").value;
        const skill = document.getElementById("skillFilter").value;
        const semester = document.getElementById("semesterFilter").value;

        state.filteredJobs = state.jobs.filter((job) => {
            const haystack = [
                job.title,
                job.moduleCode,
                job.requiredSkills,
                job.jobId
            ].join(" ").toLowerCase();
            const matchKeyword = !keyword || haystack.includes(keyword);
            const matchType = !type || matchesText(job.title, type) || matchesText(job.requiredSkills, type);
            const matchSkill = !skill || matchesText(job.requiredSkills, skill);
            const deadline = String(job.applicationDeadline || job.createdAt || "").toLowerCase();
            const matchSemester = !semester || deadline.includes(semester);
            return matchKeyword && matchType && matchSkill && matchSemester;
        });
        state.page = 1;
        renderJobs();
    }

    function renderJobs() {
        const jobList = document.getElementById("jobList");
        const emptyTip = document.getElementById("emptyTip");
        const start = (state.page - 1) * state.pageSize;
        const jobs = state.filteredJobs.slice(start, start + state.pageSize);

        jobList.innerHTML = "";
        if (jobs.length === 0) {
            emptyTip.style.display = "block";
            renderPagination();
            return;
        }

        emptyTip.style.display = "none";
        jobs.forEach((job) => {
            const card = document.createElement("article");
            card.className = "job-card";
            const deadline = job.applicationDeadline
                ? "Deadline: " + fmtDate(job.applicationDeadline)
                : "Created: " + fmtDate(job.createdAt);
            card.innerHTML = ""
                + "<div class=\"job-main\">"
                + "<h2>" + escapeHtml(job.title) + "</h2>"
                + "<div class=\"job-meta\">"
                + "<div>Module: " + escapeHtml(job.moduleCode || "-") + " | Slots: " + escapeHtml(job.slots ?? "-") + "</div>"
                + "<div>Skills: " + escapeHtml(job.requiredSkills || "-") + "</div>"
                + "<div>" + escapeHtml(deadline) + "</div>"
                + "</div>"
                + "</div>"
                + "<div class=\"job-actions\">"
                + "<a class=\"action-btn\" href=\"job-detail.jsp?jobId=" + encodeURIComponent(job.jobId) + "\">View Details</a>"
                + "<a class=\"action-btn primary\" href=\"apply.jsp?jobId=" + encodeURIComponent(job.jobId) + "\">Apply</a>"
                + "</div>";
            jobList.appendChild(card);
        });
        renderPagination();
    }

    function renderPagination() {
        const pagination = document.getElementById("pagination");
        const totalPages = Math.max(1, Math.ceil(state.filteredJobs.length / state.pageSize));
        pagination.innerHTML = "";
        if (totalPages <= 1) {
            return;
        }

        for (let page = 1; page <= totalPages; page++) {
            const button = document.createElement("button");
            button.className = "page-btn" + (page === state.page ? " active" : "");
            button.type = "button";
            button.textContent = String(page);
            button.addEventListener("click", () => {
                state.page = page;
                renderJobs();
            });
            pagination.appendChild(button);
        }

        const nextButton = document.createElement("button");
        nextButton.className = "page-btn";
        nextButton.type = "button";
        nextButton.textContent = "›";
        nextButton.disabled = state.page >= totalPages;
        nextButton.addEventListener("click", () => {
            if (state.page < totalPages) {
                state.page++;
                renderJobs();
            }
        });
        pagination.appendChild(nextButton);
    }

    async function loadJobs() {
        try {
            const data = await api("/jobs?status=OPEN&page=1&size=500");
            state.jobs = (data.items || []).sort((a, b) => parseTime(b.createdAt) - parseTime(a.createdAt));
            state.filteredJobs = state.jobs;
            renderJobs();
        } catch (error) {
            document.getElementById("jobList").innerHTML = ""
                + "<article class=\"job-card\">"
                + "<div class=\"job-main\">"
                + "<h2>Failed to load jobs</h2>"
                + "<div class=\"job-meta\"><div>" + escapeHtml(error.message) + "</div></div>"
                + "</div>"
                + "</article>";
            document.getElementById("emptyTip").style.display = "none";
            document.getElementById("pagination").innerHTML = "";
        }
    }

    document.getElementById("searchInput").addEventListener("input", filterJobs);
    document.getElementById("typeFilter").addEventListener("change", filterJobs);
    document.getElementById("skillFilter").addEventListener("change", filterJobs);
    document.getElementById("semesterFilter").addEventListener("change", filterJobs);
    loadJobs();
</script>
</body>
</html>

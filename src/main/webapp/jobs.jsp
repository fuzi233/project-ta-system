<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    boolean isTa = AuthSession.ROLE_TA.equalsIgnoreCase(role);
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
            position: relative;
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

        .signin-menu {
            position: relative;
        }

        .signin-toggle {
            height: 40px;
            border: 1px solid #c2d6ff;
            border-radius: 999px;
            padding: 0 18px;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 10px 22px rgba(21, 117, 255, 0.18);
        }

        .login-drop {
            position: absolute;
            top: calc(100% + 12px);
            right: 0;
            width: 360px;
            max-width: calc(100vw - 48px);
            display: none;
            padding: 18px;
            border: 1px solid #d6e4ff;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.98);
            box-shadow: 0 24px 50px rgba(16, 32, 57, 0.2);
            z-index: 20;
        }

        .login-drop.show {
            display: block;
            animation: rise 180ms ease;
        }

        @keyframes rise {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .login-drop h3 {
            margin: 0 0 12px;
            color: #16315b;
            font-size: 1rem;
        }

        .role-row,
        .demo-strip {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 10px;
        }

        .role-chip,
        .demo-btn {
            border: 1px solid #c2d6ff;
            border-radius: 10px;
            background: #f8fafc;
            color: #475569;
            font-weight: 700;
            cursor: pointer;
        }

        .role-chip {
            flex: 1;
            padding: 8px 10px;
        }

        .role-chip.active {
            border-color: #1575ff;
            background: #eff6ff;
            color: #1575ff;
        }

        .demo-btn {
            padding: 6px 10px;
            font-size: 0.78rem;
        }

        .login-field {
            width: 100%;
            height: 42px;
            margin-bottom: 10px;
            border: 1px solid #c2d6ff;
            border-radius: 11px;
            padding: 0 12px;
            color: #16315b;
            font-size: 0.92rem;
        }

        .login-submit {
            width: 100%;
            height: 42px;
            border: 0;
            border-radius: 11px;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            font-weight: 800;
            cursor: pointer;
        }

        .login-error {
            min-height: 18px;
            color: #EF4444;
            font-size: 0.78rem;
            margin-bottom: 8px;
        }

        .login-note {
            margin-top: 10px;
            text-align: center;
            color: #64748B;
            font-size: 0.8rem;
        }

        .login-note a {
            padding: 0;
            border: 0;
            color: #1575ff;
            font-weight: 800;
        }

        .content {
            padding: 30px 32px 36px;
        }

        .page-title {
            margin: 0 0 22px;
            font-size: 42px;
            font-weight: 800;
            color: #10213f;
        }

        .toolbar {
            display: grid;
            grid-template-columns: 1.8fr 0.9fr 0.9fr auto;
            gap: 12px;
            margin-bottom: 20px;
        }

        .input,
        .select,
        .btn {
            height: 46px;
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
            margin: 6px 0 20px;
        }

        .job-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .job-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 15px;
            padding: 18px 22px;
            box-shadow: 0 6px 16px rgba(15, 23, 42, 0.04);
        }

        .job-main h2 {
            margin: 0 0 8px;
            font-size: 21px;
            font-weight: 800;
            color: #1e293b;
        }

        .job-meta {
            display: flex;
            flex-direction: column;
            gap: 5px;
            color: var(--muted);
            font-size: 15px;
        }

        .job-actions {
            display: flex;
            gap: 14px;
            flex-shrink: 0;
        }

        .action-btn {
            min-width: 118px;
            height: 44px;
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

            .login-drop {
                right: 50%;
                transform: translateX(50%);
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
                <a href="jobs.jsp" class="active">Job List</a>
                <% if (isTa) { %>
                <a href="applications.jsp">My Applications</a>
                <a href="profile.jsp">Profile</a>
                <a href="javascript:void(0)" onclick="signOut()">Sign Out</a>
                <% } else { %>
                <div class="signin-menu">
                    <button id="signinToggle" class="signin-toggle" type="button">Sign In</button>
                    <div id="loginDrop" class="login-drop">
                        <h3>Sign In</h3>
                        <div class="role-row">
                            <button class="role-chip active" type="button" data-login-role="TA">TA</button>
                            <button class="role-chip" type="button" data-login-role="MO">MO</button>
                            <button class="role-chip" type="button" data-login-role="ADMIN">Admin</button>
                        </div>
                        <input type="hidden" id="loginRole" value="TA">
                        <input id="loginIdentifier" class="login-field" type="text" placeholder="Student ID or email">
                        <input id="loginPassword" class="login-field" type="password" placeholder="Password">
                        <div id="loginError" class="login-error"></div>
                        <button class="login-submit" type="button" onclick="doLogin()">Sign In</button>
                        <div class="demo-strip">
                            <button class="demo-btn" type="button" data-demo-role="TA" data-demo-id="ta001@bupt.edu.cn" data-demo-pw="TaDemo@123">TA Demo</button>
                            <button class="demo-btn" type="button" data-demo-role="MO" data-demo-id="mo001@bupt.edu.cn" data-demo-pw="MoDemo@123">MO Demo</button>
                            <button class="demo-btn" type="button" data-demo-role="ADMIN" data-demo-id="hradmin" data-demo-pw="HrDemo@123">Admin Demo</button>
                        </div>
                        <div class="login-note">Need an account? <a href="index.jsp?login=1">Create TA account</a></div>
                    </div>
                </div>
                <% } %>
            </nav>
        </header>

        <main class="content">
            <h1 class="page-title">Available Jobs</h1>

            <div class="toolbar">
                <input id="searchInput" class="input" type="text" placeholder="Search jobs...">
                <select id="typeFilter" class="select">
                    <option value="">All Modules</option>
                </select>
                <select id="skillFilter" class="select">
                    <option value="">All Skills</option>
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
    const IS_TA = <%= isTa ? "true" : "false" %>;
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

    function splitSkills(value) {
        return String(value || "")
            .split(/[,;\/|]+/)
            .map(item => item.trim())
            .filter(Boolean);
    }

    function populateDynamicFilters() {
        const moduleSelect = document.getElementById("typeFilter");
        const skillSelect = document.getElementById("skillFilter");
        const currentModule = moduleSelect.value;
        const currentSkill = skillSelect.value;
        const modules = [...new Set(state.jobs.map(job => String(job.moduleCode || "").trim()).filter(Boolean))].sort();
        const skills = [...new Set(state.jobs.flatMap(job => splitSkills(job.requiredSkills)))].sort((a, b) => a.localeCompare(b));

        moduleSelect.innerHTML = "<option value=\"\">All Modules</option>"
            + modules.map(module => "<option value=\"" + escapeHtml(module) + "\">" + escapeHtml(module) + "</option>").join("");
        skillSelect.innerHTML = "<option value=\"\">All Skills</option>"
            + skills.map(skill => "<option value=\"" + escapeHtml(skill) + "\">" + escapeHtml(skill) + "</option>").join("");
        moduleSelect.value = modules.includes(currentModule) ? currentModule : "";
        skillSelect.value = skills.includes(currentSkill) ? currentSkill : "";
    }

    function filterJobs() {
        const keyword = document.getElementById("searchInput").value.trim().toLowerCase();
        const moduleCode = document.getElementById("typeFilter").value;
        const skill = document.getElementById("skillFilter").value;

        state.filteredJobs = state.jobs.filter((job) => {
            const haystack = [
                job.title,
                job.moduleCode,
                job.requiredSkills,
                job.jobId
            ].join(" ").toLowerCase();
            const matchKeyword = !keyword || haystack.includes(keyword);
            const matchModule = !moduleCode || String(job.moduleCode || "") === moduleCode;
            const matchSkill = !skill || splitSkills(job.requiredSkills).some(item => item.toLowerCase() === skill.toLowerCase());
            return matchKeyword && matchModule && matchSkill;
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
            const detailUrl = "job-detail.jsp?jobId=" + encodeURIComponent(job.jobId);
            const applyUrl = "apply.jsp?jobId=" + encodeURIComponent(job.jobId);
            const detailHref = detailUrl;
            const applyHref = IS_TA ? applyUrl : "index.jsp?login=1&redirect=" + encodeURIComponent(applyUrl);
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
                + "<a class=\"action-btn\" href=\"" + detailHref + "\">View Details</a>"
                + "<a class=\"action-btn primary\" href=\"" + applyHref + "\">Apply</a>"
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
            populateDynamicFilters();
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
    loadJobs();

    if (!IS_TA) {
        const loginRole = document.getElementById("loginRole");
        const loginDrop = document.getElementById("loginDrop");
        const signinToggle = document.getElementById("signinToggle");

        signinToggle.addEventListener("click", (event) => {
            event.stopPropagation();
            loginDrop.classList.toggle("show");
        });

        document.addEventListener("click", (event) => {
            if (!loginDrop.contains(event.target) && event.target !== signinToggle) {
                loginDrop.classList.remove("show");
            }
        });

        document.querySelectorAll("[data-login-role]").forEach((button) => {
            button.addEventListener("click", () => {
                document.querySelectorAll("[data-login-role]").forEach((item) => {
                    item.classList.remove("active");
                });
                button.classList.add("active");
                loginRole.value = button.getAttribute("data-login-role");
                document.getElementById("loginError").textContent = "";
            });
        });

        document.querySelectorAll("[data-demo-role]").forEach((button) => {
            button.addEventListener("click", () => {
                const role = button.getAttribute("data-demo-role");
                document.querySelectorAll("[data-login-role]").forEach((item) => {
                    item.classList.toggle("active", item.getAttribute("data-login-role") === role);
                });
                loginRole.value = role;
                document.getElementById("loginIdentifier").value = button.getAttribute("data-demo-id");
                document.getElementById("loginPassword").value = button.getAttribute("data-demo-pw");
                document.getElementById("loginError").textContent = "";
            });
        });
    }

    async function doLogin() {
        const role = document.getElementById("loginRole").value;
        const identifier = document.getElementById("loginIdentifier").value.trim();
        const password = document.getElementById("loginPassword").value;
        const error = document.getElementById("loginError");
        if (!identifier) {
            error.textContent = "Please enter your identifier.";
            return;
        }
        if (!password) {
            error.textContent = "Please enter your password.";
            return;
        }
        try {
            const response = await fetch("auth/login", {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({role, identifier, password})
            });
            const result = await response.json();
            if (!response.ok) {
                error.textContent = result.error || "Sign-in failed.";
                return;
            }
            window.location.href = result.redirect || "jobs.jsp";
        } catch (_) {
            error.textContent = "Network error. Please try again.";
        }
    }

    async function signOut() {
        await fetch("auth/logout", {method: "POST"});
        window.location.href = "index.jsp?login=1";
    }
</script>
</body>
</html>

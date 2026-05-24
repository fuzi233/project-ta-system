<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    boolean isTa = AuthSession.ROLE_TA.equalsIgnoreCase(role);
%>
<%
    String id = request.getParameter("id");

    String jobTitle = "Programming TA";
    String course = "Java Programming";
    String teacher = "Prof. Smith";
    String deadline = "Jan 25, 2024";
    String responsibilities = "<li>Assist in grading assignments</li>"
            + "<li>Hold weekly office hours</li>"
            + "<li>Support class activities</li>";
    String requiredSkills = "<li>Basic Java knowledge</li>"
            + "<li>Git version control</li>";
    String preferredExperience = "<li>Tutoring or TA experience</li>"
            + "<li>Familiarity with Eclipse IDE</li>";
    String workload = "8 - 10 hours per week";

    if ("2".equals(id)) {
        jobTitle = "Database TA";
        course = "Database Systems";
        teacher = "Prof. Zhang";
        deadline = "Jan 30, 2024";
        responsibilities = "<li>Support SQL lab sessions</li>"
                + "<li>Answer student questions in tutorials</li>"
                + "<li>Help mark database assignments</li>";
        requiredSkills = "<li>SQL and relational database basics</li>"
                + "<li>Knowledge of MySQL</li>";
        preferredExperience = "<li>Experience in database coursework</li>"
                + "<li>Good communication skills</li>";
        workload = "6 - 8 hours per week";
    } else if ("3".equals(id)) {
        jobTitle = "Web Development TA";
        course = "Web Technologies";
        teacher = "Prof. Lee";
        deadline = "Feb 5, 2024";
        responsibilities = "<li>Assist students with HTML/CSS/JavaScript</li>"
                + "<li>Support lab demonstrations</li>"
                + "<li>Help review web project submissions</li>";
        requiredSkills = "<li>HTML, CSS, JavaScript basics</li>"
                + "<li>Frontend debugging ability</li>";
        preferredExperience = "<li>Experience building web pages</li>"
                + "<li>Knowledge of responsive design</li>";
        workload = "7 - 9 hours per week";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= jobTitle %> - Job Detail</title>
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
            background: rgba(255,255,255,0.96);
        }

        .brand {
            font-size: 18px;
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
            padding: 26px 30px 34px;
        }

        .breadcrumb {
            font-size: 14px;
            color: var(--muted);
            margin-bottom: 16px;
        }

        .breadcrumb a {
            color: var(--muted);
            text-decoration: none;
        }

        .title {
            margin: 0 0 16px;
            font-size: 34px;
            font-weight: 800;
            color: #10213f;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin-bottom: 20px;
        }

        .layout {
            display: grid;
            grid-template-columns: 1fr 2fr 0.7fr;
            gap: 14px;
        }

        .panel {
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            overflow: hidden;
        }

        .panel-header {
            padding: 14px 18px;
            font-size: 16px;
            font-weight: 700;
            color: #16315b;
            border-bottom: 1px solid #e5ebf2;
            background: #f8fafc;
        }

        .panel-body {
            padding: 18px;
        }

        .job-name {
            margin: 0 0 14px;
            font-size: 20px;
            font-weight: 800;
            color: #1e293b;
        }

        .info-item {
            margin-bottom: 10px;
            font-size: 15px;
            color: var(--muted);
        }

        .section-title {
            margin: 0 0 8px;
            font-size: 17px;
            font-weight: 800;
            color: #16315b;
        }

        .detail-section {
            margin-bottom: 18px;
        }

        .detail-section ul {
            margin: 0;
            padding-left: 20px;
            color: var(--muted);
            font-size: 15px;
            line-height: 1.55;
        }

        .workload {
            font-size: 15px;
            color: var(--muted);
        }

        .action-col {
            display: flex;
            flex-direction: column;
            gap: 12px;
            padding: 18px 14px;
        }

        .action-btn {
            height: 44px;
            border-radius: 12px;
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-size: .95rem;
            font-weight: 600;
            text-decoration: none;
            display: flex;
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

        @media (max-width: 1100px) {
            .layout {
                grid-template-columns: 1fr;
            }

            .panel {
                min-height: auto;
            }

            .action-col {
                padding: 0;
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
                <a href="index.jsp?login=1">Sign In</a>
                <% } %>
            </nav>
        </header>

        <main class="content">
            <div class="breadcrumb">
                <a href="index.jsp">Home</a> &nbsp;›&nbsp;
                <a href="jobs.jsp">Job List</a> &nbsp;›&nbsp;
                Job Detail
            </div>

            <h1 class="title">Job Detail</h1>
            <div class="divider"></div>

            <div class="layout">
                <section class="panel">
                    <div class="panel-header">Job Info</div>
                    <div class="panel-body">
                        <h2 id="jobName" class="job-name"><%= jobTitle %></h2>
                        <div id="jobCourse" class="info-item">Course: <%= course %></div>
                        <div id="jobTeacher" class="info-item">Teacher: <%= teacher %></div>
                        <div id="jobDeadline" class="info-item">Deadline: <%= deadline %></div>
                    </div>
                </section>

                <section class="panel">
                    <div class="panel-header">Job Detail</div>
                    <div class="panel-body">
                        <div class="detail-section">
                            <h3 class="section-title">Responsibilities:</h3>
                            <ul id="jobResponsibilities"><%= responsibilities %></ul>
                        </div>

                        <div class="detail-section">
                            <h3 class="section-title">Required Skills:</h3>
                            <ul id="jobSkills"><%= requiredSkills %></ul>
                        </div>

                        <div class="detail-section">
                            <h3 class="section-title">Preferred Experience:</h3>
                            <ul id="jobExperience"><%= preferredExperience %></ul>
                        </div>

                        <div class="detail-section">
                            <h3 class="section-title">Weekly Workload</h3>
                            <div id="jobWorkload" class="workload"><%= workload %></div>
                        </div>
                    </div>
                </section>

                <section class="panel">
                    <div class="action-col">
                        <a id="applyLink" class="action-btn primary" href="apply.jsp?id=<%= id == null ? "1" : id %>">Apply Now</a>
                        <a class="action-btn" href="jobs.jsp">Back</a>
                    </div>
                </section>
            </div>
        </main>
    </div>
</div>
<script>
    const IS_TA = <%= isTa ? "true" : "false" %>;

    function escapeHtml(value) {
        return String(value ?? "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'", "&#39;");
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

    function legacyJobId(raw) {
        const value = String(raw || "").trim();
        if (/^job-\d+$/i.test(value)) {
            return value.toLowerCase();
        }
        if (/^\d+$/.test(value)) {
            return "job-" + value.padStart(3, "0");
        }
        return "";
    }

    function listItems(values, fallback) {
        const items = values
            .split(",")
            .map(item => item.trim())
            .filter(Boolean);
        if (items.length === 0) {
            return "<li>" + escapeHtml(fallback) + "</li>";
        }
        return items.map(item => "<li>" + escapeHtml(item) + "</li>").join("");
    }

    async function loadJobDetail() {
        const params = new URLSearchParams(window.location.search);
        const rawJobId = params.get("jobId") || params.get("id") || "";
        if (!rawJobId) {
            return;
        }

        const response = await fetch("/jobs?status=OPEN&page=1&size=500");
        if (!response.ok) {
            return;
        }
        const data = await response.json();
        const jobs = data.items || [];
        const exact = jobs.find(job => job.jobId === rawJobId);
        const mappedId = legacyJobId(rawJobId);
        const job = exact || jobs.find(item => item.jobId === mappedId);
        if (!job) {
            return;
        }

        document.title = job.title + " - Job Detail";
        document.getElementById("jobName").textContent = job.title;
        document.getElementById("jobCourse").textContent = "Module: " + (job.moduleCode || "-");
        document.getElementById("jobTeacher").textContent = "Job ID: " + job.jobId;
        document.getElementById("jobDeadline").textContent = job.applicationDeadline
            ? "Deadline: " + fmtDate(job.applicationDeadline)
            : "Created: " + fmtDate(job.createdAt);
        document.getElementById("jobResponsibilities").innerHTML =
            "<li>Support module teaching, tutorials, and coursework follow-up.</li>"
            + "<li>Assist with student questions and learning activities.</li>"
            + "<li>Coordinate with the module organizer on grading support.</li>";
        document.getElementById("jobSkills").innerHTML = listItems(job.requiredSkills || "", "No specific skills listed");
        document.getElementById("jobExperience").innerHTML =
            "<li>Relevant coursework or project experience is preferred.</li>"
            + "<li>Clear communication and reliable availability are preferred.</li>";
        document.getElementById("jobWorkload").textContent = job.hoursPerWeek
            ? job.hoursPerWeek + " hours per week"
            : "Workload to be confirmed";
        const applyUrl = "apply.jsp?jobId=" + encodeURIComponent(job.jobId);
        document.getElementById("applyLink").href = IS_TA
            ? applyUrl
            : "index.jsp?login=1&redirect=" + encodeURIComponent(applyUrl);
    }

    loadJobDetail();

    async function signOut() {
        await fetch("auth/logout", {method: "POST"});
        window.location.href = "index.jsp?login=1";
    }
</script>
</body>
</html>

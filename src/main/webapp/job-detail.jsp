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
    <title><%= jobTitle %> - Job Detail</title>
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
            padding: 30px 34px 40px;
        }

        .breadcrumb {
            font-size: 15px;
            color: #64748b;
            margin-bottom: 22px;
        }

        .breadcrumb a {
            color: #64748b;
            text-decoration: none;
        }

        .title {
            margin: 0 0 22px;
            font-size: 46px;
            font-weight: 800;
            color: #10213f;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin-bottom: 28px;
        }

        .layout {
            display: grid;
            grid-template-columns: 1fr 2.3fr 0.9fr;
            gap: 18px;
        }

        .panel {
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            overflow: hidden;
            min-height: 520px;
        }

        .panel-header {
            padding: 18px 20px;
            font-size: 18px;
            font-weight: 700;
            color: #334155;
            border-bottom: 1px solid #e5ebf2;
            background: #f8fafc;
        }

        .panel-body {
            padding: 22px 20px 24px;
        }

        .job-name {
            margin: 0 0 18px;
            font-size: 24px;
            font-weight: 800;
            color: #1e293b;
        }

        .info-item {
            margin-bottom: 14px;
            font-size: 18px;
            color: #475569;
        }

        .section-title {
            margin: 0 0 12px;
            font-size: 20px;
            font-weight: 800;
            color: #334155;
        }

        .detail-section {
            margin-bottom: 28px;
        }

        .detail-section ul {
            margin: 0;
            padding-left: 22px;
            color: #475569;
            font-size: 18px;
            line-height: 1.8;
        }

        .workload {
            font-size: 18px;
            color: #475569;
        }

        .action-col {
            display: flex;
            flex-direction: column;
            gap: 14px;
            padding: 28px 16px;
        }

        .action-btn {
            height: 52px;
            border-radius: 12px;
            border: 1px solid #ccd6e2;
            background: #fff;
            color: #334155;
            font-size: 16px;
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
            background: linear-gradient(135deg, #9db7d0 0%, #86a8c5 100%);
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
                            <h2 id="jobName" class="job-name">Loading...</h2>
                            <div id="jobModule" class="info-item">Module: -</div>
                            <div id="jobStatus" class="info-item">Status: -</div>
                            <div id="jobCreatedAt" class="info-item">Posted At: -</div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="panel-header">Job Detail</div>
                        <div class="panel-body">
                            <div class="detail-section">
                            <h3 class="section-title">Summary</h3>
                            <ul id="jobSummaryList">
                                <li>Loading job details...</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h3 class="section-title">Required Skills:</h3>
                            <ul id="requiredSkillsList">
                                <li>-</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h3 class="section-title">Application Notes:</h3>
                            <ul id="applicationNotesList">
                                <li>Check role fit, skill evidence and schedule before applying.</li>
                            </ul>
                        </div>

                        <div class="detail-section">
                            <h3 class="section-title">Slots</h3>
                            <div id="jobSlots" class="workload">-</div>
                        </div>
                    </div>
                </section>

                <section class="panel">
                    <div class="action-col">
                        <a id="applyNowBtn" class="action-btn primary" href="apply.jsp">Apply Now</a>
                        <a class="action-btn" href="#">Save</a>
                        <a class="action-btn" href="jobs.jsp">Back</a>
                    </div>
                </section>
            </div>
        </main>
    </div>
</div>
<script>
    const params = new URLSearchParams(window.location.search);
    const jobId = params.get("jobId") || "";

    const ui = {
        jobName: document.getElementById("jobName"),
        jobModule: document.getElementById("jobModule"),
        jobStatus: document.getElementById("jobStatus"),
        jobCreatedAt: document.getElementById("jobCreatedAt"),
        jobSummaryList: document.getElementById("jobSummaryList"),
        requiredSkillsList: document.getElementById("requiredSkillsList"),
        applicationNotesList: document.getElementById("applicationNotesList"),
        jobSlots: document.getElementById("jobSlots"),
        applyNowBtn: document.getElementById("applyNowBtn")
    };

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

    function renderList(target, values, fallbackText) {
        target.innerHTML = "";
        const list = values.filter(Boolean);
        if (!list.length) {
            const item = document.createElement("li");
            item.textContent = fallbackText;
            target.appendChild(item);
            return;
        }
        list.forEach((value) => {
            const item = document.createElement("li");
            item.textContent = value;
            target.appendChild(item);
        });
    }

    async function loadJobDetail() {
        if (!jobId) {
            ui.jobName.textContent = "Missing jobId";
            return;
        }
        const data = await api("/jobs?status=OPEN&page=1&size=500&q=" + encodeURIComponent(jobId));
        const job = (data.items || []).find((item) => item.jobId === jobId);
        if (!job) {
            throw new Error("Job not found: " + jobId);
        }

        document.title = job.title + " - Job Detail";
        ui.jobName.textContent = job.title + " (" + job.jobId + ")";
        ui.jobModule.textContent = "Module: " + (job.moduleCode || "-");
        ui.jobStatus.textContent = "Status: " + (job.status || "-");
        ui.jobCreatedAt.textContent = "Posted At: " + fmtDate(job.createdAt);
        ui.jobSlots.textContent = String(job.slots ?? "-");
        ui.applyNowBtn.href = "apply.jsp?jobId=" + encodeURIComponent(job.jobId);

        renderList(
            ui.jobSummaryList,
            [
                "Support module " + (job.moduleCode || "-") + " as a teaching assistant.",
                "Coordinate with the module owner and help maintain a stable course workflow.",
                "Prepare concrete evidence for required skills before applying."
            ],
            "No summary available."
        );
        renderList(
            ui.requiredSkillsList,
            String(job.requiredSkills || "").split(",").map((item) => item.trim()),
            "No required skills provided."
        );
        renderList(
            ui.applicationNotesList,
            [
                "Review the required skills carefully.",
                "Check your current workload before applying.",
                "Upload CV/transcript in the application form if available."
            ],
            "No notes available."
        );
    }

    loadJobDetail().catch((error) => {
        ui.jobName.textContent = error.message;
        ui.jobSummaryList.innerHTML = "<li>Unable to load this job.</li>";
        ui.requiredSkillsList.innerHTML = "<li>-</li>";
        ui.applicationNotesList.innerHTML = "<li>-</li>";
        ui.jobSlots.textContent = "-";
    });
</script>
</body>
</html>

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
    <title>Job Detail - TA Recruit</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 1rem;
        }

        .detail-side {
            display: flex;
            flex-direction: column;
            gap: .8rem;
        }

        .info-item {
            margin-bottom: .6rem;
            font-size: .95rem;
            color: var(--text);
        }

        .section-title {
            margin: 0 0 .6rem;
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text);
        }

        .detail-section {
            margin-bottom: 1.4rem;
        }

        .detail-section ul {
            margin: 0;
            padding-left: 1.2rem;
            color: var(--muted);
            font-size: .92rem;
            line-height: 1.8;
        }

        @media (max-width: 860px) {
            .detail-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="shell">
    <a class="link" href="jobs.jsp">&larr; Back to Job List</a>

    <section class="glass card">
        <h1 id="jobName">Loading...</h1>
        <p class="subtitle">
            <span id="jobModule">Module: -</span> &middot;
            <span id="jobStatus">Status: -</span> &middot;
            <span id="jobCreatedAt">Posted At: -</span>
        </p>
    </section>

    <section class="detail-grid">
        <div class="glass card">
            <h2>Job Info</h2>
            <div class="detail-section">
                <h3 class="section-title">Summary</h3>
                <ul id="jobSummaryList"><li>Loading job details...</li></ul>
            </div>
            <div class="detail-section">
                <h3 class="section-title">Slots</h3>
                <p id="jobSlots">-</p>
            </div>
        </div>
        <div class="detail-side">
            <div class="glass card">
                <h2>Required Skills</h2>
                <ul id="requiredSkillsList"><li>-</li></ul>
            </div>
            <div class="glass card">
                <h2>Application Notes</h2>
                <ul id="applicationNotesList"><li>Check role fit, skill evidence and schedule before applying.</li></ul>
            </div>
            <a id="applyNowBtn" class="btn" href="apply.jsp" style="text-align:center;text-decoration:none;">Apply Now</a>
        </div>
    </section>
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

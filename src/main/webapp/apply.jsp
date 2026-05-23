<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_TA.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<%
    String jobTitle = "TA Application";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply - <%= jobTitle %></title>
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
            font-size: 44px;
            font-weight: 800;
            color: #10213f;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin-bottom: 26px;
        }

        .form-layout {
            display: grid;
            grid-template-columns: 1fr 1.8fr 0.75fr;
            gap: 16px;
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
            padding: 20px;
        }

        .field {
            margin-bottom: 22px;
        }

        .field label {
            display: block;
            font-size: 16px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 8px;
        }

        .input,
        .textarea,
        .select,
        .file-input {
            width: 100%;
            border: 1px solid #ced8e3;
            border-radius: 10px;
            padding: 12px 14px;
            font-size: 16px;
            color: #334155;
            background: #fff;
        }

        .file-upload {
            position: relative;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            width: 100%;
        }

        .file-input {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
        }

        .file-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 150px;
            height: 46px;
        }

        .file-upload .file-name {
            margin: 0;
            flex: 1;
            pointer-events: none;
        }

        .textarea {
            min-height: 120px;
            resize: vertical;
            font-family: inherit;
        }

        .hint {
            margin-top: 8px;
            font-size: 14px;
            color: #6b7280;
        }

        .action-col {
            display: flex;
            flex-direction: column;
            gap: 14px;
            padding: 18px 16px;
        }

        .action-btn {
            height: 52px;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .footer-actions {
            display: flex;
            gap: 14px;
            margin-top: 18px;
        }

        .footer-btn {
            min-width: 170px;
            height: 52px;
            cursor: pointer;
        }

        .success-box {
            display: none;
            margin-top: 22px;
            padding: 16px 18px;
            border-radius: 12px;
            background: #edf6ee;
            border: 1px solid #cfe4d1;
            color: #2f5d34;
            font-size: 16px;
            font-weight: 600;
        }

        .file-name {
            margin-top: 6px;
            font-size: 14px;
            color: #475569;
            display: none;
        }

        .upload-status {
            margin-top: 16px;
            border-radius: 12px;
            border: 1px solid #dbe3ec;
            padding: 12px 14px;
            background: #f8fafc;
            font-size: 14px;
            color: #334155;
            display: none;
        }

        .upload-status ul {
            margin: 8px 0 0;
            padding-left: 18px;
        }

        .upload-status .status-ok {
            color: #2f5d34;
            font-weight: 600;
        }

        .upload-status .status-fail {
            color: #8e2d2d;
            font-weight: 600;
        }

        .job-summary {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .job-summary h3 {
            margin: 0 0 6px;
            font-size: 18px;
            color: #334155;
        }

        .job-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 8px;
            font-size: 15px;
            color: #475569;
        }

        .job-list li {
            padding: 8px 10px;
            border-radius: 10px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
        }

        @media (max-width: 1100px) {
            .form-layout {
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

            .footer-actions {
                flex-direction: column;
            }

            .footer-btn {
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
            <div class="breadcrumb">
                <a href="index.jsp">Home</a> &nbsp;›&nbsp;
                <a href="jobs.jsp">Job List</a> &nbsp;›&nbsp;
                Apply
            </div>

            <h1 id="pageTitle" class="title"><%= jobTitle %> Application Form</h1>
            <div class="divider"></div>

            <form id="applyForm" onsubmit="submitApplication(event)">
                <div class="form-layout">
                    <section class="panel">
                        <div class="panel-header">Personal Information</div>
                        <div class="panel-body">
                            <div class="field">
                                <label for="fullName">Full Name</label>
                                <input class="input" type="text" id="fullName" name="fullName">
                            </div>

                            <div class="field">
                                <label for="studentId">Student ID</label>
                                <input class="input" type="text" id="studentId" name="studentId">
                            </div>

                            <div class="field">
                                <label for="email">Email</label>
                                <input class="input" type="email" id="email" name="email" placeholder="example@student.com">
                            </div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="panel-header">Skills and Experience</div>
                        <div class="panel-body">
                            <div class="field">
                                <label for="skills">Skills</label>
                                <select class="select" id="skills" name="skills" multiple>
                                    <option value="">Select skills...</option>
                                    <option>Java</option>
                                    <option>SQL</option>
                                    <option>HTML/CSS</option>
                                    <option>JavaScript</option>
                                    <option>Git</option>
                                </select>
                                <div class="hint">Hold Ctrl (Windows) or Cmd (Mac) to select multiple skills.</div>
                            </div>

                            <div class="field">
                                <label for="experience">Experience</label>
                                <textarea class="textarea" id="experience" name="experience"
                                          placeholder="Describe your relevant experience..."></textarea>
                            </div>

                            <div class="field">
                                <label for="cvFile">Upload CV</label>
                                <div class="file-upload">
                                    <button class="btn ghost file-button" type="button">Choose File</button>
                                    <input class="file-input" type="file" id="cvFile" name="cvFile" aria-label="Choose CV file">
                                    <div id="cvFileName" class="file-name">No file selected</div>
                                </div>
                            </div>

                            <div class="field">
                                <label for="transcriptFile">Upload Transcript</label>
                                <div class="file-upload">
                                    <button class="btn ghost file-button" type="button">Choose File</button>
                                    <input class="file-input" type="file" id="transcriptFile" name="transcriptFile" aria-label="Choose transcript file">
                                    <div id="transcriptFileName" class="file-name">No file selected</div>
                                </div>
                                <div class="hint">Accepted formats: PDF, DOC, DOCX</div>
                            </div>

                            <div class="footer-actions">
                                <button class="footer-btn btn" type="submit">Submit Application</button>
                                <button class="footer-btn btn ghost" type="reset">Cancel</button>
                            </div>

                            <div id="successBox" class="success-box">
                                Application submitted successfully.
                            </div>
                            <div id="errorBox" class="success-box" style="display:none;background:#fdecec;border-color:#f2c7c7;color:#8e2d2d;">
                                Submission failed.
                            </div>
                            <div id="uploadStatus" class="upload-status"></div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="panel-header">Selected Jobs</div>
                        <div class="panel-body job-summary">
                            <h3 id="jobCount">0 jobs selected</h3>
                            <ul id="jobList" class="job-list"></ul>
                            <a class="action-btn btn ghost" href="jobs.jsp">Back to Job List</a>
                        </div>
                    </section>
                </div>
            </form>
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

    function parseJobIdsFromUrl() {
        const params = new URLSearchParams(window.location.search);
        const jobIdParams = params.getAll("jobId");
        const idParam = params.get("id");
        const rawList = [];
        if (jobIdParams.length) {
            jobIdParams.forEach((item) => {
                const parts = String(item || "").split(",");
                parts.forEach((p) => {
                    const trimmed = p.trim();
                    if (trimmed) {
                        rawList.push(trimmed);
                    }
                });
            });
        }
        if (!rawList.length && idParam) {
            rawList.push(idParam);
        }
        return rawList;
    }

    function mapLegacyIdToJobId(raw) {
        if (!raw) {
            return "";
        }
        const trimmed = String(raw).trim();
        if (/^job-\d+$/i.test(trimmed)) {
            return trimmed.toLowerCase();
        }
        if (/^\d+$/.test(trimmed)) {
            return "job-" + trimmed.padStart(3, "0");
        }
        return "";
    }

    function mapCandidateToJobId(candidate, jobs) {
        const mapped = mapLegacyIdToJobId(candidate);
        if (mapped && jobs.some((job) => job.jobId === mapped)) {
            return mapped;
        }
        if (/^\d+$/.test(String(candidate || ""))) {
            const index = Number(candidate) - 1;
            if (index >= 0 && index < jobs.length) {
                return jobs[index].jobId;
            }
        }
        return "";
    }

    async function resolveJobIds() {
        const params = new URLSearchParams(window.location.search);
        const jobsData = await api("/jobs?status=OPEN&page=1&size=200");
        const jobs = jobsData.items || [];
        if (jobs.length === 0) {
            throw new Error("No open jobs available now.");
        }
        const requested = parseJobIdsFromUrl();
        const resolved = [];
        for (const cand of requested) {
            const mapped = mapCandidateToJobId(cand, jobs);
            if (mapped && !resolved.includes(mapped)) {
                resolved.push(mapped);
            }
        }
        if (!resolved.length) {
            resolved.push(jobs[0].jobId);
        }
        return {
            jobIds: resolved,
            jobs: jobs
        };
    }

    function renderJobSummary(selectedJobs) {
        const jobCountEl = document.getElementById("jobCount");
        const listEl = document.getElementById("jobList");
        jobCountEl.textContent = selectedJobs.length + " jobs selected";
        listEl.innerHTML = "";
        selectedJobs.forEach((job) => {
            const item = document.createElement("li");
            item.textContent = job.title + " (" + job.jobId + ")";
            listEl.appendChild(item);
        });
        const titleEl = document.getElementById("pageTitle");
        if (selectedJobs.length === 1) {
            titleEl.textContent = selectedJobs[0].title + " Application Form";
        } else {
            titleEl.textContent = "Multi-job Application Form";
        }
    }

    function loadProfileDraft() {
        const raw = localStorage.getItem("taApplicationProfile");
        if (!raw) {
            return;
        }
        try {
            const data = JSON.parse(raw);
            if (data.fullName) {
                document.getElementById("fullName").value = data.fullName;
            }
            if (data.studentId) {
                document.getElementById("studentId").value = data.studentId;
            }
            if (data.email) {
                document.getElementById("email").value = data.email;
            }
        } catch (_) {
            localStorage.removeItem("taApplicationProfile");
        }
    }

    function saveProfileDraft() {
        const payload = {
            fullName: document.getElementById("fullName").value.trim(),
            studentId: document.getElementById("studentId").value.trim(),
            email: document.getElementById("email").value.trim()
        };
        localStorage.setItem("taApplicationProfile", JSON.stringify(payload));
    }

    function updateFileName(inputId, labelId) {
        const input = document.getElementById(inputId);
        const label = document.getElementById(labelId);
        if (!input || !label) {
            return;
        }
        if (!input.files || input.files.length === 0) {
            label.textContent = "No file selected";
            return;
        }
        const names = Array.from(input.files).map((file) => file.name);
        label.textContent = names.join(", ");
    }

    function normalizeAttachmentResult(item, fallbackName) {
        if (!item && fallbackName) {
            return {name: fallbackName, ok: true, message: "Uploaded"};
        }
        if (typeof item === "string") {
            return {name: item, ok: true, message: "Uploaded"};
        }
        if (typeof item === "object") {
            const name = item.fileName || item.filename || item.name || fallbackName || "Attachment";
            const statusRaw = (item.status || "").toUpperCase();
            const ok = item.success === true || statusRaw === "SUCCESS" || statusRaw === "UPLOADED";
            const message = item.error || item.message || (ok ? "Uploaded" : "Upload failed");
            return {name: name, ok: ok, message: message};
        }
        return {name: fallbackName || "Attachment", ok: false, message: "Upload failed"};
    }

    function renderUploadStatus(jobId, results) {
        const box = document.getElementById("uploadStatus");
        const title = document.createElement("div");
        title.innerHTML = "Job " + jobId + ":";
        const list = document.createElement("ul");
        results.forEach((item) => {
            const li = document.createElement("li");
            const statusClass = item.ok ? "status-ok" : "status-fail";
            li.innerHTML = "<span class='" + statusClass + "'>" + (item.ok ? "Uploaded" : "Failed") + "</span> "
                + item.name + (item.message ? (" - " + item.message) : "");
            list.appendChild(li);
        });
        box.appendChild(title);
        box.appendChild(list);
        box.style.display = "block";
    }

    async function submitApplication(event) {
        event.preventDefault();

        const form = document.getElementById("applyForm");
        const submitButtons = form.querySelectorAll("button[type='submit']");
        const successBox = document.getElementById("successBox");
        const errorBox = document.getElementById("errorBox");
        const uploadStatusBox = document.getElementById("uploadStatus");
        const fullName = document.getElementById("fullName").value.trim();
        const studentId = document.getElementById("studentId").value.trim();
        const email = document.getElementById("email").value.trim();
        const skills = Array.from(document.getElementById("skills").selectedOptions)
            .map((opt) => opt.value)
            .filter((val) => val && val.trim());
        const experience = document.getElementById("experience").value.trim();

        if (!fullName) {
            alert("Please enter your full name.");
            return;
        }

        if (!studentId) {
            alert("Please enter your student ID.");
            return;
        }

        if (!email) {
            alert("Please enter your email.");
            return;
        }

        if (!skills.length) {
            alert("Please select at least one skill.");
            return;
        }

        if (!experience) {
            alert("Please fill in your experience.");
            return;
        }

        const resolved = await resolveJobIds();
        const jobIds = resolved.jobIds;
        if (!jobIds.length) {
            alert("Please select at least one job before applying.");
            return;
        }
        const confirmMessage = "Submit applications for " + jobIds.length + " jobs?";
        if (!window.confirm(confirmMessage)) {
            return;
        }

        successBox.style.display = "none";
        errorBox.style.display = "none";
        uploadStatusBox.style.display = "none";
        uploadStatusBox.innerHTML = "";
        submitButtons.forEach((btn) => {
            btn.disabled = true;
        });

        try {
            saveProfileDraft();
            const fileInputs = {
                cv: document.getElementById("cvFile"),
                transcript: document.getElementById("transcriptFile")
            };
            const selectedFiles = [
                fileInputs.cv && fileInputs.cv.files.length ? fileInputs.cv.files[0].name : "",
                fileInputs.transcript && fileInputs.transcript.files.length ? fileInputs.transcript.files[0].name : ""
            ].filter(Boolean);

            let successCount = 0;
            for (const jobId of jobIds) {
                const formData = new FormData(form);
                formData.set("jobId", jobId);
                const response = await fetch("/applications", {
                    method: "POST",
                    body: formData
                });
                const text = await response.text();
                let result = {};
                try {
                    result = text ? JSON.parse(text) : {};
                } catch (_) {
                    result = {error: text || ("HTTP " + response.status)};
                }
                if (!response.ok) {
                    throw new Error(result.error || ("HTTP " + response.status));
                }

                const attachmentResults = [];
                if (Array.isArray(result.attachments) && result.attachments.length) {
                    result.attachments.forEach((item) => {
                        attachmentResults.push(normalizeAttachmentResult(item, ""));
                    });
                } else if (selectedFiles.length) {
                    selectedFiles.forEach((name) => {
                        attachmentResults.push(normalizeAttachmentResult(null, name));
                    });
                } else {
                    attachmentResults.push({name: "No attachments", ok: true, message: "Not provided"});
                }
                renderUploadStatus(jobId, attachmentResults);
                successCount++;
            }

            successBox.textContent = "Submitted " + successCount + " application(s) successfully. Redirecting...";
            successBox.style.display = "block";
            setTimeout(function () {
                window.location.href = "applications.jsp";
            }, 1000);
        } catch (error) {
            errorBox.textContent = error.message;
            errorBox.style.display = "block";
        } finally {
            submitButtons.forEach((btn) => {
                btn.disabled = false;
            });
        }
    }

    async function boot() {
        loadProfileDraft();
        updateFileName("cvFile", "cvFileName");
        updateFileName("transcriptFile", "transcriptFileName");
        document.getElementById("cvFile").addEventListener("change", () => {
            updateFileName("cvFile", "cvFileName");
        });
        document.getElementById("transcriptFile").addEventListener("change", () => {
            updateFileName("transcriptFile", "transcriptFileName");
        });
        ["fullName", "studentId", "email"].forEach((id) => {
            const input = document.getElementById(id);
            input.addEventListener("change", saveProfileDraft);
            input.addEventListener("blur", saveProfileDraft);
        });

        try {
            const resolved = await resolveJobIds();
            const selectedJobs = resolved.jobs.filter((job) => resolved.jobIds.includes(job.jobId));
            renderJobSummary(selectedJobs);
        } catch (_) {
            renderJobSummary([]);
        }
    }

    boot();
</script>
</body>
</html>

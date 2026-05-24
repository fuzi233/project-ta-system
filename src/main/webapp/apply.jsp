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
    String id = request.getParameter("id");

    String jobTitle = "Programming TA";
    if ("2".equals(id)) {
        jobTitle = "Database TA";
    } else if ("3".equals(id)) {
        jobTitle = "Web Development TA";
    }
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
            color: #16315b;
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
            color: #16315b;
            margin-bottom: 8px;
        }

        .profile-summary {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 22px;
        }

        .readonly-row {
            border: 1px solid #d9e2ec;
            border-radius: 12px;
            background: #f8fbff;
            padding: 12px 14px;
        }

        .readonly-label {
            margin-bottom: 4px;
            font-size: 13px;
            font-weight: 700;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.02em;
        }

        .readonly-value {
            color: #16315b;
            font-size: 16px;
            font-weight: 700;
            word-break: break-word;
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
            color: #16315b;
            background: #fff;
        }

        .textarea {
            min-height: 120px;
            resize: vertical;
            font-family: inherit;
        }

        .hint {
            margin-top: 8px;
            font-size: 15px;
            color: #6b7280;
        }

        .file-input {
            display: none;
        }

        .upload-shell {
            border: 1px solid #ced8e3;
            border-radius: 16px;
            background: linear-gradient(180deg, #ffffff 0%, #f8fbff 100%);
            padding: 16px 18px;
        }

        .upload-row {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
        }

        .upload-btn {
            min-width: 148px;
            height: 48px;
            border-radius: 12px;
            border: none;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff !important;
            cursor: pointer;
            display: inline-flex;
            align-items: stretch;
            justify-content: stretch;
            padding: 0 20px;
            transition: all 0.2s ease;
            box-sizing: border-box;
            vertical-align: top;
        }

        .upload-btn.is-selected {
            background: linear-gradient(135deg, rgba(225, 244, 239, 0.98), rgba(214, 239, 255, 0.98));
            border: 1px solid #9fd8c9;
            color: #175b63;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.6);
        }

        .upload-btn-text {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            white-space: nowrap;
            font-size: 15px;
            font-weight: 700;
            line-height: 1;
            color: #fff !important;
        }

        .upload-btn.is-selected .upload-btn-text {
            color: #175b63 !important;
        }

        .upload-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .upload-name {
            flex: 1;
            min-width: 180px;
            font-size: 15px;
            color: var(--muted);
            font-weight: 500;
            padding: 0;
        }

        .file-status {
            display: none;
            word-break: break-word;
        }

        .field-error {
            display: none;
            margin-top: 10px;
            padding: 10px 12px;
            border-radius: 10px;
            background: #fff7f7;
            border: 1px solid #f1d2d2;
            font-size: 14px;
            color: #9a4a4a;
        }

        .action-col {
            display: flex;
            flex-direction: column;
            gap: 14px;
            padding: 18px 16px;
        }

        .action-btn {
            height: 52px;
            border-radius: 12px;
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
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

        .btn-text {
            text-align: center;
            white-space: nowrap;
        }

        .footer-actions {
            display: flex;
            gap: 14px;
            margin-top: 18px;
        }

        .footer-btn {
            min-width: 170px;
            height: 52px;
            border-radius: 12px;
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-size: .95rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 20px;
            transition: all 0.2s ease;
        }

        .footer-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .footer-btn.primary {
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            border: none;
        }

        .action-btn:disabled,
        .footer-btn:disabled {
            background: #d8e1ef !important;
            border-color: #d8e1ef !important;
            color: #7a8aa3 !important;
            box-shadow: none !important;
            transform: none !important;
        }

        .result-box {
            display: none;
            margin-top: 22px;
            padding: 18px;
            border-radius: 14px;
            border: 1px solid #d9e2ec;
            background: #f8fafc;
        }

        .result-box.success {
            background: #edf6ee;
            border-color: #cfe4d1;
        }

        .result-box.partial {
            background: #fff8eb;
            border-color: #efd9a7;
        }

        .result-box.error {
            background: #fdf1f1;
            border-color: #e8c4c4;
        }

        .result-title {
            margin: 0 0 14px;
            font-size: 17px;
            font-weight: 700;
            color: #16315b;
        }

        .result-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .result-item {
            border-radius: 10px;
            padding: 12px 14px;
            font-size: 14px;
            line-height: 1.5;
            border: 1px solid transparent;
            background: rgba(255, 255, 255, 0.7);
        }

        .result-item strong {
            color: #1e293b;
        }

        .result-item.success {
            color: #2f5d34;
            border-color: #cfe4d1;
            background: #f4fbf5;
        }

        .result-item.error {
            color: #9a4a4a;
            border-color: #e8c4c4;
            background: #fff7f7;
        }

        .result-item.info {
            color: #1f5f8b;
            border-color: #bdd8f6;
            background: #eef6ff;
        }

        .result-actions {
            display: flex;
            gap: 12px;
            margin-top: 16px;
            flex-wrap: wrap;
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
<div class="bg-orb orb-a"></div>
<div class="bg-orb orb-b"></div>
<div class="page">
    <div class="shell">
        <header class="topbar">
            <div class="brand">TA Recruitment System</div>
            <nav class="nav">
                <a href="jobs.jsp" class="active">Job List</a>
                <a href="applications.jsp">My Applications</a>
                <a href="profile.jsp">Profile</a>
                <a href="javascript:void(0)" onclick="signOut()">Sign Out</a>
            </nav>
        </header>

        <main class="content">
            <div class="breadcrumb">
                <a href="index.jsp">Home</a> &nbsp;›&nbsp;
                <a href="jobs.jsp">Job List</a> &nbsp;›&nbsp;
                <span id="applyBreadcrumbTitle">Apply for <%= jobTitle %></span>
            </div>

            <h1 id="applyPageTitle" class="title"><%= jobTitle %> Application Form</h1>
            <div class="divider"></div>

            <form id="applyForm" onsubmit="submitApplication(event)">
                <div class="form-layout">
                    <section class="panel">
                        <div class="panel-header">Personal Information</div>
                        <div class="panel-body">
                            <input type="hidden" id="fullName" name="fullName">
                            <input type="hidden" id="studentId" name="studentId">
                            <div class="profile-summary">
                                <div class="readonly-row">
                                    <div class="readonly-label">Full Name</div>
                                    <div id="fullNameText" class="readonly-value">Loading...</div>
                                </div>
                                <div class="readonly-row">
                                    <div class="readonly-label">Student ID</div>
                                    <div id="studentIdText" class="readonly-value">Loading...</div>
                                </div>
                            </div>

                            <div class="field">
                                <label for="email">Email</label>
                                <input class="input" type="email" id="email" name="email" placeholder="example@bupt.edu.cn" required>
                                <div id="emailError" class="field-error"></div>
                            </div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="panel-header">Skills and Experience</div>
                        <div class="panel-body">
                            <div class="field">
                                <label for="skills">Skills</label>
                                <select class="select" id="skills" name="skills">
                                    <option value="">Select skills...</option>
                                </select>
                            </div>

                            <div class="field">
                                <label for="experience">Experience</label>
                                <textarea class="textarea" id="experience" name="experience"
                                          placeholder="Describe your relevant experience..."></textarea>
                            </div>

                            <div class="field">
                                <label for="cvFile">Upload CV</label>
                                <div class="upload-shell">
                                    <div class="upload-row">
                                        <label id="cvUploadBtn" class="upload-btn" for="cvFile"><span class="upload-btn-text">Choose File</span></label>
                                        <div id="cvFileName" class="upload-name">No file chosen</div>
                                    </div>
                                    <input class="file-input" type="file" id="cvFile" name="cvFile">
                                </div>
                                <div id="cvFileStatus" class="file-status"></div>
                                <div id="cvFileError" class="field-error"></div>
                            </div>

                            <div class="field">
                                <label for="transcriptFile">Upload Transcript</label>
                                <div class="upload-shell">
                                    <div class="upload-row">
                                        <label id="transcriptUploadBtn" class="upload-btn" for="transcriptFile"><span class="upload-btn-text">Choose File</span></label>
                                        <div id="transcriptFileName" class="upload-name">No file chosen</div>
                                    </div>
                                    <input class="file-input" type="file" id="transcriptFile" name="transcriptFile">
                                </div>
                                <div class="hint">Accepted formats: PDF, DOC, DOCX</div>
                                <div id="transcriptFileStatus" class="file-status"></div>
                                <div id="transcriptFileError" class="field-error"></div>
                            </div>

                            <div class="footer-actions">
                                <button class="footer-btn primary" type="submit"><span class="btn-text">Submit Application</span></button>
                                <button class="footer-btn" type="reset"><span class="btn-text">Cancel</span></button>
                            </div>

                            <div id="resultBox" class="result-box">
                                <h2 class="result-title">Submission Result</h2>
                                <div id="resultList" class="result-list"></div>
                                <div class="result-actions">
                                    <a id="viewApplicationsBtn" class="action-btn primary" href="applications.jsp" style="display:none;"><span class="btn-text">View My Applications</span></a>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="action-col">
                            <a class="action-btn" href="jobs.jsp"><span class="btn-text">Back</span></a>
                        </div>
                    </section>
                </div>
            </form>
        </main>
    </div>
</div>

<script>
    const acceptedFileExtensions = [".pdf", ".doc", ".docx"];
    let applicationSubmitted = false;
    let applicationSubmitting = false;
    let preferredProfileSkill = "";

    function escapeHtml(value) {
        return String(value ?? "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'", "&#39;");
    }

    function updateFileStatus(inputId, nameId, errorId, buttonId) {
        const input = document.getElementById(inputId);
        const name = document.getElementById(nameId);
        const error = document.getElementById(errorId);
        const button = document.getElementById(buttonId);
        const buttonText = button ? button.querySelector(".upload-btn-text") : null;
        const file = input.files[0];

        error.textContent = "";
        error.style.display = "none";

        if (!file) {
            name.textContent = "No file chosen";
            if (button) {
                button.classList.remove("is-selected");
            }
            if (buttonText) {
                buttonText.textContent = "Choose File";
            }
            return;
        }

        name.textContent = file.name;
        if (button) {
            button.classList.add("is-selected");
        }
        if (buttonText) {
            buttonText.textContent = "File Selected";
        }
    }

    function resetFileFeedback() {
        document.getElementById("cvFileName").textContent = "No file chosen";
        document.getElementById("transcriptFileName").textContent = "No file chosen";
        document.getElementById("cvUploadBtn").classList.remove("is-selected");
        document.getElementById("transcriptUploadBtn").classList.remove("is-selected");
        document.getElementById("cvUploadBtn").querySelector(".upload-btn-text").textContent = "Choose File";
        document.getElementById("transcriptUploadBtn").querySelector(".upload-btn-text").textContent = "Choose File";
        document.getElementById("cvFileError").textContent = "";
        document.getElementById("cvFileError").style.display = "none";
        document.getElementById("transcriptFileError").textContent = "";
        document.getElementById("transcriptFileError").style.display = "none";
        hideResultBox();
    }

    function hideResultBox() {
        const resultBox = document.getElementById("resultBox");
        const resultList = document.getElementById("resultList");
        const viewApplicationsBtn = document.getElementById("viewApplicationsBtn");

        resultBox.style.display = "none";
        resultBox.className = "result-box";
        resultList.innerHTML = "";
        viewApplicationsBtn.style.display = "none";
    }

    function addResultItem(label, message, type) {
        const resultList = document.getElementById("resultList");
        const item = document.createElement("div");
        item.className = "result-item " + type;
        item.innerHTML = "<strong>" + label + ":</strong> " + message;
        resultList.appendChild(item);
    }

    function getFileValidationResult(file, requiredLabel) {
        if (!file) {
            return {
                ok: false,
                message: requiredLabel + " file is required before submitting."
            };
        }

        const fileName = file.name.toLowerCase();
        const isAccepted = acceptedFileExtensions.some(ext => fileName.endsWith(ext));

        if (!isAccepted) {
            return {
                ok: false,
                message: "Only PDF, DOC, and DOCX files are accepted."
            };
        }

        return {
            ok: true,
            message: file.name
        };
    }

    function isEmailValid(value) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(value || "").trim());
    }

    function setEmailError(message) {
        const error = document.getElementById("emailError");
        error.textContent = message || "";
        error.style.display = message ? "block" : "none";
    }

    function splitSkills(value) {
        return String(value || "")
            .split(/[,;\/|]+/)
            .map(item => item.trim())
            .filter(Boolean);
    }

    function populateSkillOptions(jobs, preferredSkill) {
        const select = document.getElementById("skills");
        const current = preferredSkill || select.value;
        const skills = [...new Set((jobs || []).flatMap(job => splitSkills(job.requiredSkills)))].sort((a, b) => a.localeCompare(b));
        select.innerHTML = "<option value=\"\">Select skills...</option>"
            + skills.map(skill => "<option value=\"" + escapeHtml(skill) + "\">" + escapeHtml(skill) + "</option>").join("");
        if (skills.includes(current)) {
            select.value = current;
        }
    }

    async function loadApplicantProfile() {
        try {
            const profile = await api("/auth/me");
            document.getElementById("fullName").value = profile.displayName || "";
            document.getElementById("studentId").value = profile.identifier || "";
            document.getElementById("email").value = profile.email || "";
            document.getElementById("fullNameText").textContent = profile.displayName || "-";
            document.getElementById("studentIdText").textContent = profile.identifier || "-";
            preferredProfileSkill = profile.skills || "";
            if (profile.resumeText && !document.getElementById("experience").value.trim()) {
                document.getElementById("experience").value = profile.resumeText;
            }
        } catch (_) {
            document.getElementById("fullNameText").textContent = "-";
            document.getElementById("studentIdText").textContent = "-";
        }
    }

    document.getElementById("cvFile").addEventListener("change", function () {
        updateFileStatus("cvFile", "cvFileName", "cvFileError", "cvUploadBtn");
    });

    document.getElementById("transcriptFile").addEventListener("change", function () {
        updateFileStatus("transcriptFile", "transcriptFileName", "transcriptFileError", "transcriptUploadBtn");
    });

    document.getElementById("email").addEventListener("input", function () {
        const email = document.getElementById("email").value.trim();
        setEmailError(!email || isEmailValid(email) ? "" : "Please enter a valid email address.");
    });

    document.getElementById("applyForm").addEventListener("reset", function () {
        setTimeout(resetFileFeedback, 0);
    });

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

    async function loadJobHeader() {
        const params = new URLSearchParams(window.location.search);
        const candidate = String(params.get("jobId") || params.get("id") || "").trim();
        if (!candidate) {
            return;
        }
        try {
            const jobsData = await api("/jobs?status=OPEN&page=1&size=500");
            const jobs = jobsData.items || [];
            populateSkillOptions(jobs, preferredProfileSkill);
            const exact = jobs.find((job) => job.jobId === candidate);
            const mapped = mapLegacyIdToJobId(candidate);
            const job = exact || jobs.find((item) => item.jobId === mapped);
            if (!job) {
                return;
            }
            document.title = "Apply - " + job.title;
            document.getElementById("applyBreadcrumbTitle").textContent = "Apply for " + job.title;
            document.getElementById("applyPageTitle").textContent = job.title + " Application Form";
        } catch (_) {
            // Keep the server-rendered fallback title if the job list cannot be loaded.
        }
    }

    async function resolveJobId() {
        const params = new URLSearchParams(window.location.search);
        const candidate = params.get("jobId") || params.get("id") || "";
        const trimmedCandidate = String(candidate || "").trim();
        const jobsData = await api("/jobs?status=OPEN&page=1&size=200");
        const jobs = jobsData.items || [];

        if (jobs.length === 0) {
            throw new Error("No open jobs available now.");
        }

        if (trimmedCandidate && jobs.some((job) => job.jobId === trimmedCandidate)) {
            return trimmedCandidate;
        }

        const mapped = mapLegacyIdToJobId(trimmedCandidate);
        if (mapped && jobs.some((job) => job.jobId === mapped)) {
            return mapped;
        }

        if (/^\d+$/.test(String(candidate || ""))) {
            const index = Number(candidate) - 1;
            if (index >= 0 && index < jobs.length) {
                return jobs[index].jobId;
            }
        }

        return jobs[0].jobId;
    }

    async function submitApplication(event) {
        event.preventDefault();
        if (applicationSubmitted || applicationSubmitting) {
            return;
        }

        const form = document.getElementById("applyForm");
        const fullName = document.getElementById("fullName").value.trim();
        const studentId = document.getElementById("studentId").value.trim();
        const email = document.getElementById("email").value.trim();
        const skills = document.getElementById("skills").value.trim();
        const experience = document.getElementById("experience").value.trim();
        const submitButtons = document.querySelectorAll('button[type="submit"]');
        const cvFile = document.getElementById("cvFile").files[0];
        const transcriptFile = document.getElementById("transcriptFile").files[0];
        const cvValidation = getFileValidationResult(cvFile, "CV");
        const transcriptValidation = getFileValidationResult(transcriptFile, "Transcript");
        let hasBlockingError = false;

        hideResultBox();
        document.getElementById("cvFileError").textContent = "";
        document.getElementById("cvFileError").style.display = "none";
        document.getElementById("transcriptFileError").textContent = "";
        document.getElementById("transcriptFileError").style.display = "none";
        setEmailError("");

        if (!fullName) {
            alert("Please enter your full name.");
            return;
        }

        if (!studentId) {
            alert("Please enter your student ID.");
            return;
        }

        if (!email) {
            setEmailError("Email is required.");
            return;
        }

        if (!isEmailValid(email)) {
            setEmailError("Please enter a valid email address.");
            return;
        }

        if (!skills) {
            alert("Please select at least one skill.");
            return;
        }

        if (!experience) {
            alert("Please fill in your experience.");
            return;
        }

        if (!cvValidation.ok) {
            document.getElementById("cvFileError").textContent = cvValidation.message;
            document.getElementById("cvFileError").style.display = "block";
            hasBlockingError = true;
        }

        if (!transcriptValidation.ok) {
            document.getElementById("transcriptFileError").textContent = transcriptValidation.message;
            document.getElementById("transcriptFileError").style.display = "block";
            hasBlockingError = true;
        }

        const resultBox = document.getElementById("resultBox");
        const viewApplicationsBtn = document.getElementById("viewApplicationsBtn");
        resultBox.style.display = "block";

        if (hasBlockingError) {
            resultBox.className = "result-box error";
            addResultItem("Application", "Application not submitted. Please fix the file errors below and try again.", "error");
            addResultItem("CV", cvValidation.ok ? "File selected and ready: " + cvValidation.message : cvValidation.message, cvValidation.ok ? "info" : "error");
            addResultItem("Transcript", transcriptValidation.ok ? "File selected and ready: " + transcriptValidation.message : transcriptValidation.message, transcriptValidation.ok ? "info" : "error");
            return;
        }

        if (!window.confirm("Submit this application now? You cannot submit it again after it is sent.")) {
            hideResultBox();
            return;
        }

        applicationSubmitting = true;
        submitButtons.forEach(button => {
            button.disabled = true;
            if (button.classList.contains("primary")) {
                button.dataset.originalText = button.textContent;
                button.textContent = "Submitting...";
            }
        });

        try {
            const jobId = await resolveJobId();
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

            const attachments = Array.isArray(result.attachments) ? result.attachments : [];
            const attachmentMap = {};
            attachments.forEach(item => {
                if (item && item.attachmentType) {
                    attachmentMap[String(item.attachmentType).toLowerCase()] = item;
                }
            });

            const cvResult = attachmentMap.cv;
            const transcriptResult = attachmentMap.transcript;
            const allAttachmentSucceeded = Boolean(cvResult) && Boolean(transcriptResult);

            resultBox.className = allAttachmentSucceeded ? "result-box success" : "result-box partial";

            if (result.created === false) {
                addResultItem("Application", "Application already exists. Current application status: Pending review.", "info");
            } else {
                addResultItem("Application", "Application submitted successfully. Current application status: Pending review.", "success");
            }

            addResultItem(
                "CV",
                cvResult
                    ? "Uploaded successfully: " + (cvResult.originalFilename || (cvFile ? cvFile.name : "CV file"))
                    : "Upload failed: The CV file was not saved successfully.",
                cvResult ? "success" : "error"
            );

            addResultItem(
                "Transcript",
                transcriptResult
                    ? "Uploaded successfully: " + (transcriptResult.originalFilename || (transcriptFile ? transcriptFile.name : "Transcript file"))
                    : "Upload failed: The transcript file was not saved successfully.",
                transcriptResult ? "success" : "error"
            );

            viewApplicationsBtn.style.display = "inline-flex";
            applicationSubmitted = true;
        } catch (error) {
            resultBox.className = "result-box error";
            addResultItem("Application", error.message, "error");
            addResultItem("CV", "Upload not completed.", "error");
            addResultItem("Transcript", "Upload not completed.", "error");
            applicationSubmitting = false;
        } finally {
            submitButtons.forEach(button => {
                button.disabled = applicationSubmitted;
                if (button.dataset.originalText) {
                    button.textContent = applicationSubmitted ? "Submitted" : button.dataset.originalText;
                }
            });
        }
    }

    loadApplicantProfile().finally(loadJobHeader);

    async function signOut() {
        await fetch("auth/logout", {method: "POST"});
        window.location.href = "index.jsp?login=1";
    }
</script>
</body>
</html>

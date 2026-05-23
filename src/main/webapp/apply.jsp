<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_TA.equalsIgnoreCase(role)) {
        String qs = request.getQueryString();
        String target = "apply.jsp" + (qs != null ? "?" + qs : "");
        response.sendRedirect("index.jsp?redirect=" + java.net.URLEncoder.encode(target, "UTF-8"));
        return;
    }
%>
<%
    String jobIdsParam = request.getParameter("jobIds");
    String singleId = request.getParameter("jobId");
    String legacyId = request.getParameter("id");
    String effectiveJobIds = jobIdsParam;
    if (effectiveJobIds == null || effectiveJobIds.isBlank()) {
        if (singleId != null && !singleId.isBlank()) effectiveJobIds = singleId;
        else if (legacyId != null && !legacyId.isBlank()) effectiveJobIds = legacyId;
    }
    int jobCount = 0;
    if (effectiveJobIds != null && !effectiveJobIds.isBlank()) {
        jobCount = effectiveJobIds.split(",").length;
    }
    String pageTitle = "Apply";
    if (jobCount == 1) {
        pageTitle = "Apply for " + effectiveJobIds.trim();
    } else if (jobCount > 1) {
        pageTitle = "Apply for " + jobCount + " Jobs";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - TA Recruit</title>
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

        .chip-group {
            display: flex;
            flex-wrap: wrap;
            gap: .5rem;
        }
        .skill-chip {
            border: 1px solid #c2d6ff;
            border-radius: 9999px;
            padding: .45rem .85rem;
            font-size: .85rem;
            background: rgba(255,255,255,.85);
            color: #16315b;
            cursor: pointer;
            transition: all 120ms ease;
            user-select: none;
            font-weight: 500;
        }
        .skill-chip.selected {
            border-color: #1575ff;
            background: linear-gradient(135deg, #1575ff, #0094ff);
            color: #fff;
            font-weight: 700;
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
            <div class="breadcrumb">
                <a href="index.jsp">Home</a> &nbsp;›&nbsp;
                <a href="jobs.jsp">Job List</a> &nbsp;›&nbsp;
                <span id="breadcrumbLabel"><%= pageTitle %></span>
            </div>

            <h1 id="pageTitle" class="title"><%= pageTitle %> Application Form</h1>
            <div class="divider"></div>

            <div id="jobsSummary" class="selection-bar" style="display:none;">
                <span id="jobsSummaryText"></span>
            </div>

            <form id="applyForm" novalidate>
                <div class="form-layout">
                    <section class="panel">
                        <div class="panel-header">Personal Information</div>
                        <div class="panel-body">
                            <div class="field">
                                <label for="fullName">Full Name</label>
                                <input class="input" type="text" id="fullName" name="fullName" placeholder="Enter your full name">
                                <div class="field-error" id="fullNameError"></div>
                            </div>

                            <div class="field">
                                <label for="studentId">Student ID</label>
                                <input class="input" type="text" id="studentId" name="studentId" placeholder="e.g. 2023213149">
                                <div class="field-error" id="studentIdError"></div>
                            </div>

                            <div class="field">
                                <label for="email">Email</label>
                                <input class="input" type="email" id="email" name="email" placeholder="example@student.com">
                                <div class="field-error" id="emailError"></div>
                            </div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="panel-header">Skills and Experience</div>
                        <div class="panel-body">
                            <div class="field">
                                <label>Skills <span style="font-weight:400;color:var(--muted);font-size:.82rem;">(click to select)</span></label>
                                <div class="chip-group" id="skillChips"></div>
                                <div class="field-error" id="skillsError"></div>
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
                                <button id="submitBtn" class="footer-btn primary" type="submit"><span class="btn-text">Submit Application</span></button>
                                <a class="footer-btn" href="jobs.jsp" style="text-decoration:none;"><span class="btn-text">Back to Job List</span></a>
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
                </div>
            </form>
        </main>
    </div>
</div>

<script>
    var acceptedFileExtensions = [".pdf", ".doc", ".docx"];
    var STORAGE_KEY = "ta_apply_profile";
    var SKILL_OPTIONS = ["Java", "SQL", "HTML/CSS", "JavaScript", "Git", "Python", "C/C++", "Data Analysis", "Machine Learning", "Algorithms", "Communication"];

    var state = {
        jobIds: [],
        jobDetails: [],
        selectedSkills: []
    };

    // ---- Skill chips ----
    function buildSkillChips() {
        var container = document.getElementById("skillChips");
        SKILL_OPTIONS.forEach(function(skill) {
            var chip = document.createElement("span");
            chip.className = "skill-chip";
            chip.textContent = skill;
            chip.addEventListener("click", function() {
                chip.classList.toggle("selected");
                var idx = state.selectedSkills.indexOf(skill);
                if (idx >= 0) { state.selectedSkills.splice(idx, 1); }
                else { state.selectedSkills.push(skill); }
                document.getElementById("skillsError").textContent = "";
            });
            container.appendChild(chip);
        });
    }

    // ---- Auto-fill from localStorage ----
    function loadProfile() {
        try {
            var stored = localStorage.getItem(STORAGE_KEY);
            if (stored) {
                var profile = JSON.parse(stored);
                if (profile.fullName) document.getElementById("fullName").value = profile.fullName;
                if (profile.studentId) document.getElementById("studentId").value = profile.studentId;
                if (profile.email) document.getElementById("email").value = profile.email;
            }
        } catch (_) {}
    }

    function saveProfile() {
        var profile = {
            fullName: document.getElementById("fullName").value.trim(),
            studentId: document.getElementById("studentId").value.trim(),
            email: document.getElementById("email").value.trim()
        };
        try { localStorage.setItem(STORAGE_KEY, JSON.stringify(profile)); } catch (_) {}
    }

    // ---- Parse jobIds from URL ----
    function parseJobIds() {
        var params = new URLSearchParams(window.location.search);
        var jobIdsParam = params.get("jobIds") || params.get("jobId") || params.get("id") || "";
        return jobIdsParam.split(",").map(function(s) { return s.trim(); }).filter(Boolean);
    }

    function mapLegacyIdToJobId(raw) {
        if (!raw) return "";
        var trimmed = String(raw).trim();
        if (/^job-\d+$/i.test(trimmed)) return trimmed.toLowerCase();
        if (/^\d+$/.test(trimmed)) return "job-" + trimmed.padStart(3, "0");
        return "";
    }

    // ---- Resolve job details ----
    async function resolveJobs() {
        var candidates = parseJobIds();
        var data = await api("/jobs?status=OPEN&page=1&size=200");
        var jobs = data.items || [];
        var resolved = [];
        var seen = {};

        candidates.forEach(function(c) {
            var mapped = mapLegacyIdToJobId(c);
            var match = jobs.find(function(j) { return j.jobId === mapped; }) ||
                        jobs.find(function(j) { return String(j.jobId).toLowerCase() === c.toLowerCase(); });
            if (match && !seen[match.jobId]) {
                resolved.push(match);
                seen[match.jobId] = true;
            }
        });

        if (!resolved.length && jobs.length) resolved = [jobs[0]];
        return resolved;
    }

    // ---- Update page heading ----
    function updateHeading() {
        var count = state.jobDetails.length;
        var title, breadcrumb;
        if (count === 1) {
            var j = state.jobDetails[0];
            title = "Apply for " + j.title + " (" + j.jobId + ")";
            breadcrumb = "Apply for " + j.title + " (" + j.jobId + ")";
        } else {
            title = "Apply for " + count + " Jobs";
            breadcrumb = "Apply for " + count + " Jobs";
        }
        document.getElementById("pageTitle").textContent = title + " Application Form";
        document.getElementById("breadcrumbLabel").textContent = breadcrumb;
        document.title = title + " - TA Recruit";

        var names = state.jobDetails.map(function(j) { return j.title + " (" + j.jobId + ")"; }).join(", ");
        document.getElementById("jobsSummary").style.display = "block";
        document.getElementById("jobsSummaryText").textContent = "Applying for " + count + (count === 1 ? " job: " : " jobs: ") + names;
    }

    // ---- UI helpers ----
    function showFieldError(fieldId, errorId, msg) {
        var field = document.getElementById(fieldId);
        var error = document.getElementById(errorId);
        if (msg) { error.textContent = msg; error.style.display = "block"; field.style.borderColor = "#EF4444"; }
        else { error.textContent = ""; error.style.display = "none"; field.style.borderColor = ""; }
    }

    function hideResultBox() {
        var rb = document.getElementById("resultBox");
        rb.style.display = "none";
        rb.className = "result-box";
        document.getElementById("resultList").innerHTML = "";
        document.getElementById("viewApplicationsBtn").style.display = "none";
    }

    function addResultItem(label, message, type) {
        var list = document.getElementById("resultList");
        var item = document.createElement("div");
        item.className = "result-item " + type;
        item.innerHTML = "<strong>" + label + ":</strong> " + message;
        list.appendChild(item);
    }

    function getFileValidationResult(file, label) {
        if (!file) return { ok: false, message: label + " file is required." };
        var ext = file.name.toLowerCase();
        var ok = acceptedFileExtensions.some(function(e) { return ext.endsWith(e); });
        return ok ? { ok: true, message: file.name } : { ok: false, message: "Only PDF, DOC, and DOCX files are accepted." };
    }

    // ---- File upload UI ----
    function updateFileStatus(inputId, nameId, errorId, buttonId) {
        var input = document.getElementById(inputId);
        var name = document.getElementById(nameId);
        var btn = document.getElementById(buttonId);
        var btnText = btn ? btn.querySelector(".upload-btn-text") : null;
        document.getElementById(errorId).textContent = "";
        document.getElementById(errorId).style.display = "none";
        if (!input.files[0]) {
            name.textContent = "No file chosen";
            if (btn) btn.classList.remove("is-selected");
            if (btnText) btnText.textContent = "Choose File";
            return;
        }
        name.textContent = input.files[0].name;
        if (btn) btn.classList.add("is-selected");
        if (btnText) btnText.textContent = "File Selected";
    }

    // ---- Validation ----
    function validateForm() {
        var ok = true;
        var fn = document.getElementById("fullName").value.trim();
        var sid = document.getElementById("studentId").value.trim();
        var em = document.getElementById("email").value.trim();
        var exp = document.getElementById("experience").value.trim();

        if (!fn) { showFieldError("fullName", "fullNameError", "Please enter your full name."); ok = false; }
        else showFieldError("fullName", "fullNameError", "");

        if (!sid) { showFieldError("studentId", "studentIdError", "Please enter your student ID."); ok = false; }
        else showFieldError("studentId", "studentIdError", "");

        if (!em) { showFieldError("email", "emailError", "Please enter your email."); ok = false; }
        else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(em)) { showFieldError("email", "emailError", "Invalid email format."); ok = false; }
        else showFieldError("email", "emailError", "");

        if (state.selectedSkills.length === 0) { document.getElementById("skillsError").textContent = "Please select at least one skill."; ok = false; }
        else document.getElementById("skillsError").textContent = "";

        return ok;
    }

    // ---- Submit ----
    async function submitApplication(event) {
        event.preventDefault();
        var form = event.target;

        if (!validateForm()) return;

        var cvFile = document.getElementById("cvFile").files[0];
        var transcriptFile = document.getElementById("transcriptFile").files[0];
        var cvVal = getFileValidationResult(cvFile, "CV");
        var trVal = getFileValidationResult(transcriptFile, "Transcript");

        if (!cvVal.ok) { document.getElementById("cvFileError").textContent = cvVal.message; document.getElementById("cvFileError").style.display = "block"; return; }
        if (!trVal.ok) { document.getElementById("transcriptFileError").textContent = trVal.message; document.getElementById("transcriptFileError").style.display = "block"; return; }

        var count = state.jobDetails.length;
        if (!confirm("Submit applications for " + count + (count === 1 ? " job?" : " jobs?"))) return;

        saveProfile();
        hideResultBox();

        var submitBtn = document.getElementById("submitBtn");
        submitBtn.disabled = true;
        submitBtn.querySelector(".btn-text").textContent = "Submitting...";

        var resultBox = document.getElementById("resultBox");
        resultBox.style.display = "block";
        var totalCreated = 0, totalSkipped = 0, totalUploaded = 0, failed = [];

        for (var i = 0; i < state.jobDetails.length; i++) {
            var jobId = state.jobDetails[i].jobId;
            var fd = new FormData(form);
            fd.set("jobId", jobId);
            fd.set("skills", state.selectedSkills.join(","));
            try {
                var resp = await fetch("/applications", { method: "POST", body: fd });
                var text = await resp.text();
                var r = {};
                try { r = text ? JSON.parse(text) : {}; } catch (_) { r = {error: text}; }
                if (!resp.ok) throw new Error(r.error || "HTTP " + resp.status);

                if (r.created === false) totalSkipped++;
                else totalCreated++;

                var atts = Array.isArray(r.attachments) ? r.attachments : [];
                atts.forEach(function(a) { if (a && a.attachmentType) totalUploaded++; });

            } catch (e) {
                failed.push(jobId + ": " + e.message);
            }
        }

        if (failed.length) {
            resultBox.className = "result-box partial";
            addResultItem("Summary", totalCreated + " created, " + totalSkipped + " existed, " + failed.length + " failed", "error");
            failed.forEach(function(f) { addResultItem("Failed", f, "error"); });
        } else {
            resultBox.className = "result-box success";
            var msg = totalCreated + " application(s) submitted";
            if (totalSkipped > 0) msg += ", " + totalSkipped + " already existed";
            if (totalUploaded > 0) msg += " (" + totalUploaded + " attachment(s) uploaded)";
            addResultItem("Summary", msg, "success");
            document.getElementById("viewApplicationsBtn").style.display = "inline-flex";
        }

        submitBtn.disabled = false;
        submitBtn.querySelector(".btn-text").textContent = "Submit Application";
    }

    // ---- Init ----
    document.getElementById("cvFile").addEventListener("change", function() {
        updateFileStatus("cvFile", "cvFileName", "cvFileError", "cvUploadBtn");
    });
    document.getElementById("transcriptFile").addEventListener("change", function() {
        updateFileStatus("transcriptFile", "transcriptFileName", "transcriptFileError", "transcriptUploadBtn");
    });
    document.getElementById("applyForm").addEventListener("submit", submitApplication);

    async function api(url, options) {
        options = options || {};
        var resp = await fetch(url, { headers: {"Content-Type": "application/json"}, ...options });
        var text = await resp.text();
        var body = {};
        try { body = text ? JSON.parse(text) : {}; } catch (_) { body = {error: text || ("HTTP " + resp.status)}; }
        if (!resp.ok) throw new Error(body.error || ("HTTP " + resp.status));
        return body;
    }

    buildSkillChips();
    loadProfile();
    resolveJobs().then(function(jobs) {
        state.jobDetails = jobs;
        updateHeading();
    }).catch(function(e) {
        document.getElementById("jobsSummaryText").textContent = e.message;
        document.getElementById("jobsSummary").style.display = "block";
    });
</script>
</body>
</html>

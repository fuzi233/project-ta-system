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
    String selectedJobIds = request.getParameter("jobIds");
    String selectedJobId = request.getParameter("jobId");
    String pageLabel = "Selected Job";
    if (selectedJobIds != null && !selectedJobIds.isBlank()) {
        int selectedCount = selectedJobIds.split(",").length;
        pageLabel = selectedCount > 1 ? (selectedCount + " Selected Jobs") : "Selected Job";
    } else if (selectedJobId != null && !selectedJobId.isBlank()) {
        pageLabel = selectedJobId.trim();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply - <%= pageLabel %></title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        .apply-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .apply-full {
            grid-column: 1 / -1;
        }

        .apply-actions {
            display: flex;
            gap: .8rem;
            align-items: center;
            flex-wrap: wrap;
            margin-top: .5rem;
        }

        .field {
            margin-bottom: 1.1rem;
        }

        .field label {
            display: block;
            font-size: .9rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: .35rem;
        }

        textarea {
            min-height: 110px;
            resize: vertical;
            font-family: inherit;
        }

        .hint {
            margin-top: .3rem;
            font-size: .82rem;
            color: var(--muted);
        }

        .error-msg {
            min-height: 18px;
            margin-top: 4px;
            color: #EF4444;
            font-size: .8rem;
        }

        .success-box {
            display: none;
            margin-top: 1rem;
            padding: .9rem 1rem;
            border-radius: 12px;
            border: 1px solid #cfe4d1;
            background: #edf6ee;
            color: #2f5d34;
            font-size: .92rem;
            font-weight: 600;
        }

        .error-box {
            display: none;
            margin-top: .6rem;
            padding: .9rem 1rem;
            border-radius: 12px;
            border: 1px solid #f2c7c7;
            background: #fdecec;
            color: #8e2d2d;
            font-size: .92rem;
            font-weight: 600;
        }

        .chip-group {
            display: flex;
            flex-wrap: wrap;
            gap: .5rem;
        }

        .skill-chip {
            border: 1px solid #c2d6ff;
            border-radius: 9999px;
            padding: .5rem .9rem;
            font-size: .85rem;
            background: rgba(255,255,255,.85);
            color: #16315b;
            cursor: pointer;
            transition: all 120ms ease;
            user-select: none;
        }

        .skill-chip.selected {
            border-color: var(--primary);
            background: linear-gradient(135deg, #1575ff, #0094ff);
            color: #fff;
            font-weight: 700;
        }

        @media (max-width: 860px) {
            .apply-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<div class="shell">
    <a class="link" href="jobs.jsp">&larr; Back to Job List</a>

    <section class="glass card">
        <h1 id="applyTitle"><%= pageLabel %> Application Form</h1>
        <p id="selectionSummary" class="subtitle">Loading selected jobs...</p>
    </section>

    <form id="applyForm" novalidate>
        <section class="apply-grid">
            <div class="glass card">
                <h2>Personal Information</h2>
                <div class="field">
                    <label for="fullName">Full Name</label>
                    <input id="fullName" name="fullName" type="text" placeholder="Enter your full name" required/>
                    <div class="error-msg" id="fullNameError"></div>
                </div>
                <div class="field">
                    <label for="studentId">Student ID</label>
                    <input id="studentId" name="studentId" type="text" placeholder="e.g. 2023213149" required/>
                    <div class="error-msg" id="studentIdError"></div>
                </div>
                <div class="field">
                    <label for="email">Email</label>
                    <input id="email" name="email" type="email" placeholder="example@student.com" required/>
                    <div class="error-msg" id="emailError"></div>
                </div>
            </div>

            <div class="glass card">
                <h2>Skills & Experience</h2>
                <div class="field">
                    <label>Skills (click to select)</label>
                    <div class="chip-group" id="skillChips">
                    </div>
                    <div class="hint">Select at least one skill relevant to the position</div>
                    <div class="error-msg" id="skillsError"></div>
                </div>
                <div class="field">
                    <label for="experience">Experience</label>
                    <textarea id="experience" name="experience" placeholder="Describe your relevant experience, coursework, or projects..."></textarea>
                    <div class="error-msg" id="experienceError"></div>
                </div>
            </div>

            <div class="glass card apply-full">
                <h2>Attachments</h2>
                <div class="apply-grid">
                    <div class="field">
                        <label for="cvFile">Upload CV</label>
                        <input type="file" id="cvFile" name="cvFile"/>
                        <div class="hint">Accepted formats: PDF, DOC, DOCX</div>
                    </div>
                    <div class="field">
                        <label for="transcriptFile">Upload Transcript</label>
                        <input type="file" id="transcriptFile" name="transcriptFile"/>
                        <div class="hint">Accepted formats: PDF, DOC, DOCX</div>
                    </div>
                </div>
            </div>
        </section>

        <div class="apply-actions">
            <button id="submitApplicationBtn" class="btn" type="submit">Submit Application</button>
            <a class="btn ghost" href="jobs.jsp">Cancel</a>
        </div>

        <div id="successBox" class="success-box">Application submitted successfully.</div>
        <div id="errorBox" class="error-box">Submission failed.</div>
    </form>
</div>

<script>
    async function api(url, options = {}) {
        const response = await fetch(url, {
            headers: {"Content-Type": "application/json"},
            ...options
        });
        const text = await response.text();
        let body = {};
        try { body = text ? JSON.parse(text) : {}; } catch (_) { body = {error: text || ("HTTP " + response.status)}; }
        if (!response.ok) throw new Error(body.error || ("HTTP " + response.status));
        return body;
    }

    var applyState = { jobs: [], unresolvedCandidates: [], selectedSkills: [] };

    var SKILL_OPTIONS = ["Java", "SQL", "HTML/CSS", "JavaScript", "Git", "Python", "C/C++", "Data Structures", "Algorithms", "Communication"];

    function buildSkillChips() {
        var container = document.getElementById("skillChips");
        SKILL_OPTIONS.forEach(function(skill) {
            var chip = document.createElement("span");
            chip.className = "skill-chip";
            chip.textContent = skill;
            chip.addEventListener("click", function() {
                chip.classList.toggle("selected");
                var idx = applyState.selectedSkills.indexOf(skill);
                if (idx >= 0) {
                    applyState.selectedSkills.splice(idx, 1);
                } else {
                    applyState.selectedSkills.push(skill);
                }
                document.getElementById("skillsError").textContent = "";
            });
            container.appendChild(chip);
        });
    }

    function setFieldError(fieldId, errorId, message) {
        var field = document.getElementById(fieldId);
        var error = document.getElementById(errorId);
        if (message) {
            field.style.borderColor = "#EF4444";
            error.textContent = message;
        } else {
            field.style.borderColor = "";
            error.textContent = "";
        }
    }

    function validateForm() {
        var fullName = document.getElementById("fullName").value.trim();
        var studentId = document.getElementById("studentId").value.trim();
        var email = document.getElementById("email").value.trim();
        var experience = document.getElementById("experience").value.trim();
        var ok = true;

        if (!fullName) { setFieldError("fullName", "fullNameError", "Please enter your full name."); ok = false; }
        else { setFieldError("fullName", "fullNameError", ""); }

        if (!studentId) { setFieldError("studentId", "studentIdError", "Please enter your student ID."); ok = false; }
        else { setFieldError("studentId", "studentIdError", ""); }

        if (!email) { setFieldError("email", "emailError", "Please enter your email."); ok = false; }
        else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { setFieldError("email", "emailError", "Invalid email format."); ok = false; }
        else { setFieldError("email", "emailError", ""); }

        if (applyState.selectedSkills.length === 0) { document.getElementById("skillsError").textContent = "Please select at least one skill."; ok = false; }

        if (!experience) { setFieldError("experience", "experienceError", "Please fill in your experience."); ok = false; }
        else { setFieldError("experience", "experienceError", ""); }

        return ok;
    }

    function mapLegacyIdToJobId(raw) {
        if (!raw) return "";
        var trimmed = String(raw).trim();
        if (/^job-\d+$/i.test(trimmed)) return trimmed.toLowerCase();
        if (/^\d+$/.test(trimmed)) return "job-" + trimmed.padStart(3, "0");
        return "";
    }

    function parseRequestedJobCandidates() {
        var params = new URLSearchParams(window.location.search);
        var multiCandidates = (params.get("jobIds") || "").split(",").map(function(v) { return v.trim(); }).filter(Boolean);
        if (multiCandidates.length) return multiCandidates;
        var candidate = (params.get("jobId") || params.get("id") || "").trim();
        return candidate ? [candidate] : [];
    }

    async function resolveSelectedJobs() {
        var candidates = parseRequestedJobCandidates();
        var jobsData = await api("/jobs?status=OPEN&page=1&size=200");
        var jobs = jobsData.items || [];
        if (jobs.length === 0) throw new Error("No open jobs available now.");
        if (!candidates.length) return { jobs: [jobs[0]], unresolvedCandidates: [] };

        var resolvedJobs = [], unresolvedCandidates = [], seenJobIds = new Set();
        candidates.forEach(function(candidate) {
            var directMatch = jobs.find(function(job) { return String(job.jobId || "").toLowerCase() === candidate.toLowerCase(); });
            if (directMatch) { if (!seenJobIds.has(directMatch.jobId)) { resolvedJobs.push(directMatch); seenJobIds.add(directMatch.jobId); } return; }
            var mapped = mapLegacyIdToJobId(candidate);
            if (mapped) { var mj = jobs.find(function(j) { return j.jobId === mapped; }); if (mj && !seenJobIds.has(mj.jobId)) { resolvedJobs.push(mj); seenJobIds.add(mj.jobId); } return; }
            if (/^\d+$/.test(candidate)) { var idx = Number(candidate) - 1; if (idx >= 0 && idx < jobs.length) { var ij = jobs[idx]; if (!seenJobIds.has(ij.jobId)) { resolvedJobs.push(ij); seenJobIds.add(ij.jobId); } return; } }
            unresolvedCandidates.push(candidate);
        });
        if (!resolvedJobs.length) throw new Error("No selected jobs are available for application.");
        return { jobs: resolvedJobs, unresolvedCandidates: unresolvedCandidates };
    }

    function updateHeading() {
        var count = applyState.jobs.length;
        var label = count === 1 ? ("Apply for " + applyState.jobs[0].title + " (" + applyState.jobs[0].jobId + ")") : ("Apply for " + count + " Selected Jobs");
        document.getElementById("applyTitle").textContent = label + " Application Form";
        document.title = label + " - Application";
        document.getElementById("submitApplicationBtn").textContent = count > 1 ? "Submit Applications" : "Submit Application";
        var selList = applyState.jobs.map(function(j) { return j.title + " (" + j.jobId + ")"; }).join(", ");
        var summaryText = "Applying for " + count + (count === 1 ? " job: " : " jobs: ") + selList + ".";
        if (applyState.unresolvedCandidates.length) summaryText += " Skipped: " + applyState.unresolvedCandidates.join(", ") + ".";
        document.getElementById("selectionSummary").textContent = summaryText;
    }

    async function submitSingleApplication(form, jobId) {
        var formData = new FormData(form);
        formData.set("jobId", jobId);
        formData.set("skills", applyState.selectedSkills.join(","));
        var response = await fetch("/applications", { method: "POST", body: formData });
        var text = await response.text();
        var result = {};
        try { result = text ? JSON.parse(text) : {}; } catch (_) { result = {error: text || ("HTTP " + response.status)}; }
        if (!response.ok) throw new Error(result.error || ("HTTP " + response.status));
        return result;
    }

    async function submitApplication(event) {
        event.preventDefault();
        if (!validateForm()) return;
        if (!applyState.jobs.length) { document.getElementById("errorBox").textContent = "Please select a job from the job list first."; document.getElementById("errorBox").style.display = "block"; return; }

        var submitBtn = document.getElementById("submitApplicationBtn");
        var successBox = document.getElementById("successBox");
        var errorBox = document.getElementById("errorBox");
        successBox.style.display = "none";
        errorBox.style.display = "none";
        submitBtn.disabled = true;

        try {
            var created = 0, skipped = 0, uploaded = 0, failed = [];
            for (var i = 0; i < applyState.jobs.length; i++) {
                try {
                    var result = await submitSingleApplication(event.target, applyState.jobs[i].jobId);
                    if (result.created === false) skipped++; else created++;
                    uploaded += Array.isArray(result.attachments) ? result.attachments.length : 0;
                } catch (e) { failed.push(applyState.jobs[i].jobId + ": " + e.message); }
            }
            if (failed.length) throw new Error("Partial failure: " + failed.join(" | "));
            var msg = created + (created === 1 ? " application" : " applications") + " submitted";
            if (skipped > 0) msg += ", " + skipped + " already existed";
            if (uploaded > 0) msg += " (" + uploaded + " attachment(s))";
            successBox.textContent = msg + ". Redirecting...";
            successBox.style.display = "block";
            setTimeout(function() { window.location.href = "applications.jsp"; }, 1100);
        } catch (e) {
            errorBox.textContent = e.message;
            errorBox.style.display = "block";
        } finally { submitBtn.disabled = false; }
    }

    document.getElementById("applyForm").addEventListener("submit", submitApplication);

    buildSkillChips();
    resolveSelectedJobs().then(function(sel) {
        applyState.jobs = sel.jobs;
        applyState.unresolvedCandidates = sel.unresolvedCandidates;
        updateHeading();
    }).catch(function(e) {
        document.getElementById("selectionSummary").textContent = e.message;
    });
</script>
</body>
</html>

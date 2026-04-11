async function api(path, options = {}) {
    const response = await fetch(path, {
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

const ui = {
    detailName: document.getElementById("detailName"),
    detailUserId: document.getElementById("detailUserId"),
    detailIdentifier: document.getElementById("detailIdentifier"),
    detailEmail: document.getElementById("detailEmail"),
    detailStatus: document.getElementById("detailStatus"),
    detailSubmittedAt: document.getElementById("detailSubmittedAt"),
    detailJob: document.getElementById("detailJob"),
    detailModule: document.getElementById("detailModule"),
    detailSkills: document.getElementById("detailSkills"),
    detailResume: document.getElementById("detailResume"),
    aiScore: document.getElementById("aiScore"),
    aiReasoning: document.getElementById("aiReasoning"),
    aiMissingSkills: document.getElementById("aiMissingSkills"),
    aiSuggestions: document.getElementById("aiSuggestions"),
    aiHint: document.getElementById("aiHint"),
    aiAssessBtn: document.getElementById("aiAssessBtn")
};

const params = new URLSearchParams(window.location.search);
const candidateUserId = params.get("candidateUserId") || "";
const jobId = params.get("jobId") || "";

let detailState = {
    candidate: null,
    application: null,
    job: null
};

function fmtDate(value) {
    const t = Date.parse(value || "");
    if (Number.isNaN(t)) {
        return "-";
    }
    return new Date(t).toLocaleString("en-US", {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    });
}

function renderSkills(rawSkills) {
    ui.detailSkills.innerHTML = "";
    const tokens = String(rawSkills || "")
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean);
    if (!tokens.length) {
        ui.detailSkills.textContent = "-";
        return;
    }
    tokens.forEach((skill) => {
        const chip = document.createElement("span");
        chip.className = "chip";
        chip.textContent = skill;
        ui.detailSkills.appendChild(chip);
    });
}

function renderMissingSkills(skills) {
    ui.aiMissingSkills.innerHTML = "";
    if (!skills || !skills.length) {
        ui.aiMissingSkills.textContent = "No missing skills.";
        return;
    }
    skills.forEach((skill) => {
        const chip = document.createElement("span");
        chip.className = "chip";
        chip.textContent = skill;
        ui.aiMissingSkills.appendChild(chip);
    });
}

function renderDetail() {
    const candidate = detailState.candidate || {};
    const application = detailState.application || {};
    const job = detailState.job || {};

    ui.detailName.textContent = candidate.displayName || candidate.applicantId || "-";
    ui.detailUserId.textContent = candidate.applicantId || candidate.userId || "-";
    ui.detailIdentifier.textContent = candidate.identifier || "-";
    ui.detailEmail.textContent = candidate.email || "-";
    ui.detailStatus.textContent = application.status || candidate.status || "-";
    ui.detailSubmittedAt.textContent = fmtDate(application.submittedAt || candidate.submittedAt);
    ui.detailJob.textContent = (job.title || "-") + " (" + (job.jobId || jobId || "-") + ")";
    ui.detailModule.textContent = job.moduleCode || "-";
    renderSkills(candidate.skills || "");
    ui.detailResume.textContent = candidate.resumeText || "No resume text submitted.";
}

async function loadDetail() {
    if (!candidateUserId || !jobId) {
        ui.detailResume.textContent = "Missing candidateUserId or jobId.";
        ui.aiAssessBtn.disabled = true;
        return;
    }

    try {
        const candidatesResp = await api("mo/candidates?jobId=" + encodeURIComponent(jobId) + "&page=1&size=500");
        const rows = candidatesResp.candidates || [];
        const candidate = rows.find((item) => item.applicantId === candidateUserId);
        if (!candidate) {
            throw new Error("Candidate not found under this job.");
        }

        const jobsResp = await api("jobs?page=1&size=500");
        const jobs = jobsResp.items || [];
        const job = jobs.find((item) => item.jobId === jobId) || {jobId: jobId, title: "-", moduleCode: "-"};

        detailState = {
            candidate: candidate,
            application: {
                applicationId: candidate.applicationId,
                status: candidate.status,
                submittedAt: candidate.submittedAt
            },
            job: job
        };
        renderDetail();
    } catch (error) {
        ui.detailResume.textContent = error.message;
        ui.aiAssessBtn.disabled = true;
    }
}

ui.aiAssessBtn.addEventListener("click", async () => {
    ui.aiAssessBtn.disabled = true;
    ui.aiHint.textContent = "Analyzing...";
    try {
        const match = await api("ai/match", {
            method: "POST",
            body: JSON.stringify({
                applicantId: candidateUserId,
                jobId: jobId
            })
        });
        const gaps = await api("ai/missing-skills", {
            method: "POST",
            body: JSON.stringify({
                applicantId: candidateUserId,
                jobId: jobId
            })
        });

        ui.aiScore.textContent = "Score: " + match.score + " | Workload: " + match.workload + " | Provider: " + (match.provider || "-");
        ui.aiReasoning.textContent = match.reasoning || "-";
        renderMissingSkills(gaps.missingSkills || []);
        ui.aiSuggestions.textContent = (gaps.summary || "") + "\n\n" + ((gaps.learningSuggestions || []).join("\n"));
        ui.aiHint.textContent = "Done";
    } catch (error) {
        ui.aiScore.textContent = error.message;
        ui.aiReasoning.textContent = "";
        ui.aiMissingSkills.textContent = "";
        ui.aiSuggestions.textContent = "";
        ui.aiHint.textContent = "Failed";
    } finally {
        ui.aiAssessBtn.disabled = false;
    }
});

loadDetail();

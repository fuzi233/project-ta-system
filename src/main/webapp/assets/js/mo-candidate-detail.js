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
    detailAttachments: document.getElementById("detailAttachments"),
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
const applicationId = params.get("applicationId") || "";

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
    renderAttachments(application.attachments || candidate.attachments || []);
}

function renderAttachments(attachments) {
    if (!attachments || attachments.length === 0) {
        ui.detailAttachments.textContent = "No attachment uploaded.";
        return;
    }
    ui.detailAttachments.innerHTML = "";
    ui.detailAttachments.classList.add("attachment-list");
    attachments.forEach((item) => {
        const line = document.createElement("div");
        line.className = "attachment-item";

        const name = item.originalFilename || "Unnamed file";
        const type = item.attachmentType || "-";
        const size = item.sizeBytes != null ? (item.sizeBytes + " bytes") : "-";
        const extracted = item.hasExtractedText ? "Text extracted" : "No extracted text";

        const main = document.createElement("div");
        main.className = "attachment-main";

        const meta = document.createElement("div");
        meta.className = "attachment-meta";

        const typePill = document.createElement("span");
        typePill.className = "attachment-pill";
        typePill.textContent = type;
        meta.appendChild(typePill);

        const sizePill = document.createElement("span");
        sizePill.className = "attachment-pill";
        sizePill.textContent = size;
        meta.appendChild(sizePill);

        const extractedPill = document.createElement("span");
        extractedPill.className = "attachment-pill" + (item.hasExtractedText ? " ready" : "");
        extractedPill.textContent = extracted;
        meta.appendChild(extractedPill);

        if (item.attachmentId) {
            const link = document.createElement("a");
            link.href = "attachments/download?attachmentId=" + encodeURIComponent(item.attachmentId);
            link.target = "_blank";
            link.rel = "noopener noreferrer";
            link.textContent = name;
            link.className = "attachment-link";
            main.appendChild(link);

            const actionLink = document.createElement("a");
            actionLink.href = link.href;
            actionLink.target = "_blank";
            actionLink.rel = "noopener noreferrer";
            actionLink.textContent = "Open";
            actionLink.className = "btn ghost attachment-open";
            line.appendChild(main);
            main.appendChild(meta);
            line.appendChild(actionLink);
        } else {
            const text = document.createElement("div");
            text.className = "attachment-link";
            text.textContent = name;
            main.appendChild(text);
            main.appendChild(meta);
            line.appendChild(main);
        }
        ui.detailAttachments.appendChild(line);
    });
}

async function loadDetail() {
    if (!candidateUserId || !jobId) {
        ui.detailResume.textContent = "Missing candidateUserId or jobId.";
        ui.aiAssessBtn.disabled = true;
        return;
    }

    try {
        let detailPath = "mo/candidate-detail?jobId=" + encodeURIComponent(jobId)
            + "&candidateUserId=" + encodeURIComponent(candidateUserId);
        if (applicationId) {
            detailPath += "&applicationId=" + encodeURIComponent(applicationId);
        }
        const detailResp = await api(detailPath);
        const candidate = detailResp.candidate || {};
        const application = detailResp.application || {};
        const job = detailResp.job || {jobId: jobId, title: "-", moduleCode: "-"};

        detailState = {
            candidate: candidate,
            application: application,
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
        const assessment = await api("mo/candidate-assessment", {
            method: "POST",
            body: JSON.stringify({
                candidateUserId: candidateUserId,
                jobId: jobId
            })
        });
        const insight = assessment.insight || {};
        ui.aiScore.textContent = "Score: " + (insight.score ?? "-")
            + " | Workload: " + (insight.workload ?? "-")
            + " | Provider: " + (insight.provider || "-");
        ui.aiReasoning.textContent = insight.explanation || "-";
        renderMissingSkills(insight.missingSkills || []);
        ui.aiSuggestions.textContent = insight.resumeSummary || "-";
        if ((insight.provider || "").toLowerCase() === "rule-based") {
            ui.aiHint.textContent = "Done (rule-based fallback: AI provider unavailable or misconfigured)";
        } else {
            ui.aiHint.textContent = "Done (provider: " + (insight.provider || "-") + ")";
        }
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

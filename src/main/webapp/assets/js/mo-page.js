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

const state = {
    moUserId: document.body.dataset.moUserId || "",
    jobs: [],
    applicationsByJob: {},
    collapsedJobs: {},
    reviewStatus: ""
};

const createJobState = {
    selectedSkills: [],
    editingJobId: ""
};

const COMMON_SKILL_CANONICAL_ZH = {
    "C": "C",
    "C++": "C++",
    "Java": "Java",
    "Python": "Python",
    "JavaScript": "JavaScript",
    "SQL": "SQL",
    "HTML": "HTML",
    "CSS": "CSS",
    "Data Structures": "\u6570\u636e\u7ed3\u6784",
    "Algorithms": "\u7b97\u6cd5",
    "Machine Learning": "\u673a\u5668\u5b66\u4e60",
    "Deep Learning": "\u6df1\u5ea6\u5b66\u4e60",
    "Artificial Intelligence": "\u4eba\u5de5\u667a\u80fd",
    "Operating Systems": "\u64cd\u4f5c\u7cfb\u7edf",
    "Computer Networks": "\u8ba1\u7b97\u673a\u7f51\u7edc",
    "Database Systems": "\u6570\u636e\u5e93\u7cfb\u7edf",
    "Linux": "Linux",
    "Git": "Git",
    "MATLAB": "MATLAB",
    "Excel": "Excel",
    "Communication": "\u6c9f\u901a\u80fd\u529b",
    "Teaching": "\u6559\u5b66",
    "Lab Tutoring": "\u5b9e\u9a8c\u8f85\u5bfc",
    "Report Writing": "\u62a5\u544a\u5199\u4f5c"
};

const COMMON_SKILL_CANONICAL_EN = Object.fromEntries(
    Object.entries(COMMON_SKILL_CANONICAL_ZH).map(([en, zh]) => [zh, en])
);

const COMMON_SKILL_LOOKUP = {};
Object.keys(COMMON_SKILL_CANONICAL_ZH).forEach((skill) => {
    COMMON_SKILL_LOOKUP[skill.toLowerCase()] = skill;
});
Object.entries(COMMON_SKILL_CANONICAL_EN).forEach(([localizedLabel, canonicalLabel]) => {
    COMMON_SKILL_LOOKUP[localizedLabel.toLowerCase()] = canonicalLabel;
});

const tabReviewEl = document.getElementById("tabReview");
const tabCreateEl = document.getElementById("tabCreate");
const panelReviewEl = document.getElementById("panelReview");
const panelCreateEl = document.getElementById("panelCreate");
const reviewRefreshBtnEl = document.getElementById("reviewRefreshBtn");
const reviewHintEl = document.getElementById("reviewHint");
const reviewListEl = document.getElementById("reviewList");
const reviewJobSelectEl = document.getElementById("reviewJobSelect");
const reviewJobSearchEl = document.getElementById("reviewJobSearch");
const reviewJobOptionsEl = document.getElementById("reviewJobOptions");
const reviewClearFilterBtnEl = document.getElementById("reviewClearFilterBtn");
const reviewStatusFilterEls = Array.from(document.querySelectorAll("[data-review-status]"));
const reviewStatusCountEls = {
    all: document.querySelector("[data-review-count='all']"),
    submitted: document.querySelector("[data-review-count='submitted']"),
    interviewed: document.querySelector("[data-review-count='interviewed']"),
    accepted: document.querySelector("[data-review-count='accepted']"),
    rejected: document.querySelector("[data-review-count='rejected']")
};
const moJobFormEl = document.getElementById("mo-job-form");
const moOutputEl = document.getElementById("mo-output");
const commonSkillSelectEl = document.getElementById("commonSkillSelect");
const customSkillInputEl = document.getElementById("customSkillInput");
const addSkillBtnEl = document.getElementById("addSkillBtn");
const requiredSkillsInputEl = document.getElementById("requiredSkillsInput");
const selectedSkillsEl = document.getElementById("selectedSkills");
const jobFormTitleEl = document.getElementById("jobFormTitle");
const jobFormHelpEl = document.getElementById("jobFormHelp");
const jobSubmitBtnEl = document.getElementById("jobSubmitBtn");
const cancelEditJobBtnEl = document.getElementById("cancelEditJobBtn");

function switchTab(tabName) {
    const isReview = tabName === "review";
    if (isReview) {
        tabReviewEl.classList.add("active");
        tabCreateEl.classList.remove("active");
        panelReviewEl.classList.add("active");
        panelCreateEl.classList.remove("active");
        return;
    }
    tabReviewEl.classList.remove("active");
    tabCreateEl.classList.add("active");
    panelReviewEl.classList.remove("active");
    panelCreateEl.classList.add("active");
}

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

function fmtDateOnly(value) {
    const t = Date.parse(value || "");
    if (Number.isNaN(t)) {
        return "-";
    }
    return new Date(t).toLocaleDateString("en-US", {
        year: "numeric",
        month: "short",
        day: "numeric"
    });
}

function normalizeDeadlineInput(value) {
    const trimmed = (value || "").trim();
    const matched = trimmed.match(/^(\d{4})\/(\d{1,2})\/(\d{1,2})$/);
    if (!matched) {
        return "";
    }
    const year = Number(matched[1]);
    const month = Number(matched[2]);
    const day = Number(matched[3]);
    const parsed = new Date(year, month - 1, day);
    if (
        parsed.getFullYear() !== year
        || parsed.getMonth() !== month - 1
        || parsed.getDate() !== day
    ) {
        return "";
    }
    return year + "/" + String(month).padStart(2, "0") + "/" + String(day).padStart(2, "0");
}

function isDeadlineInPast(normalizedDeadline) {
    const matched = (normalizedDeadline || "").match(/^(\d{4})\/(\d{2})\/(\d{2})$/);
    if (!matched) {
        return true;
    }
    const deadline = new Date(Number(matched[1]), Number(matched[2]) - 1, Number(matched[3]));
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return deadline < today;
}

function setMoOutput(message, tone) {
    moOutputEl.textContent = message || "";
    moOutputEl.classList.remove("show", "success", "error");
    if (!message) {
        return;
    }
    moOutputEl.classList.add("show");
    if (tone) {
        moOutputEl.classList.add(tone);
    }
}

function syncRequiredSkillsInput() {
    requiredSkillsInputEl.value = createJobState.selectedSkills.join(",");
}

function normalizeSkill(rawSkill) {
    const trimmed = (rawSkill || "").trim();
    if (!trimmed) {
        return "";
    }
    return COMMON_SKILL_LOOKUP[trimmed.toLowerCase()] || trimmed;
}

function renderSelectedSkills() {
    selectedSkillsEl.innerHTML = "";
    if (!createJobState.selectedSkills.length) {
        const empty = document.createElement("span");
        empty.className = "empty-inline";
        empty.textContent = "No required skills selected yet.";
        selectedSkillsEl.appendChild(empty);
        syncRequiredSkillsInput();
        return;
    }

    createJobState.selectedSkills.forEach((skill) => {
        const chip = document.createElement("span");
        chip.className = "skill-chip";
        chip.textContent = skill;

        const removeBtn = document.createElement("button");
        removeBtn.type = "button";
        removeBtn.className = "skill-chip-remove";
        removeBtn.setAttribute("aria-label", "Remove " + skill);
        removeBtn.textContent = "x";
        removeBtn.addEventListener("click", () => {
            createJobState.selectedSkills = createJobState.selectedSkills.filter((item) => item !== skill);
            renderSelectedSkills();
        });
        chip.appendChild(removeBtn);
        selectedSkillsEl.appendChild(chip);
    });
    syncRequiredSkillsInput();
}

function addRequiredSkill(rawSkill) {
    const normalizedSkill = normalizeSkill(rawSkill);
    if (!normalizedSkill) {
        return false;
    }
    const exists = createJobState.selectedSkills.some((skill) => skill.toLowerCase() === normalizedSkill.toLowerCase());
    if (!exists) {
        createJobState.selectedSkills.push(normalizedSkill);
    }
    renderSelectedSkills();
    return true;
}

function clearSkillBuilder() {
    createJobState.selectedSkills = [];
    if (commonSkillSelectEl) {
        commonSkillSelectEl.value = "";
    }
    if (customSkillInputEl) {
        customSkillInputEl.value = "";
    }
    renderSelectedSkills();
}

function setRequiredSkillsFromValue(value) {
    createJobState.selectedSkills = [];
    String(value || "")
        .split(",")
        .map((skill) => skill.trim())
        .filter(Boolean)
        .forEach((skill) => addRequiredSkill(skill));
    renderSelectedSkills();
}

function setJobFormMode(job) {
    const isEditing = Boolean(job && job.jobId);
    createJobState.editingJobId = isEditing ? job.jobId : "";
    jobFormTitleEl.textContent = isEditing ? "Edit Job" : "Create New Job";
    jobFormHelpEl.textContent = isEditing
        ? "Update this job posting. Existing applications stay attached to the same Job ID."
        : "Create a new job posting with structured skills and workload details so the AI matching engine can score candidates more accurately.";
    jobSubmitBtnEl.textContent = isEditing ? "Update Job" : "Create Job";
    cancelEditJobBtnEl.style.display = isEditing ? "inline-flex" : "none";
    document.getElementById("jobIdInput").readOnly = isEditing;
}

function startEditJob(job) {
    switchTab("create");
    setJobFormMode(job);
    document.getElementById("jobIdInput").value = job.jobId || "";
    document.getElementById("jobTitleInput").value = job.title || "";
    document.getElementById("moduleCodeInput").value = job.moduleCode || "";
    document.getElementById("slotsInput").value = job.slots || "";
    document.getElementById("hoursPerWeekInput").value = job.hoursPerWeek || "";
    document.getElementById("applicationDeadlineInput").value = job.applicationDeadline || "";
    document.getElementById("monthlyStipendInput").value = job.monthlyStipend || "";
    setRequiredSkillsFromValue(job.requiredSkills || "");
    setMoOutput("Editing job " + (job.jobId || "") + ".", "");
}

function resetJobForm() {
    moJobFormEl.reset();
    clearSkillBuilder();
    setJobFormMode(null);
    setMoOutput("", "");
}

function populateCommonSkillOptions() {
    if (!commonSkillSelectEl) {
        return;
    }
    commonSkillSelectEl.innerHTML = "";
    const placeholder = document.createElement("option");
    placeholder.value = "";
    placeholder.textContent = "Select a common skill";
    commonSkillSelectEl.appendChild(placeholder);

    Object.entries(COMMON_SKILL_CANONICAL_ZH).forEach(([canonicalSkill, localizedSkill]) => {
        const option = document.createElement("option");
        option.value = canonicalSkill;
        option.textContent = canonicalSkill;
        commonSkillSelectEl.appendChild(option);
    });
}

function normalizeStatus(status) {
    return (status || "").trim().toUpperCase();
}

function getStatusLabel(status) {
    const normalized = normalizeStatus(status);
    if (normalized === "INTERVIEWED") {
        return "Interviewed";
    }
    if (normalized === "ACCEPTED") {
        return "Accepted";
    }
    if (normalized === "REJECTED") {
        return "Rejected";
    }
    return "Pending";
}

function getStatusTone(status) {
    const normalized = normalizeStatus(status);
    if (normalized === "INTERVIEWED") {
        return "interviewed";
    }
    if (normalized === "ACCEPTED") {
        return "accepted";
    }
    if (normalized === "REJECTED") {
        return "rejected";
    }
    return "pending";
}

function isOutstandingStatus(status) {
    const normalized = normalizeStatus(status);
    return normalized === "" || normalized === "SUBMITTED" || normalized === "INTERVIEWED";
}

function matchesReviewStatus(candidate) {
    if (!state.reviewStatus) {
        return true;
    }
    return normalizeStatus(candidate.status) === state.reviewStatus;
}

function showToast(message) {
    if (!message) {
        return;
    }
    const existingToast = document.getElementById("mo-review-toast");
    if (existingToast) {
        existingToast.remove();
    }
    const toast = document.createElement("div");
    toast.id = "mo-review-toast";
    toast.className = "mo-review-toast show";
    toast.textContent = message;
    document.body.appendChild(toast);
    window.setTimeout(() => {
        toast.classList.remove("show");
        window.setTimeout(() => toast.remove(), 220);
    }, 1800);
}

function confirmReviewAction(candidate, targetStatus) {
    const displayName = candidate.displayName || candidate.applicantId || "this candidate";
    const targetLabel = getStatusLabel(targetStatus);
    return window.confirm("Confirm " + targetLabel + " for " + displayName + "?");
}

function createStatusTag(status) {
    const tag = document.createElement("span");
    const tone = getStatusTone(status);
    tag.className = "status-tag " + tone;
    tag.textContent = getStatusLabel(status);
    return tag;
}

function getSortedApplications(jobId) {
    return [...(state.applicationsByJob[jobId] || [])].sort((a, b) => {
        const ta = Date.parse(a.submittedAt || "");
        const tb = Date.parse(b.submittedAt || "");
        const va = Number.isNaN(ta) ? 0 : ta;
        const vb = Number.isNaN(tb) ? 0 : tb;
        return vb - va;
    });
}

function summarizeApplications(applications) {
    const summary = {
        total: applications.length,
        pending: 0,
        interviewed: 0,
        accepted: 0,
        rejected: 0,
        actionable: 0
    };
    applications.forEach((application) => {
        const normalized = normalizeStatus(application.status);
        if (normalized === "SUBMITTED" || normalized === "") {
            summary.pending += 1;
        } else if (normalized === "INTERVIEWED") {
            summary.interviewed += 1;
        } else if (normalized === "ACCEPTED") {
            summary.accepted += 1;
        } else if (normalized === "REJECTED") {
            summary.rejected += 1;
        }
        if (isOutstandingStatus(application.status)) {
            summary.actionable += 1;
        }
    });
    return summary;
}

function buildJobSearchBlob(job) {
    return [
        job.jobId,
        job.title,
        job.moduleCode,
        job.requiredSkills
    ].filter(Boolean).join(" ").toLowerCase();
}

function buildCandidateSearchBlob(job, candidate) {
    return [
        job.jobId,
        job.title,
        job.moduleCode,
        candidate.displayName,
        candidate.applicantId,
        candidate.applicationId
    ].filter(Boolean).join(" ").toLowerCase();
}

function ensureCollapsedState(jobId, collapsed) {
    if (!Object.prototype.hasOwnProperty.call(state.collapsedJobs, jobId)) {
        state.collapsedJobs[jobId] = collapsed;
    }
}

function buildJobStat(label, value, tone) {
    const stat = document.createElement("span");
    stat.className = "job-stat" + (tone ? " " + tone : "");
    stat.textContent = label + " " + value;
    return stat;
}

function buildVisibleJobs() {
    const selectedJobId = (reviewJobSelectEl.value || "").trim();
    const keyword = (reviewJobSearchEl.value || "").trim().toLowerCase();

    return state.jobs
        .map((job) => {
            const allApplications = getSortedApplications(job.jobId);
            const stats = summarizeApplications(allApplications);
            const jobMatchesKeyword = !keyword || buildJobSearchBlob(job).includes(keyword);
            const statusMatchedApplications = allApplications.filter(matchesReviewStatus);
            const matchedApplications = !keyword
                ? statusMatchedApplications
                : statusMatchedApplications.filter((candidate) => buildCandidateSearchBlob(job, candidate).includes(keyword));
            const applications = !keyword
                ? statusMatchedApplications
                : (jobMatchesKeyword ? statusMatchedApplications : matchedApplications);
            return {
                job: job,
                stats: stats,
                jobMatchesKeyword: jobMatchesKeyword,
                allApplications: allApplications,
                applications: applications,
                matchedCount: matchedApplications.length,
                visibleCount: statusMatchedApplications.length
            };
        })
        .filter((entry) => {
            if (selectedJobId && entry.job.jobId !== selectedJobId) {
                return false;
            }
            if (!keyword) {
                return entry.visibleCount > 0 || !state.reviewStatus;
            }
            return entry.jobMatchesKeyword || entry.matchedCount > 0;
        })
        .sort((a, b) => {
            if (b.stats.actionable !== a.stats.actionable) {
                return b.stats.actionable - a.stats.actionable;
            }
            if (b.stats.pending !== a.stats.pending) {
                return b.stats.pending - a.stats.pending;
            }
            if (b.stats.total !== a.stats.total) {
                return b.stats.total - a.stats.total;
            }
            return (a.job.title || a.job.jobId || "").localeCompare(b.job.title || b.job.jobId || "");
        });
}

function updateReviewStatusFilters() {
    const selectedJobId = (reviewJobSelectEl.value || "").trim();
    const keyword = (reviewJobSearchEl.value || "").trim().toLowerCase();
    const filteredApplications = state.jobs
        .filter((job) => !selectedJobId || job.jobId === selectedJobId)
        .flatMap((job) => getSortedApplications(job.jobId).filter((candidate) => {
            if (!keyword) {
                return true;
            }
            return buildJobSearchBlob(job).includes(keyword) || buildCandidateSearchBlob(job, candidate).includes(keyword);
        }));

    const counts = {
        all: filteredApplications.length,
        submitted: 0,
        interviewed: 0,
        accepted: 0,
        rejected: 0
    };

    filteredApplications.forEach((candidate) => {
        const normalized = normalizeStatus(candidate.status);
        if (normalized === "INTERVIEWED") {
            counts.interviewed += 1;
        } else if (normalized === "ACCEPTED") {
            counts.accepted += 1;
        } else if (normalized === "REJECTED") {
            counts.rejected += 1;
        } else {
            counts.submitted += 1;
        }
    });

    Object.entries(reviewStatusCountEls).forEach(([key, element]) => {
        if (element) {
            element.textContent = String(counts[key]);
        }
    });

    reviewStatusFilterEls.forEach((button) => {
        button.classList.toggle("active", button.dataset.reviewStatus === state.reviewStatus);
    });
}

async function updateApplicationStatus(applicationId, status, triggerBtn) {
    if (!applicationId || !status) {
        return;
    }
    if (triggerBtn) {
        triggerBtn.disabled = true;
    }
    try {
        await api("mo/applications", {
            method: "PUT",
            body: JSON.stringify({
                applicationId: applicationId,
                status: status
            })
        });
        await loadReviewData();
        showToast("Application marked as " + getStatusLabel(status) + ".");
    } catch (error) {
        alert(error.message);
    } finally {
        if (triggerBtn) {
            triggerBtn.disabled = false;
        }
    }
}

function buildCandidateRow(job, candidate, isLatest) {
    const row = document.createElement("div");
    row.className = "candidate-row";

    const main = document.createElement("div");
    main.className = "candidate-main";
    const displayName = candidate.displayName || candidate.applicantId;
    const attachmentCount = Array.isArray(candidate.attachments) ? candidate.attachments.length : 0;
    main.innerHTML = "<strong>" + displayName + "</strong><br/>"
        + "User: " + candidate.applicantId + " | Application: " + candidate.applicationId
        + " | Attachments: " + attachmentCount;
    row.appendChild(main);

    const statusCell = document.createElement("div");
    statusCell.className = "candidate-status";
    const nameLine = document.createElement("div");
    nameLine.className = "candidate-label";
    nameLine.textContent = "Submitter: " + (candidate.displayName || "Unknown");
    const stateLine = document.createElement("div");
    stateLine.className = "candidate-status-meta";
    stateLine.textContent = "Current status";
    statusCell.appendChild(nameLine);
    statusCell.appendChild(stateLine);
    statusCell.appendChild(createStatusTag(candidate.status));
    row.appendChild(statusCell);

    const dateCell = document.createElement("div");
    dateCell.className = "candidate-date";
    dateCell.textContent = "Submitted: " + fmtDate(candidate.submittedAt);
    row.appendChild(dateCell);

    const actions = document.createElement("div");
    actions.className = "candidate-actions";

    const currentStatus = normalizeStatus(candidate.status);

    const interviewBtn = document.createElement("button");
    interviewBtn.type = "button";
    interviewBtn.className = "btn btn-review-interview";
    interviewBtn.textContent = currentStatus === "INTERVIEWED" ? "Interviewed" : "Mark Interviewed";
    interviewBtn.disabled = currentStatus === "INTERVIEWED" || currentStatus === "ACCEPTED" || currentStatus === "REJECTED";
    interviewBtn.addEventListener("click", async () => {
        if (!confirmReviewAction(candidate, "INTERVIEWED")) {
            return;
        }
        await updateApplicationStatus(candidate.applicationId, "INTERVIEWED", interviewBtn);
    });
    actions.appendChild(interviewBtn);

    const approveBtn = document.createElement("button");
    approveBtn.type = "button";
    approveBtn.className = "btn btn-review-approve";
    approveBtn.textContent = "Approve";
    approveBtn.disabled = currentStatus === "ACCEPTED";
    approveBtn.addEventListener("click", async () => {
        if (!confirmReviewAction(candidate, "ACCEPTED")) {
            return;
        }
        await updateApplicationStatus(candidate.applicationId, "ACCEPTED", approveBtn);
    });
    actions.appendChild(approveBtn);

    const rejectBtn = document.createElement("button");
    rejectBtn.type = "button";
    rejectBtn.className = "btn btn-review-reject";
    rejectBtn.textContent = "Reject";
    rejectBtn.disabled = currentStatus === "REJECTED";
    rejectBtn.addEventListener("click", async () => {
        if (!confirmReviewAction(candidate, "REJECTED")) {
            return;
        }
        await updateApplicationStatus(candidate.applicationId, "REJECTED", rejectBtn);
    });
    actions.appendChild(rejectBtn);

    const detailLink = document.createElement("a");
    detailLink.className = "btn btn-review-detail";
    detailLink.href = "mo-candidate-detail.jsp?jobId=" + encodeURIComponent(job.jobId)
        + "&candidateUserId=" + encodeURIComponent(candidate.applicantId)
        + "&applicationId=" + encodeURIComponent(candidate.applicationId || "");
    detailLink.textContent = "Detail";
    actions.appendChild(detailLink);

    row.appendChild(actions);
    if (isLatest) {
        row.style.borderColor = "#91c5ff";
        row.style.boxShadow = "0 0 0 2px rgba(21,117,255,.12)";
        const latestChip = document.createElement("span");
        latestChip.className = "chip";
        latestChip.textContent = "Latest";
        latestChip.style.marginLeft = ".4rem";
        nameLine.appendChild(latestChip);
    }
    return row;
}

function renderReview() {
    reviewListEl.innerHTML = "";
    updateReviewStatusFilters();
    if (!state.jobs.length) {
        reviewHintEl.textContent = "No jobs created by current MO yet.";
        const empty = document.createElement("div");
        empty.className = "panel empty-note";
        empty.textContent = "No jobs created by current MO yet. Please create a job first.";
        reviewListEl.appendChild(empty);
        return;
    }

    const keyword = (reviewJobSearchEl.value || "").trim().toLowerCase();
    const visibleJobs = buildVisibleJobs();

    if (!visibleJobs.length) {
        const emptyMessage = state.reviewStatus
            ? "No applications match the current status filter."
            : "No jobs match current filter.";
        reviewHintEl.textContent = emptyMessage;
        const empty = document.createElement("div");
        empty.className = "panel empty-note";
        empty.textContent = emptyMessage;
        reviewListEl.appendChild(empty);
        return;
    }

    let visibleApplicationCount = 0;

    for (const entry of visibleJobs) {
        const job = entry.job;
        const stats = entry.stats;
        const applications = entry.applications;
        visibleApplicationCount += applications.length;
        ensureCollapsedState(job.jobId, stats.actionable === 0);

        const block = document.createElement("section");
        block.className = "job-block";
        if (state.collapsedJobs[job.jobId]) {
            block.classList.add("collapsed");
        }

        const head = document.createElement("div");
        head.className = "job-head";

        const left = document.createElement("div");
        left.className = "job-head-main";
        const title = document.createElement("h3");
        title.className = "job-title";
        title.textContent = job.title + " (" + job.jobId + ")";

        const sub = document.createElement("p");
        sub.className = "job-sub";
        const subParts = [
            "Module " + (job.moduleCode || "-"),
            "Slots " + (job.slots || 0),
            "Status " + (job.status || "-")
        ];
        if (job.hoursPerWeek) {
            subParts.push("Hours/week " + job.hoursPerWeek);
        }
        if (job.applicationDeadline) {
            subParts.push("Deadline " + fmtDateOnly(job.applicationDeadline));
        }
        if (job.monthlyStipend) {
            subParts.push("Stipend " + job.monthlyStipend + " Yuan");
        }
        if (keyword && !entry.jobMatchesKeyword && entry.matchedCount > 0) {
            subParts.push(entry.matchedCount + " candidate match" + (entry.matchedCount === 1 ? "" : "es"));
        }
        sub.textContent = subParts.join(" | ");

        const summary = document.createElement("div");
        summary.className = "job-head-summary";
        summary.appendChild(buildJobStat("Total", stats.total, ""));
        summary.appendChild(buildJobStat("Pending", stats.pending, "pending"));
        summary.appendChild(buildJobStat("Interviewed", stats.interviewed, "interviewed"));
        summary.appendChild(buildJobStat("Accepted", stats.accepted, "accepted"));
        summary.appendChild(buildJobStat("Rejected", stats.rejected, "rejected"));

        left.appendChild(title);
        left.appendChild(sub);
        left.appendChild(summary);
        head.appendChild(left);

        const actions = document.createElement("div");
        actions.className = "job-head-actions";

        if (stats.actionable > 0) {
            const focus = document.createElement("span");
            focus.className = "job-focus";
            focus.textContent = "Needs review";
            actions.appendChild(focus);
        }

        if (keyword && !entry.jobMatchesKeyword && entry.matchedCount > 0) {
            const note = document.createElement("span");
            note.className = "match-note";
            note.textContent = "Showing matched candidates";
            actions.appendChild(note);
        }

        const toggleBtn = document.createElement("button");
        toggleBtn.type = "button";
        toggleBtn.className = "btn ghost job-toggle";
        toggleBtn.setAttribute("aria-expanded", state.collapsedJobs[job.jobId] ? "false" : "true");
        toggleBtn.textContent = state.collapsedJobs[job.jobId] ? "Expand" : "Collapse";
        toggleBtn.addEventListener("click", () => {
            state.collapsedJobs[job.jobId] = !state.collapsedJobs[job.jobId];
            renderReview();
        });
        actions.appendChild(toggleBtn);
        head.appendChild(actions);
        block.appendChild(head);

        const list = document.createElement("div");
        list.className = "candidate-list";
        if (!applications.length) {
            const emptyLine = document.createElement("div");
            emptyLine.className = "empty-inline";
            emptyLine.textContent = keyword
                ? "No candidates in this job match the current search."
                : "No applications for this job yet.";
            list.appendChild(emptyLine);
        } else {
            const latestApplicationId = entry.allApplications[0] ? entry.allApplications[0].applicationId : "";
            applications.forEach((candidate) => {
                const isLatest = Boolean(latestApplicationId) && candidate.applicationId === latestApplicationId;
                list.appendChild(buildCandidateRow(job, candidate, isLatest));
            });
        }
        block.appendChild(list);
        reviewListEl.appendChild(block);
    }

    const statusText = state.reviewStatus ? getStatusLabel(state.reviewStatus) : "All";
    reviewHintEl.textContent = keyword
        ? "Showing " + visibleJobs.length + " jobs / " + visibleApplicationCount + " " + statusText.toLowerCase() + " applications matching the current search."
        : "Showing " + visibleJobs.length + " jobs / " + visibleApplicationCount + " " + statusText.toLowerCase() + " applications.";
}

async function loadReviewData() {
    reviewHintEl.textContent = "Loading jobs and applications...";
    reviewRefreshBtnEl.disabled = true;
    try {
        const jobsResp = await api("jobs?page=1&size=500");
        const jobs = (jobsResp.items || []).filter((item) => item.createdBy === state.moUserId);
        state.jobs = jobs;
        state.applicationsByJob = {};
        state.collapsedJobs = Object.fromEntries(
            Object.entries(state.collapsedJobs).filter(([jobId]) => jobs.some((job) => job.jobId === jobId))
        );

        await Promise.all(jobs.map(async (job) => {
            const resp = await api("mo/candidates?jobId=" + encodeURIComponent(job.jobId) + "&page=1&size=500");
            state.applicationsByJob[job.jobId] = resp.candidates || [];
        }));

        populateJobOptions();
        renderReview();
    } catch (error) {
        reviewHintEl.textContent = error.message;
        reviewListEl.innerHTML = "";
        const errorPanel = document.createElement("div");
        errorPanel.className = "panel empty-note";
        errorPanel.textContent = error.message;
        reviewListEl.appendChild(errorPanel);
    } finally {
        reviewRefreshBtnEl.disabled = false;
    }
}

function populateJobOptions() {
    const previousValue = reviewJobSelectEl.value;
    reviewJobOptionsEl.innerHTML = "";
    reviewJobSelectEl.innerHTML = "";

    const allOption = document.createElement("option");
    allOption.value = "";
    allOption.textContent = "All Jobs";
    reviewJobSelectEl.appendChild(allOption);

    for (const job of state.jobs) {
        const option = document.createElement("option");
        option.value = job.jobId;
        option.textContent = job.jobId + " | " + job.title + " (" + job.moduleCode + ")";
        reviewJobSelectEl.appendChild(option);

        const jobIdOpt = document.createElement("option");
        jobIdOpt.value = job.jobId;
        reviewJobOptionsEl.appendChild(jobIdOpt);

        const titleOpt = document.createElement("option");
        titleOpt.value = job.title;
        reviewJobOptionsEl.appendChild(titleOpt);

        const moduleOpt = document.createElement("option");
        moduleOpt.value = job.moduleCode;
        reviewJobOptionsEl.appendChild(moduleOpt);
    }

    if (previousValue && state.jobs.some((job) => job.jobId === previousValue)) {
        reviewJobSelectEl.value = previousValue;
    }
}

tabReviewEl.addEventListener("click", () => switchTab("review"));
tabCreateEl.addEventListener("click", () => switchTab("create"));
reviewRefreshBtnEl.addEventListener("click", async () => {
    await loadReviewData();
});
reviewJobSelectEl.addEventListener("change", renderReview);
reviewJobSearchEl.addEventListener("input", renderReview);
reviewStatusFilterEls.forEach((button) => {
    button.addEventListener("click", () => {
        state.reviewStatus = button.dataset.reviewStatus || "";
        renderReview();
    });
});
reviewClearFilterBtnEl.addEventListener("click", () => {
    reviewJobSelectEl.value = "";
    reviewJobSearchEl.value = "";
    state.reviewStatus = "";
    renderReview();
});

populateCommonSkillOptions();
renderSelectedSkills();

addSkillBtnEl.addEventListener("click", () => {
    const candidateSkill = (customSkillInputEl.value || "").trim() || (commonSkillSelectEl.value || "").trim();
    if (!addRequiredSkill(candidateSkill)) {
        setMoOutput("Please choose or enter a required skill before adding.", "error");
        return;
    }
    customSkillInputEl.value = "";
    commonSkillSelectEl.value = "";
    setMoOutput("", "");
});

customSkillInputEl.addEventListener("keydown", (event) => {
    if (event.key !== "Enter") {
        return;
    }
    event.preventDefault();
    addSkillBtnEl.click();
});

moJobFormEl.addEventListener("submit", async (event) => {
    event.preventDefault();
    const payload = Object.fromEntries(new FormData(moJobFormEl).entries());
    if (!requiredSkillsInputEl.value) {
        setMoOutput("Please add at least one required skill.", "error");
        return;
    }
    const normalizedDeadline = normalizeDeadlineInput(payload.applicationDeadline);
    if (!normalizedDeadline) {
        setMoOutput("Application Deadline must use yyyy/m/d or yyyy/mm/dd, for example 2026/5/24.", "error");
        return;
    }
    payload.applicationDeadline = normalizedDeadline;
    payload.slots = Number(payload.slots);
    payload.hoursPerWeek = Number(payload.hoursPerWeek);
    payload.monthlyStipend = Number(payload.monthlyStipend);
    setMoOutput("", "");
    try {
        const data = await api("mo/jobs", {
            method: "POST",
            body: JSON.stringify(payload)
        });
        const createdJob = data.record || {};
        setMoOutput(
            "Job created successfully: " + (createdJob.title || payload.title)
            + " (" + (createdJob.jobId || payload.jobId) + ").",
            "success"
        );
        moJobFormEl.reset();
        clearSkillBuilder();
        await loadReviewData();
        reviewHintEl.textContent = "Job " + (createdJob.jobId || payload.jobId) + " created successfully.";
    } catch (error) {
        setMoOutput(error.message, "error");
    }
});

loadReviewData();

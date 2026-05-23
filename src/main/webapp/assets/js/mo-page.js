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
    filterStatus: "all",
    collapsedJobs: new Set(),
    collapseInitialized: false
};

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
const moJobFormEl = document.getElementById("mo-job-form");
const moOutputEl = document.getElementById("mo-output");
const filterButtons = {
    all: document.getElementById("filterAll"),
    pending: document.getElementById("filterPending"),
    interviewed: document.getElementById("filterInterviewed"),
    accepted: document.getElementById("filterAccepted"),
    rejected: document.getElementById("filterRejected")
};

const statusLabelMap = {
    SUBMITTED: "Pending",
    INTERVIEWED: "Interviewed",
    ACCEPTED: "Accepted",
    REJECTED: "Rejected"
};

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

function pretty(value) {
    return JSON.stringify(value, null, 2);
}

function normalizeStatus(status) {
    const upper = String(status || "").toUpperCase();
    return statusLabelMap[upper] ? upper : "SUBMITTED";
}

function statusToPillClass(status) {
    const normalized = normalizeStatus(status);
    if (normalized === "ACCEPTED") {
        return "accepted";
    }
    if (normalized === "REJECTED") {
        return "rejected";
    }
    if (normalized === "INTERVIEWED") {
        return "interviewed";
    }
    return "pending";
}

function statusMatchesFilter(status) {
    const normalized = normalizeStatus(status);
    if (state.filterStatus === "all") {
        return true;
    }
    if (state.filterStatus === "pending") {
        return normalized === "SUBMITTED";
    }
    return normalized.toLowerCase() === state.filterStatus;
}

function setStatusFilter(filterKey) {
    state.filterStatus = filterKey;
    Object.entries(filterButtons).forEach(([key, btn]) => {
        if (!btn) {
            return;
        }
        if (key === filterKey) {
            btn.classList.add("active");
        } else {
            btn.classList.remove("active");
        }
    });
    renderReview();
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
    const nameLine = document.createElement("div");
    nameLine.textContent = "Submitter: " + (candidate.displayName || "Unknown");
    nameLine.style.fontWeight = "700";
    nameLine.style.color = "#173c6b";
    const stateLine = document.createElement("div");
    const status = normalizeStatus(candidate.status);
    const statusLabel = statusLabelMap[status] || status;
    const statusPill = document.createElement("span");
    statusPill.className = "status-pill " + statusToPillClass(status);
    statusPill.textContent = statusLabel;
    stateLine.appendChild(statusPill);
    statusCell.appendChild(nameLine);
    statusCell.appendChild(stateLine);
    row.appendChild(statusCell);

    const dateCell = document.createElement("div");
    dateCell.textContent = "Submitted: " + fmtDate(candidate.submittedAt);
    row.appendChild(dateCell);

    const actions = document.createElement("div");
    actions.className = "candidate-actions";

    const approveBtn = document.createElement("button");
    approveBtn.type = "button";
    approveBtn.className = "btn";
    approveBtn.textContent = "Approve";
    approveBtn.addEventListener("click", async () => {
        if (!window.confirm("Approve this application?")) {
            return;
        }
        await updateApplicationStatus(candidate.applicationId, "ACCEPTED", approveBtn);
    });
    actions.appendChild(approveBtn);

    const interviewBtn = document.createElement("button");
    interviewBtn.type = "button";
    interviewBtn.className = "btn neutral";
    interviewBtn.textContent = "Mark Interviewed";
    interviewBtn.addEventListener("click", async () => {
        if (!window.confirm("Mark this application as interviewed?")) {
            return;
        }
        await updateApplicationStatus(candidate.applicationId, "INTERVIEWED", interviewBtn);
    });
    actions.appendChild(interviewBtn);

    const rejectBtn = document.createElement("button");
    rejectBtn.type = "button";
    rejectBtn.className = "btn danger";
    rejectBtn.textContent = "Reject";
    rejectBtn.addEventListener("click", async () => {
        if (!window.confirm("Reject this application?")) {
            return;
        }
        await updateApplicationStatus(candidate.applicationId, "REJECTED", rejectBtn);
    });
    actions.appendChild(rejectBtn);

    const detailLink = document.createElement("a");
    detailLink.className = "btn";
    detailLink.href = "mo-candidate-detail.jsp?jobId=" + encodeURIComponent(job.jobId)
        + "&candidateUserId=" + encodeURIComponent(candidate.applicantId)
        + "&applicationId=" + encodeURIComponent(candidate.applicationId || "");
    detailLink.textContent = "Detail + AI";
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

function getJobStats(applications) {
    let pending = 0;
    let interviewed = 0;
    let accepted = 0;
    let rejected = 0;
    applications.forEach((item) => {
        const status = normalizeStatus(item.status);
        if (status === "SUBMITTED") {
            pending++;
        } else if (status === "INTERVIEWED") {
            interviewed++;
        } else if (status === "ACCEPTED") {
            accepted++;
        } else if (status === "REJECTED") {
            rejected++;
        }
    });
    return {
        total: applications.length,
        pending: pending,
        interviewed: interviewed,
        accepted: accepted,
        rejected: rejected
    };
}

function jobMatchesKeyword(job, applications, keyword) {
    if (!keyword) {
        return true;
    }
    const blob = (job.jobId + " " + job.title + " " + job.moduleCode).toLowerCase();
    if (blob.includes(keyword)) {
        return true;
    }
    return applications.some((candidate) => {
        const candidateBlob = ((candidate.displayName || "") + " "
            + (candidate.applicantId || "") + " "
            + (candidate.applicationId || "")).toLowerCase();
        return candidateBlob.includes(keyword);
    });
}

function jobFieldMatches(job, keyword) {
    if (!keyword) {
        return true;
    }
    const blob = (job.jobId + " " + job.title + " " + job.moduleCode).toLowerCase();
    return blob.includes(keyword);
}

function candidateMatchesKeyword(candidate, keyword) {
    if (!keyword) {
        return true;
    }
    const candidateBlob = ((candidate.displayName || "") + " "
        + (candidate.applicantId || "") + " "
        + (candidate.applicationId || "")).toLowerCase();
    return candidateBlob.includes(keyword);
}

function renderReview() {
    reviewListEl.innerHTML = "";
    if (!state.jobs.length) {
        const empty = document.createElement("div");
        empty.className = "panel empty-note";
        empty.textContent = "No jobs created by current MO yet. Please create a job first.";
        reviewListEl.appendChild(empty);
        return;
    }

    const selectedJobId = (reviewJobSelectEl.value || "").trim();
    const keyword = (reviewJobSearchEl.value || "").trim().toLowerCase();
    const visibleJobs = state.jobs.filter((job) => {
        if (selectedJobId && job.jobId !== selectedJobId) {
            return false;
        }
        const applications = state.applicationsByJob[job.jobId] || [];
        return jobMatchesKeyword(job, applications, keyword);
    });

    if (!visibleJobs.length) {
        const empty = document.createElement("div");
        empty.className = "panel empty-note";
        empty.textContent = "No jobs match current filter.";
        reviewListEl.appendChild(empty);
        return;
    }

    if (!state.collapseInitialized) {
        visibleJobs.forEach((job) => {
            const applications = state.applicationsByJob[job.jobId] || [];
            const stats = getJobStats(applications);
            if (stats.pending === 0) {
                state.collapsedJobs.add(job.jobId);
            }
        });
        state.collapseInitialized = true;
    }

    for (const job of visibleJobs) {
        const block = document.createElement("section");
        block.className = "job-block";

        const head = document.createElement("div");
        head.className = "job-head";
        const left = document.createElement("div");
        const title = document.createElement("h3");
        title.className = "job-title";
        title.textContent = job.title + " (" + job.jobId + ")";
        const sub = document.createElement("p");
        sub.className = "job-sub";
        sub.textContent = "Module " + job.moduleCode + " | Slots " + job.slots + " | Status " + job.status;
        left.appendChild(title);
        left.appendChild(sub);
        head.appendChild(left);

        const statsWrap = document.createElement("div");
        statsWrap.className = "job-meta-grid";
        const applications = [...(state.applicationsByJob[job.jobId] || [])];
        const stats = getJobStats(applications);
        const statsRow = document.createElement("div");
        statsRow.className = "job-stats";
        const totalPill = document.createElement("span");
        totalPill.className = "status-pill interviewed";
        totalPill.textContent = "Total " + stats.total;
        const pendingPill = document.createElement("span");
        pendingPill.className = "status-pill pending";
        pendingPill.textContent = "Pending " + stats.pending;
        const acceptedPill = document.createElement("span");
        acceptedPill.className = "status-pill accepted";
        acceptedPill.textContent = "Accepted " + stats.accepted;
        const rejectedPill = document.createElement("span");
        rejectedPill.className = "status-pill rejected";
        rejectedPill.textContent = "Rejected " + stats.rejected;
        statsRow.appendChild(totalPill);
        statsRow.appendChild(pendingPill);
        statsRow.appendChild(acceptedPill);
        statsRow.appendChild(rejectedPill);
        statsWrap.appendChild(statsRow);

        const toggleBtn = document.createElement("button");
        toggleBtn.type = "button";
        toggleBtn.className = "job-toggle";
        toggleBtn.textContent = state.collapsedJobs.has(job.jobId) ? "Expand" : "Collapse";
        toggleBtn.addEventListener("click", () => {
            if (state.collapsedJobs.has(job.jobId)) {
                state.collapsedJobs.delete(job.jobId);
            } else {
                state.collapsedJobs.add(job.jobId);
            }
            renderReview();
        });

        statsWrap.appendChild(toggleBtn);
        head.appendChild(statsWrap);
        block.appendChild(head);

        const list = document.createElement("div");
        list.className = "candidate-list";
        const jobFieldMatched = jobFieldMatches(job, keyword);
        const filteredApplications = applications
            .filter((candidate) => statusMatchesFilter(candidate.status))
            .filter((candidate) => jobFieldMatched || candidateMatchesKeyword(candidate, keyword))
            .sort((a, b) => {
                const ta = Date.parse(a.submittedAt || "");
                const tb = Date.parse(b.submittedAt || "");
                const va = Number.isNaN(ta) ? 0 : ta;
                const vb = Number.isNaN(tb) ? 0 : tb;
                return vb - va;
            });
        if (state.collapsedJobs.has(job.jobId)) {
            list.style.display = "none";
        }
        if (!filteredApplications.length) {
            const emptyLine = document.createElement("div");
            emptyLine.className = "empty-inline";
            emptyLine.textContent = "No applications match current filter.";
            list.appendChild(emptyLine);
        } else {
            filteredApplications.forEach((candidate, index) => {
                list.appendChild(buildCandidateRow(job, candidate, index === 0));
            });
        }
        block.appendChild(list);
        reviewListEl.appendChild(block);
    }
}

async function loadReviewData() {
    reviewHintEl.textContent = "Loading jobs and applications...";
    reviewRefreshBtnEl.disabled = true;
    try {
        const jobsResp = await api("jobs?page=1&size=500");
        const jobs = (jobsResp.items || []).filter((item) => item.createdBy === state.moUserId);
        state.jobs = jobs;
        state.applicationsByJob = {};

        await Promise.all(jobs.map(async (job) => {
            const resp = await api("mo/candidates?jobId=" + encodeURIComponent(job.jobId) + "&page=1&size=500");
            state.applicationsByJob[job.jobId] = resp.candidates || [];
        }));

        populateJobOptions();
        renderReview();
        reviewHintEl.textContent = "Loaded " + jobs.length + " jobs.";
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
    }
}

tabReviewEl.addEventListener("click", () => switchTab("review"));
tabCreateEl.addEventListener("click", () => switchTab("create"));
reviewRefreshBtnEl.addEventListener("click", async () => {
    await loadReviewData();
});
reviewJobSelectEl.addEventListener("change", () => {
    if (reviewJobSelectEl.value) {
        const selected = state.jobs.find((job) => job.jobId === reviewJobSelectEl.value);
        reviewJobSearchEl.value = selected ? selected.jobId : "";
    }
    renderReview();
});
reviewJobSearchEl.addEventListener("input", () => {
    const kw = (reviewJobSearchEl.value || "").trim().toLowerCase();
    const matched = state.jobs.find((job) => {
        const blob = (job.jobId + " " + job.title + " " + job.moduleCode).toLowerCase();
        return blob === kw || job.jobId.toLowerCase() === kw;
    });
    reviewJobSelectEl.value = matched ? matched.jobId : "";
    renderReview();
});
reviewClearFilterBtnEl.addEventListener("click", () => {
    reviewJobSelectEl.value = "";
    reviewJobSearchEl.value = "";
    renderReview();
});

Object.entries(filterButtons).forEach(([key, btn]) => {
    if (!btn) {
        return;
    }
    btn.addEventListener("click", () => setStatusFilter(key));
});

moJobFormEl.addEventListener("submit", async (event) => {
    event.preventDefault();
    const payload = Object.fromEntries(new FormData(moJobFormEl).entries());
    payload.slots = Number(payload.slots);
    try {
        const data = await api("mo/jobs", {
            method: "POST",
            body: JSON.stringify(payload)
        });
        moOutputEl.textContent = pretty(data);
        await loadReviewData();
        switchTab("review");
    } catch (error) {
        moOutputEl.textContent = error.message;
    }
});

setStatusFilter("all");
loadReviewData();

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
    applicationsByJob: {}
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

function buildStatusSelect(currentStatus) {
    const select = document.createElement("select");
    select.className = "mini-select";
    const statuses = ["SUBMITTED", "INTERVIEWED", "ACCEPTED", "REJECTED"];
    statuses.forEach((status) => {
        const option = document.createElement("option");
        option.value = status;
        option.textContent = status;
        if ((currentStatus || "").toUpperCase() === status) {
            option.selected = true;
        }
        select.appendChild(option);
    });
    return select;
}

function buildCandidateRow(job, candidate, isLatest) {
    const row = document.createElement("div");
    row.className = "candidate-row";

    const main = document.createElement("div");
    main.className = "candidate-main";
    const displayName = candidate.displayName || candidate.applicantId;
    main.innerHTML = "<strong>" + displayName + "</strong><br/>"
        + "User: " + candidate.applicantId + " | Application: " + candidate.applicationId;
    row.appendChild(main);

    const statusCell = document.createElement("div");
    const nameLine = document.createElement("div");
    nameLine.textContent = "Submitter: " + (candidate.displayName || "Unknown");
    nameLine.style.fontWeight = "700";
    nameLine.style.color = "#173c6b";
    const stateLine = document.createElement("div");
    stateLine.textContent = "Current: " + (candidate.status || "SUBMITTED");
    statusCell.appendChild(nameLine);
    statusCell.appendChild(stateLine);
    row.appendChild(statusCell);

    const dateCell = document.createElement("div");
    dateCell.textContent = "Submitted: " + fmtDate(candidate.submittedAt);
    row.appendChild(dateCell);

    const actions = document.createElement("div");
    actions.className = "candidate-actions";

    const statusSelect = buildStatusSelect(candidate.status);
    actions.appendChild(statusSelect);

    const updateBtn = document.createElement("button");
    updateBtn.type = "button";
    updateBtn.className = "btn ghost";
    updateBtn.textContent = "Update";
    updateBtn.addEventListener("click", async () => {
        updateBtn.disabled = true;
        try {
            await api("mo/applications", {
                method: "PUT",
                body: JSON.stringify({
                    applicationId: candidate.applicationId,
                    status: statusSelect.value
                })
            });
            await loadReviewData();
        } catch (error) {
            alert(error.message);
        } finally {
            updateBtn.disabled = false;
        }
    });
    actions.appendChild(updateBtn);

    const detailLink = document.createElement("a");
    detailLink.className = "btn";
    detailLink.href = "mo-candidate-detail.jsp?jobId=" + encodeURIComponent(job.jobId)
        + "&candidateUserId=" + encodeURIComponent(candidate.applicantId);
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
        if (!keyword) {
            return true;
        }
        const blob = (job.jobId + " " + job.title + " " + job.moduleCode).toLowerCase();
        return blob.includes(keyword);
    });

    if (!visibleJobs.length) {
        const empty = document.createElement("div");
        empty.className = "panel empty-note";
        empty.textContent = "No jobs match current filter.";
        reviewListEl.appendChild(empty);
        return;
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
        block.appendChild(head);

        const list = document.createElement("div");
        list.className = "candidate-list";
        const applications = [...(state.applicationsByJob[job.jobId] || [])]
            .sort((a, b) => {
                const ta = Date.parse(a.submittedAt || "");
                const tb = Date.parse(b.submittedAt || "");
                const va = Number.isNaN(ta) ? 0 : ta;
                const vb = Number.isNaN(tb) ? 0 : tb;
                return vb - va;
            });
        if (!applications.length) {
            const emptyLine = document.createElement("div");
            emptyLine.className = "empty-inline";
            emptyLine.textContent = "No applications for this job yet.";
            list.appendChild(emptyLine);
        } else {
            applications.forEach((candidate, index) => {
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

loadReviewData();

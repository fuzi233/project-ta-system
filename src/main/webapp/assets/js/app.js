async function api(url, options = {}) {
    const response = await fetch(url, {
        headers: {"Content-Type": "application/json"},
        ...options
    });
    const text = await response.text();
    let body;
    try {
        body = text ? JSON.parse(text) : {};
    } catch (_) {
        body = {raw: text};
    }
    if (!response.ok) {
        throw new Error(body.error || `HTTP ${response.status}`);
    }
    return body;
}

function pretty(value) {
    return JSON.stringify(value, null, 2);
}

const jobFilter = document.getElementById("job-filter");
if (jobFilter) {
    const jobsOutput = document.getElementById("jobs-output");
    async function loadJobs(q = "") {
        try {
            const data = await api(`/jobs?q=${encodeURIComponent(q)}`);
            jobsOutput.textContent = pretty(data);
        } catch (error) {
            jobsOutput.textContent = error.message;
        }
    }

    jobFilter.addEventListener("submit", async (event) => {
        event.preventDefault();
        const q = document.getElementById("q").value || "";
        await loadJobs(q);
    });

    loadJobs();
}

const applyForm = document.getElementById("apply-form");
if (applyForm) {
    const output = document.getElementById("apply-output");
    applyForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const payload = Object.fromEntries(new FormData(applyForm).entries());
        try {
            const data = await api("/applications", {
                method: "POST",
                body: JSON.stringify(payload)
            });
            output.textContent = pretty(data);
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

const statusForm = document.getElementById("status-form");
if (statusForm) {
    const output = document.getElementById("status-output");
    statusForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const payload = Object.fromEntries(new FormData(statusForm).entries());
        try {
            const data = await api(`/applications?applicantId=${encodeURIComponent(payload.applicantId)}`);
            output.textContent = pretty(data);
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

const moForm = document.getElementById("mo-job-form");
let moRefreshJobs = null;
if (moForm) {
    const output = document.getElementById("mo-output");
    moForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const payload = Object.fromEntries(new FormData(moForm).entries());
        payload.slots = Number(payload.slots);
        try {
            const data = await api("/mo/jobs", {
                method: "POST",
                body: JSON.stringify(payload)
            });
            output.textContent = pretty(data);
            if (moRefreshJobs) {
                await moRefreshJobs();
            }
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

let moLoadCandidates = null;

// MO Candidate Screening
const candidateFilterForm = document.getElementById("candidate-filter-form");
if (candidateFilterForm) {
    const candidatesOutput = document.getElementById("candidates-output");
    
    async function loadCandidates(jobId, status = "", page = 1, size = 20) {
        try {
            let url = `/mo/candidates?jobId=${encodeURIComponent(jobId)}&page=${page}&size=${size}`;
            if (status) {
                url += `&status=${encodeURIComponent(status)}`;
            }
            const data = await api(url);
            candidatesOutput.textContent = pretty(data);
        } catch (error) {
            candidatesOutput.textContent = error.message;
        }
    }
    
    candidateFilterForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const formData = new FormData(candidateFilterForm);
        const jobId = formData.get("jobId");
        const status = formData.get("status");
        const page = parseInt(formData.get("page")) || 1;
        const size = parseInt(formData.get("size")) || 20;
        
        await loadCandidates(jobId, status, page, size);
    });

    moLoadCandidates = async (jobId) => {
        const formData = new FormData(candidateFilterForm);
        const status = formData.get("status") || "";
        const page = parseInt(formData.get("page")) || 1;
        const size = parseInt(formData.get("size")) || 20;
        await loadCandidates(jobId, status, page, size);
    };
}

// MO Open Job List
const moJobsTableBody = document.getElementById("mo-jobs-table-body");
if (moJobsTableBody) {
    const refreshBtn = document.getElementById("mo-jobs-refresh");
    const candidateJobIdInput = document.getElementById("candidateJobId");

    function renderJobRows(jobs) {
        moJobsTableBody.innerHTML = "";
        if (!jobs || jobs.length === 0) {
            const row = document.createElement("tr");
            const cell = document.createElement("td");
            cell.colSpan = 5;
            cell.className = "empty-note";
            cell.textContent = "No open jobs.";
            row.appendChild(cell);
            moJobsTableBody.appendChild(row);
            return;
        }

        for (const job of jobs) {
            const row = document.createElement("tr");

            const idCell = document.createElement("td");
            idCell.textContent = job.jobId;
            row.appendChild(idCell);

            const titleCell = document.createElement("td");
            titleCell.textContent = job.title;
            row.appendChild(titleCell);

            const moduleCell = document.createElement("td");
            moduleCell.textContent = job.moduleCode;
            row.appendChild(moduleCell);

            const slotsCell = document.createElement("td");
            slotsCell.textContent = String(job.slots);
            row.appendChild(slotsCell);

            const actionCell = document.createElement("td");
            const useBtn = document.createElement("button");
            useBtn.type = "button";
            useBtn.className = "btn ghost";
            useBtn.textContent = "Use";
            useBtn.addEventListener("click", async () => {
                if (candidateJobIdInput) {
                    candidateJobIdInput.value = job.jobId;
                }
                if (moLoadCandidates) {
                    try {
                        await moLoadCandidates(job.jobId);
                    } catch (_) {
                    }
                }
            });
            actionCell.appendChild(useBtn);
            row.appendChild(actionCell);

            moJobsTableBody.appendChild(row);
        }
    }

    async function loadMoJobs() {
        try {
            if (refreshBtn) {
                refreshBtn.disabled = true;
            }
            const data = await api("/jobs?status=OPEN&page=1&size=200");
            renderJobRows(data.items || []);
        } catch (error) {
            moJobsTableBody.innerHTML = "";
            const row = document.createElement("tr");
            const cell = document.createElement("td");
            cell.colSpan = 5;
            cell.className = "empty-note";
            cell.textContent = error.message;
            row.appendChild(cell);
            moJobsTableBody.appendChild(row);
        } finally {
            if (refreshBtn) {
                refreshBtn.disabled = false;
            }
        }
    }

    moRefreshJobs = loadMoJobs;

    if (refreshBtn) {
        refreshBtn.addEventListener("click", async () => {
            await loadMoJobs();
        });
    }

    loadMoJobs();
}

// MO Status Update
const statusUpdateForm = document.getElementById("status-update-form");
if (statusUpdateForm) {
    const statusOutput = document.getElementById("status-output");
    
    statusUpdateForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const formData = new FormData(statusUpdateForm);
        const payload = {
            applicationId: formData.get("applicationId"),
            status: formData.get("status")
        };
        
        try {
            const data = await api("/mo/applications", {
                method: "PUT",
                body: JSON.stringify(payload)
            });
            statusOutput.textContent = pretty(data);
        } catch (error) {
            statusOutput.textContent = error.message;
        }
    });
}

const adminForm = document.getElementById("admin-form");
if (adminForm) {
    const thresholdInput = document.getElementById("threshold");
    const onlyOverloadedInput = document.getElementById("only-overloaded");
    const hint = document.getElementById("admin-hint");
    const statTotalApplications = document.getElementById("stat-total-applications");
    const statTotalApplicants = document.getElementById("stat-total-applicants");
    const statOverloaded = document.getElementById("stat-overloaded");
    const tableBody = document.getElementById("admin-table-body");

    function renderEmpty(message) {
        tableBody.innerHTML = "";
        const row = document.createElement("tr");
        const cell = document.createElement("td");
        cell.colSpan = 5;
        cell.className = "empty-note";
        cell.textContent = message;
        row.appendChild(cell);
        tableBody.appendChild(row);
    }

    function toDisplayStatus(status) {
        return status.replace(/_/g, " ");
    }

    function renderStatusBreakdown(statusBreakdown) {
        const chips = document.createElement("div");
        chips.className = "chip-list";
        const entries = Object.entries(statusBreakdown || {});
        if (entries.length === 0) {
            const chip = document.createElement("span");
            chip.className = "chip";
            chip.textContent = "No status data";
            chips.appendChild(chip);
            return chips;
        }
        for (const [status, count] of entries) {
            const chip = document.createElement("span");
            chip.className = "chip";
            chip.textContent = `${toDisplayStatus(status)}: ${count}`;
            chips.appendChild(chip);
        }
        return chips;
    }

    function renderRows(entries) {
        tableBody.innerHTML = "";
        if (!entries || entries.length === 0) {
            renderEmpty("No applicants match current filter.");
            return;
        }

        for (const entry of entries) {
            const row = document.createElement("tr");

            const applicantCell = document.createElement("td");
            applicantCell.textContent = entry.applicantId;
            row.appendChild(applicantCell);

            const activeCell = document.createElement("td");
            activeCell.textContent = String(entry.activeApplications);
            row.appendChild(activeCell);

            const totalCell = document.createElement("td");
            totalCell.textContent = String(entry.totalApplications);
            row.appendChild(totalCell);

            const statusCell = document.createElement("td");
            statusCell.appendChild(renderStatusBreakdown(entry.statusBreakdown));
            row.appendChild(statusCell);

            const warningCell = document.createElement("td");
            const badge = document.createElement("span");
            badge.className = entry.overloaded ? "pill warn" : "pill ok";
            badge.textContent = entry.overloaded
                ? `OVERLOADED (+${entry.overloadBy})`
                : "OK";
            warningCell.appendChild(badge);
            row.appendChild(warningCell);

            tableBody.appendChild(row);
        }
    }

    async function load() {
        const thresholdRaw = thresholdInput.value.trim();
        const params = new URLSearchParams();
        if (thresholdRaw !== "") {
            params.set("threshold", thresholdRaw);
        }
        if (onlyOverloadedInput.checked) {
            params.set("onlyOverloaded", "true");
        }
        const suffix = params.toString() ? `?${params.toString()}` : "";
        try {
            const data = await api(`/admin/workload${suffix}`);
            statTotalApplications.textContent = String(data.totalApplications ?? "-");
            statTotalApplicants.textContent = String(data.totalApplicants ?? "-");
            statOverloaded.textContent = String(data.overloadedCount ?? "-");
            hint.textContent = `Threshold: ${data.threshold}. Showing ${data.onlyOverloaded ? "overloaded only" : "all applicants"}.`;
            renderRows(data.entries || []);
        } catch (error) {
            hint.textContent = error.message;
            statTotalApplications.textContent = "-";
            statTotalApplicants.textContent = "-";
            statOverloaded.textContent = "-";
            renderEmpty("Failed to load workload data.");
        }
    }

    adminForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        await load();
    });

    load();
}

const aiMatchForm = document.getElementById("ai-match-form");
if (aiMatchForm) {
    const output = document.getElementById("ai-match-output");
    aiMatchForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const payload = Object.fromEntries(new FormData(aiMatchForm).entries());
        try {
            const data = await api("/ai/match", {
                method: "POST",
                body: JSON.stringify(payload)
            });
            output.textContent = pretty(data);
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

const aiMissingForm = document.getElementById("ai-missing-form");
if (aiMissingForm) {
    const output = document.getElementById("ai-missing-output");
    aiMissingForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const payload = Object.fromEntries(new FormData(aiMissingForm).entries());
        try {
            const data = await api("/ai/missing-skills", {
                method: "POST",
                body: JSON.stringify(payload)
            });
            output.textContent = pretty(data);
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

const aiWorkloadForm = document.getElementById("ai-workload-form");
if (aiWorkloadForm) {
    const output = document.getElementById("ai-workload-output");
    aiWorkloadForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const payload = Object.fromEntries(new FormData(aiWorkloadForm).entries());
        const limit = payload.limit || "5";
        try {
            const data = await api(
                `/ai/workload-suggestion?jobId=${encodeURIComponent(payload.jobId)}&limit=${encodeURIComponent(limit)}`
            );
            output.textContent = pretty(data);
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

const hrCandidateSelect = document.getElementById("hr-candidate-select");
if (hrCandidateSelect) {
    const hrJobSelect = document.getElementById("hr-job-select");
    const hrCandidateOutput = document.getElementById("hr-candidate-output");
    const hrAiOutput = document.getElementById("hr-ai-output");
    const hrAiButton = document.getElementById("hr-ai-analyze-btn");

    async function loadCandidates() {
        const data = await api("/hr/candidates");
        hrCandidateSelect.innerHTML = "";
        if (!data.items || data.items.length === 0) {
            const option = document.createElement("option");
            option.value = "";
            option.textContent = "No candidates";
            hrCandidateSelect.appendChild(option);
            return;
        }
        data.items.forEach((item, idx) => {
            const option = document.createElement("option");
            option.value = item.candidateUserId;
            option.textContent = `${item.displayName} (${item.candidateUserId})`;
            if (idx === 0) {
                option.selected = true;
            }
            hrCandidateSelect.appendChild(option);
        });
    }

    async function loadJobsForHr() {
        const data = await api("/jobs?status=OPEN&page=1&size=50");
        hrJobSelect.innerHTML = "";
        const jobs = data.items || [];
        if (jobs.length === 0) {
            const option = document.createElement("option");
            option.value = "";
            option.textContent = "No open jobs";
            hrJobSelect.appendChild(option);
            return;
        }
        jobs.forEach((job, idx) => {
            const option = document.createElement("option");
            option.value = job.jobId;
            option.textContent = `${job.title} (${job.jobId})`;
            if (idx === 0) {
                option.selected = true;
            }
            hrJobSelect.appendChild(option);
        });
    }

    async function loadCandidateDetail(candidateUserId) {
        if (!candidateUserId) {
            hrCandidateOutput.textContent = "Please select a candidate.";
            return;
        }
        const data = await api(`/hr/candidates?candidateUserId=${encodeURIComponent(candidateUserId)}`);
        hrCandidateOutput.textContent = pretty(data.candidate || data);
    }

    hrCandidateSelect.addEventListener("change", async () => {
        try {
            await loadCandidateDetail(hrCandidateSelect.value);
        } catch (error) {
            hrCandidateOutput.textContent = error.message;
        }
    });

    hrAiButton.addEventListener("click", async () => {
        const candidateUserId = hrCandidateSelect.value;
        const jobId = hrJobSelect.value;
        if (!candidateUserId || !jobId) {
            hrAiOutput.textContent = "Please select both candidate and job.";
            return;
        }
        hrAiOutput.textContent = "Analyzing...";
        try {
            const data = await api("/ai/hr-assessment", {
                method: "POST",
                body: JSON.stringify({candidateUserId, jobId})
            });
            hrAiOutput.textContent = pretty(data.insight || data);
        } catch (error) {
            hrAiOutput.textContent = error.message;
        }
    });

    (async () => {
        try {
            await loadCandidates();
            await loadJobsForHr();
            await loadCandidateDetail(hrCandidateSelect.value);
        } catch (error) {
            hrCandidateOutput.textContent = error.message;
        }
    })();
}

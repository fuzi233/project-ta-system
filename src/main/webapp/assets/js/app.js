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
        try {
            const data = await api("/applications");
            output.textContent = pretty(data);
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

const moForm = document.getElementById("mo-job-form");
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
        } catch (error) {
            output.textContent = error.message;
        }
    });
}

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

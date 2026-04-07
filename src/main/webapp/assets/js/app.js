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
    const output = document.getElementById("admin-output");
    async function load(threshold = "") {
        const suffix = threshold ? `?threshold=${encodeURIComponent(threshold)}` : "";
        try {
            const data = await api(`/admin/workload${suffix}`);
            output.textContent = pretty(data);
        } catch (error) {
            output.textContent = error.message;
        }
    }

    adminForm.addEventListener("submit", async (event) => {
        event.preventDefault();
        const threshold = document.getElementById("threshold").value;
        await load(threshold);
    });

    load();
}

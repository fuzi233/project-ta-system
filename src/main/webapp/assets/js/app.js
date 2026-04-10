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

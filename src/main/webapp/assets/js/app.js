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

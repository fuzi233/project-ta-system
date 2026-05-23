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

function escapeHtml(value) {
    return String(value ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

function decodeEscapedUnicode(value) {
    if (typeof value !== "string") {
        return value;
    }
    return value
        .replace(/\\u([0-9a-fA-F]{4})/g, (_, hex) => String.fromCharCode(parseInt(hex, 16)))
        .replace(/\\n/g, "\n");
}

function formatList(items) {
    if (!Array.isArray(items) || items.length === 0) {
        return "-";
    }
    return items.map((item) => "- " + decodeEscapedUnicode(String(item))).join("\n");
}

function renderHrInsight(insight) {
    if (!insight || typeof insight !== "object") {
        return pretty(insight);
    }

    const lines = [
        `Candidate: ${decodeEscapedUnicode(insight.displayName || insight.candidateUserId || "-")}`,
        `Score: ${insight.score ?? "-"}`,
        `Workload: ${insight.workload ?? "-"}`,
        `Provider: ${decodeEscapedUnicode(insight.provider || "-")}`,
        "",
        "Resume Summary:",
        decodeEscapedUnicode(insight.resumeSummary || "-"),
        "",
        "Matched Skills:",
        formatList(insight.matchedSkills),
        "",
        "Missing Skills:",
        formatList(insight.missingSkills),
        "",
        "Explanation:",
        decodeEscapedUnicode(insight.explanation || "-")
    ];

    return lines.join("\n");
}

function renderHrInsightHtml(insight) {
    if (!insight || typeof insight !== "object") {
        return `<p class="hr-ai-copy">${escapeHtml(pretty(insight))}</p>`;
    }

    const matched = Array.isArray(insight.matchedSkills) ? insight.matchedSkills : [];
    const missing = Array.isArray(insight.missingSkills) ? insight.missingSkills : [];

    return `
        <div class="hr-ai-section">
            <h3>Overview</h3>
            <p class="hr-ai-copy"><strong>Candidate:</strong> ${escapeHtml(decodeEscapedUnicode(insight.displayName || insight.candidateUserId || "-"))}</p>
            <p class="hr-ai-copy"><strong>Score:</strong> ${escapeHtml(insight.score ?? "-")}</p>
            <p class="hr-ai-copy"><strong>Workload:</strong> ${escapeHtml(insight.workload ?? "-")}</p>
            <p class="hr-ai-copy"><strong>Provider:</strong> ${escapeHtml(decodeEscapedUnicode(insight.provider || "-"))}</p>
        </div>
        <div class="hr-ai-section">
            <h3>Resume Summary</h3>
            <p class="hr-ai-copy">${escapeHtml(decodeEscapedUnicode(insight.resumeSummary || "-"))}</p>
        </div>
        <div class="hr-ai-section">
            <h3>Matched Skills</h3>
            ${matched.length ? `<ul class="hr-ai-list">${matched.map((item) => `<li>${escapeHtml(decodeEscapedUnicode(item))}</li>`).join("")}</ul>` : `<p class="hr-ai-copy">-</p>`}
        </div>
        <div class="hr-ai-section">
            <h3>Missing Skills</h3>
            ${missing.length ? `<ul class="hr-ai-list">${missing.map((item) => `<li>${escapeHtml(decodeEscapedUnicode(item))}</li>`).join("")}</ul>` : `<p class="hr-ai-copy">-</p>`}
        </div>
        <div class="hr-ai-section">
            <h3>Explanation</h3>
            <p class="hr-ai-copy">${escapeHtml(decodeEscapedUnicode(insight.explanation || "-"))}</p>
        </div>
    `;
}

function renderHrCandidateDetail(candidate) {
    if (!candidate || typeof candidate !== "object") {
        return pretty(candidate);
    }

    const lines = [
        `Name: ${decodeEscapedUnicode(candidate.displayName || "-")}`,
        `User ID: ${decodeEscapedUnicode(candidate.candidateUserId || "-")}`,
        `Role: ${decodeEscapedUnicode(candidate.role || "-")}`,
        `Identifier: ${decodeEscapedUnicode(candidate.identifier || "-")}`,
        `Email: ${decodeEscapedUnicode(candidate.email || "-")}`,
        `Skills: ${decodeEscapedUnicode(candidate.skills || "-")}`,
        `Workload: ${candidate.workload ?? "-"}`,
        `Updated At: ${decodeEscapedUnicode(candidate.updatedAt || "-")}`,
        "",
        "Resume Text:",
        decodeEscapedUnicode(candidate.resumeText || "-")
    ];

    return lines.join("\n");
}

function renderHrCandidateDetailHtml(candidate) {
    if (!candidate || typeof candidate !== "object") {
        return `<p class="hr-ai-copy">${escapeHtml(pretty(candidate))}</p>`;
    }

    const skills = decodeEscapedUnicode(candidate.skills || "-");
    const resumeText = decodeEscapedUnicode(candidate.resumeText || "-");

    return `
        <div class="hr-detail-grid">
            <div class="hr-detail-item">
                <p class="hr-detail-label">Name</p>
                <div class="hr-detail-value">${escapeHtml(decodeEscapedUnicode(candidate.displayName || "-"))}</div>
            </div>
            <div class="hr-detail-item">
                <p class="hr-detail-label">User ID</p>
                <div class="hr-detail-value">${escapeHtml(decodeEscapedUnicode(candidate.candidateUserId || "-"))}</div>
            </div>
            <div class="hr-detail-item">
                <p class="hr-detail-label">Role</p>
                <div class="hr-detail-value">${escapeHtml(decodeEscapedUnicode(candidate.role || "-"))}</div>
            </div>
            <div class="hr-detail-item">
                <p class="hr-detail-label">Identifier</p>
                <div class="hr-detail-value">${escapeHtml(decodeEscapedUnicode(candidate.identifier || "-"))}</div>
            </div>
            <div class="hr-detail-item">
                <p class="hr-detail-label">Email</p>
                <div class="hr-detail-value">${escapeHtml(decodeEscapedUnicode(candidate.email || "-"))}</div>
            </div>
            <div class="hr-detail-item">
                <p class="hr-detail-label">Workload</p>
                <div class="hr-detail-value">${escapeHtml(candidate.workload ?? "-")}</div>
            </div>
            <div class="hr-detail-item full">
                <p class="hr-detail-label">Skills</p>
                <div class="hr-detail-value">${escapeHtml(skills)}</div>
            </div>
            <div class="hr-detail-item full">
                <p class="hr-detail-label">Resume Text</p>
                <div class="hr-detail-value">${escapeHtml(resumeText)}</div>
            </div>
        </div>
    `;
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
        hrCandidateOutput.innerHTML = renderHrCandidateDetailHtml(data.candidate || data);
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
            hrAiOutput.innerHTML = renderHrInsightHtml(data.insight || data);
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

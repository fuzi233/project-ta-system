<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_TA.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Jobs - TA Recruitment System</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        :root {
            --bg: #eef2f6;
            --panel: #ffffff;
            --text: #1f2937;
            --muted: #6b7280;
            --line: #d7dee8;
            --primary: #9cb8d3;
            --primary-dark: #7f9fbe;
            --shadow: 0 10px 24px rgba(31, 41, 55, 0.08);
            --radius-lg: 22px;
            --radius-md: 14px;
            --radius-sm: 10px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: linear-gradient(180deg, #edf2f7 0%, #e9eef5 100%);
            color: var(--text);
        }

        .page {
            max-width: 1280px;
            margin: 40px auto;
            padding: 0 24px;
        }

        .shell {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid #e2e8f0;
            border-radius: 24px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .topbar {
            height: 72px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 28px;
            border-bottom: 1px solid var(--line);
            background: rgba(255,255,255,0.95);
        }

        .brand {
            font-size: 18px;
            font-weight: 700;
            color: #334155;
        }

        .nav {
            display: flex;
            gap: 32px;
            align-items: center;
        }

        .nav a {
            text-decoration: none;
            color: #475569;
            font-size: 16px;
            font-weight: 500;
            padding: 24px 0 20px;
            border-bottom: 3px solid transparent;
        }

        .nav a.active {
            color: #0f172a;
            border-bottom-color: #718096;
        }

        .content {
            padding: 36px 34px 40px;
        }

        .page-title {
            margin: 0 0 28px;
            font-size: 48px;
            font-weight: 800;
            color: #10213f;
        }

        .toolbar {
            display: grid;
            grid-template-columns: 1.8fr 0.8fr 0.8fr 0.8fr auto;
            gap: 12px;
            margin-bottom: 28px;
        }

        .selection-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 14px 18px;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            background: #f8fafc;
            margin-bottom: 22px;
            flex-wrap: wrap;
        }

        .selection-count {
            font-size: 16px;
            font-weight: 600;
            color: #334155;
        }

        .selection-hint {
            font-size: 14px;
            color: #9a4a4a;
            min-height: 18px;
        }

        .input,
        .select,
        .btn {
            height: 54px;
            border-radius: 12px;
            border: 1px solid #ced8e3;
            background: #fff;
            font-size: 16px;
        }

        .input,
        .select {
            padding: 0 16px;
            color: #334155;
        }

        .btn-filter {
            background: #f8fafc;
            color: #334155;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin: 8px 0 28px;
        }

        .job-list {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .job-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            padding: 28px 28px;
            box-shadow: 0 6px 16px rgba(15, 23, 42, 0.04);
        }

        .job-select {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 16px;
            color: #334155;
        }

        .job-select input {
            width: 18px;
            height: 18px;
            accent-color: #86a8c5;
        }

        .job-main h2 {
            margin: 0 0 14px;
            font-size: 24px;
            font-weight: 800;
            color: #1e293b;
        }

        .job-meta {
            display: flex;
            flex-direction: column;
            gap: 8px;
            color: #64748b;
            font-size: 18px;
        }

        .job-actions {
            display: flex;
            gap: 14px;
            flex-shrink: 0;
        }

        .action-btn {
            min-width: 132px;
            height: 52px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .action-btn.btn {
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            border: none;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 0;
            margin-top: 26px;
        }

        .page-btn {
            width: 46px;
            height: 42px;
            border: 1px solid #d0d9e4;
            background: #fff;
            color: #475569;
            font-size: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
        }

        .page-btn:first-child {
            border-radius: 10px 0 0 10px;
        }

        .page-btn:last-child {
            border-radius: 0 10px 10px 0;
        }

        .page-btn.active {
            background: #a6bfd8;
            color: #fff;
        }

        .empty-tip {
            display: none;
            text-align: center;
            padding: 36px 0 12px;
            color: #64748b;
            font-size: 18px;
        }

        @media (max-width: 1024px) {
            .toolbar {
                grid-template-columns: 1fr 1fr;
            }

            .job-card {
                flex-direction: column;
                align-items: flex-start;
            }

            .job-actions {
                width: 100%;
            }
        }

        @media (max-width: 720px) {
            .page {
                padding: 0 14px;
                margin: 20px auto;
            }

            .topbar {
                flex-direction: column;
                height: auto;
                gap: 10px;
                padding: 18px;
            }

            .nav {
                gap: 16px;
                flex-wrap: wrap;
                justify-content: center;
            }

            .content {
                padding: 24px 18px 30px;
            }

            .page-title {
                font-size: 34px;
            }

            .toolbar {
                grid-template-columns: 1fr;
            }

            .job-actions {
                flex-direction: column;
            }

            .action-btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<div class="page">
    <div class="shell">
        <header class="topbar">
            <div class="brand">TA Recruitment System</div>
            <nav class="nav">
                <a href="index.jsp">Home</a>
                <a href="jobs.jsp" class="active">Job List</a>
                <a href="applications.jsp">My Applications</a>
                <a href="profile.jsp">Profile</a>
            </nav>
        </header>

        <main class="content">
            <h1 class="page-title">Available Jobs</h1>

            <div class="toolbar">
                <input id="searchInput" class="input" type="text" placeholder="Search jobs...">
                <select id="typeFilter" class="select">
                    <option value="">All</option>
                    <option value="programming">Programming</option>
                    <option value="database">Database</option>
                    <option value="web">Web</option>
                </select>
                <select id="skillFilter" class="select">
                    <option value="">Skills</option>
                    <option value="java">Java</option>
                    <option value="sql">SQL</option>
                    <option value="html">HTML/CSS</option>
                </select>
                <select id="semesterFilter" class="select">
                    <option value="">Semester</option>
                    <option value="spring">Spring</option>
                    <option value="autumn">Autumn</option>
                </select>
                <button class="btn ghost" onclick="filterJobs()">Filter</button>
            </div>

            <div class="divider"></div>

            <div class="selection-bar">
                <div>
                    <div id="selectedCount" class="selection-count">0 jobs selected</div>
                    <div id="selectionHint" class="selection-hint"></div>
                </div>
                <button id="applySelectedBtn" class="btn action-btn" type="button">Apply to Selected Jobs</button>
            </div>

            <section id="jobList" class="job-list">
                <article class="job-card"
                         data-title="programming ta"
                         data-type="programming"
                         data-skill="java"
                         data-semester="spring">
                    <div class="job-select">
                        <input type="checkbox" class="job-checkbox" data-job-id="1" aria-label="Select Programming TA"/>
                        <span>Select</span>
                    </div>
                    <div class="job-main">
                        <h2>Programming TA</h2>
                        <div class="job-meta">
                            <div>Course: Java Programming</div>
                            <div>Deadline: Jan 25, 2024</div>
                        </div>
                    </div>
                    <div class="job-actions">
                        <a class="action-btn btn ghost" href="job-detail.jsp?id=1">View Details</a>
                        <a class="action-btn btn" href="apply.jsp?id=1">Apply</a>
                    </div>
                </article>

                <article class="job-card"
                         data-title="database ta"
                         data-type="database"
                         data-skill="sql"
                         data-semester="spring">
                    <div class="job-select">
                        <input type="checkbox" class="job-checkbox" data-job-id="2" aria-label="Select Database TA"/>
                        <span>Select</span>
                    </div>
                    <div class="job-main">
                        <h2>Database TA</h2>
                        <div class="job-meta">
                            <div>Course: Database Systems</div>
                            <div>Deadline: Jan 30, 2024</div>
                        </div>
                    </div>
                    <div class="job-actions">
                        <a class="action-btn btn ghost" href="job-detail.jsp?id=2">View Details</a>
                        <a class="action-btn btn" href="apply.jsp?id=2">Apply</a>
                    </div>
                </article>

                <article class="job-card"
                         data-title="web development ta"
                         data-type="web"
                         data-skill="html"
                         data-semester="spring">
                    <div class="job-select">
                        <input type="checkbox" class="job-checkbox" data-job-id="3" aria-label="Select Web Development TA"/>
                        <span>Select</span>
                    </div>
                    <div class="job-main">
                        <h2>Web Development TA</h2>
                        <div class="job-meta">
                            <div>Course: Web Technologies</div>
                            <div>Deadline: Feb 5, 2024</div>
                        </div>
                    </div>
                    <div class="job-actions">
                        <a class="action-btn btn ghost" href="job-detail.jsp?id=3">View Details</a>
                        <a class="action-btn btn" href="apply.jsp?id=3">Apply</a>
                    </div>
                </article>
            </section>

            <div id="emptyTip" class="empty-tip">No jobs match your current filters.</div>

            <div class="pagination">
                <a class="page-btn active" href="#">1</a>
                <a class="page-btn" href="#">2</a>
                <a class="page-btn" href="#">3</a>
                <a class="page-btn" href="#">›</a>
            </div>
        </main>
    </div>
</div>

<script>
    function updateSelectedCount() {
        const selected = document.querySelectorAll(".job-checkbox:checked");
        const countEl = document.getElementById("selectedCount");
        const hintEl = document.getElementById("selectionHint");
        const count = selected.length;
        countEl.textContent = count + " jobs selected";
        if (count > 0) {
            hintEl.textContent = "";
        }
    }

    function getSelectedJobIds() {
        return Array.from(document.querySelectorAll(".job-checkbox:checked"))
            .map((el) => el.dataset.jobId)
            .filter(Boolean);
    }

    document.querySelectorAll(".job-checkbox").forEach((checkbox) => {
        checkbox.addEventListener("change", updateSelectedCount);
    });

    document.getElementById("applySelectedBtn").addEventListener("click", () => {
        const hintEl = document.getElementById("selectionHint");
        const selected = getSelectedJobIds();
        if (!selected.length) {
            hintEl.textContent = "Please select at least one job before applying.";
            return;
        }
        const jobParam = encodeURIComponent(selected.join(","));
        window.location.href = "apply.jsp?jobId=" + jobParam;
    });

    function filterJobs() {
        const keyword = document.getElementById("searchInput").value.trim().toLowerCase();
        const type = document.getElementById("typeFilter").value;
        const skill = document.getElementById("skillFilter").value;
        const semester = document.getElementById("semesterFilter").value;

        const cards = document.querySelectorAll(".job-card");
        const emptyTip = document.getElementById("emptyTip");

        let visibleCount = 0;

        cards.forEach(card => {
            const title = card.dataset.title;
            const cardType = card.dataset.type;
            const cardSkill = card.dataset.skill;
            const cardSemester = card.dataset.semester;

            const matchKeyword = !keyword || title.includes(keyword);
            const matchType = !type || cardType === type;
            const matchSkill = !skill || cardSkill === skill;
            const matchSemester = !semester || cardSemester === semester;

            if (matchKeyword && matchType && matchSkill && matchSemester) {
                card.style.display = "flex";
                visibleCount++;
            } else {
                card.style.display = "none";
            }
        });

        emptyTip.style.display = visibleCount === 0 ? "block" : "none";
    }

    updateSelectedCount();
</script>
</body>
</html>

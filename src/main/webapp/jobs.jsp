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
            --bg: #eef3ff;
            --panel: rgba(255, 255, 255, 0.92);
            --text: #102039;
            --muted: #4c5e7a;
            --line: #d6e4ff;
            --primary: #1575ff;
            --primary-dark: #0094ff;
            --accent: #00b7a5;
            --shadow: 0 24px 50px rgba(16, 32, 57, 0.15);
            --radius-lg: 22px;
            --radius-md: 14px;
            --radius-sm: 10px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "SF Pro Text", "SF Pro Display", "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            background: radial-gradient(circle at 20% 15%, #ffffff 0%, #eef3ff 45%, #d9e8ff 100%);
            color: var(--text);
        }

        .page {
            max-width: 1280px;
            margin: 40px auto;
            padding: 0 24px;
        }

        .shell {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid var(--line);
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
            font-size: 1rem;
            font-weight: 700;
            color: #16315b;
        }

        .nav {
            display: flex;
            gap: 32px;
            align-items: center;
        }

        .nav a {
            text-decoration: none;
            color: var(--muted);
            font-size: .95rem;
            font-weight: 500;
            padding: 24px 0 20px;
            border-bottom: 3px solid transparent;
        }

        .nav a.active {
            color: #16315b;
            border-bottom-color: #1575ff;
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
            color: #16315b;
        }

        .btn {
            padding: 0 22px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .btn-filter {
            background: #f8fafc;
            color: #16315b;
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
            color: var(--muted);
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
            border-radius: 12px;
            border: 1px solid #c2d6ff;
            background: rgba(255, 255, 255, 0.9);
            color: #16315b;
            font-size: .95rem;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }

        .action-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .action-btn.primary {
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
            color: var(--muted);
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
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
        }

        .empty-tip {
            display: none;
            text-align: center;
            padding: 36px 0 12px;
            color: var(--muted);
            font-size: 18px;
        }

        .job-check {
            display: flex;
            align-items: center;
            flex-shrink: 0;
            cursor: pointer;
        }

        .job-check input {
            width: 20px;
            height: 20px;
            accent-color: #1575ff;
            cursor: pointer;
        }

        .selection-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            padding: 16px 20px;
            margin-bottom: 20px;
            border: 1px solid #d6e4ff;
            border-radius: 14px;
            background: rgba(255,255,255,0.88);
            backdrop-filter: blur(12px);
        }

        .selection-count {
            font-size: 1rem;
            font-weight: 700;
            color: #16315b;
        }

        .selection-msg {
            display: none;
            margin-bottom: 16px;
            padding: 12px 16px;
            border-radius: 12px;
            background: #fef3c7;
            border: 1px solid #fcd34d;
            color: #92400e;
            font-size: .9rem;
            font-weight: 600;
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
<div class="bg-orb orb-a"></div>
<div class="bg-orb orb-b"></div>
<div class="page">
    <a class="link" href="index.jsp">&larr; Exit</a>
    <div class="shell">
        <header class="topbar">
            <div class="brand">TA Recruitment System</div>
            <nav class="nav">
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
                <button class="btn btn-filter" onclick="filterJobs()">Filter</button>
            </div>

            <div class="divider"></div>

            <div id="selectionBar" class="selection-bar" style="display:none;">
                <span id="selectionCount" class="selection-count">0 jobs selected</span>
                <button id="batchApplyBtn" class="action-btn primary">Apply to Selected Jobs</button>
            </div>

            <section id="jobList" class="job-list">
                <article class="job-card"
                         data-job-id="1"
                         data-title="programming ta"
                         data-type="programming"
                         data-skill="java"
                         data-semester="spring">
                    <label class="job-check">
                        <input type="checkbox" class="job-checkbox" data-job-id="1" onchange="updateSelection()"/>
                    </label>
                    <div class="job-main">
                        <h2>Programming TA</h2>
                        <div class="job-meta">
                            <div>Course: Java Programming</div>
                            <div>Deadline: Jan 25, 2024</div>
                        </div>
                    </div>
                    <div class="job-actions">
                        <a class="action-btn" href="job-detail.jsp?id=1">View Details</a>
                    </div>
                </article>

                <article class="job-card"
                         data-job-id="2"
                         data-title="database ta"
                         data-type="database"
                         data-skill="sql"
                         data-semester="spring">
                    <label class="job-check">
                        <input type="checkbox" class="job-checkbox" data-job-id="2" onchange="updateSelection()"/>
                    </label>
                    <div class="job-main">
                        <h2>Database TA</h2>
                        <div class="job-meta">
                            <div>Course: Database Systems</div>
                            <div>Deadline: Jan 30, 2024</div>
                        </div>
                    </div>
                    <div class="job-actions">
                        <a class="action-btn" href="job-detail.jsp?id=2">View Details</a>
                    </div>
                </article>

                <article class="job-card"
                         data-job-id="3"
                         data-title="web development ta"
                         data-type="web"
                         data-skill="html"
                         data-semester="spring">
                    <label class="job-check">
                        <input type="checkbox" class="job-checkbox" data-job-id="3" onchange="updateSelection()"/>
                    </label>
                    <div class="job-main">
                        <h2>Web Development TA</h2>
                        <div class="job-meta">
                            <div>Course: Web Technologies</div>
                            <div>Deadline: Feb 5, 2024</div>
                        </div>
                    </div>
                    <div class="job-actions">
                        <a class="action-btn" href="job-detail.jsp?id=3">View Details</a>
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

<div id="selectionMsg" class="selection-msg">Please select at least one job to apply.</div>

<script>
    function updateSelection() {
        var checkboxes = document.querySelectorAll(".job-checkbox:checked");
        var count = checkboxes.length;
        var bar = document.getElementById("selectionBar");
        var countEl = document.getElementById("selectionCount");
        var msg = document.getElementById("selectionMsg");

        if (count === 0) {
            bar.style.display = "none";
            msg.style.display = "none";
        } else {
            bar.style.display = "flex";
            countEl.textContent = count + (count === 1 ? " job selected" : " jobs selected");
        }
    }

    document.getElementById("batchApplyBtn").addEventListener("click", function() {
        var checkboxes = document.querySelectorAll(".job-checkbox:checked");
        var jobIds = [];
        checkboxes.forEach(function(cb) { jobIds.push(cb.getAttribute("data-job-id")); });

        if (jobIds.length === 0) {
            var msg = document.getElementById("selectionMsg");
            msg.style.display = "block";
            return;
        }
        window.location.href = "apply.jsp?jobIds=" + jobIds.join(",");
    });

    function filterJobs() {
        var keyword = document.getElementById("searchInput").value.trim().toLowerCase();
        var type = document.getElementById("typeFilter").value;
        var skill = document.getElementById("skillFilter").value;
        var semester = document.getElementById("semesterFilter").value;
        var cards = document.querySelectorAll(".job-card");
        var emptyTip = document.getElementById("emptyTip");
        var visibleCount = 0;

        cards.forEach(function(card) {
            var title = card.dataset.title;
            var cardType = card.dataset.type;
            var cardSkill = card.dataset.skill;
            var cardSemester = card.dataset.semester;
            var matchKeyword = !keyword || title.includes(keyword);
            var matchType = !type || cardType === type;
            var matchSkill = !skill || cardSkill === skill;
            var matchSemester = !semester || cardSemester === semester;
            if (matchKeyword && matchType && matchSkill && matchSemester) {
                card.style.display = "flex";
                visibleCount++;
            } else {
                card.style.display = "none";
            }
        });
        emptyTip.style.display = visibleCount === 0 ? "block" : "none";
    }
</script>
</body>
</html>

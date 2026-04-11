<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Applications - TA Recruitment System</title>
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

            --pending-bg: #f6edd8;
            --pending-text: #8a6d1d;

            --accepted-bg: #dfeedd;
            --accepted-text: #3f6c45;

            --rejected-bg: #f5dddd;
            --rejected-text: #9a4a4a;
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
            background: rgba(255, 255, 255, 0.95);
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
            background: rgba(255,255,255,0.96);
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
            padding: 30px 34px 40px;
        }

        .breadcrumb {
            font-size: 15px;
            color: #64748b;
            margin-bottom: 22px;
        }

        .breadcrumb a {
            color: #64748b;
            text-decoration: none;
        }

        .title {
            margin: 0 0 22px;
            font-size: 46px;
            font-weight: 800;
            color: #10213f;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin-bottom: 20px;
        }

        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            margin-bottom: 26px;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            flex-wrap: wrap;
            gap: 0;
            border: 1px solid #d2dbe6;
            border-radius: 12px;
            overflow: hidden;
            background: #fff;
        }

        .filter-btn {
            height: 50px;
            min-width: 120px;
            border: none;
            background: #fff;
            color: #475569;
            font-size: 16px;
            font-weight: 500;
            border-right: 1px solid #d2dbe6;
            cursor: pointer;
            position: relative;
        }

        .filter-btn:last-child {
            border-right: none;
        }

        .filter-btn.active {
            background: #a7bfd7;
            color: #fff;
        }

        .badge-count {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 24px;
            height: 24px;
            padding: 0 6px;
            border-radius: 999px;
            margin-left: 6px;
            font-size: 13px;
            background: rgba(15, 23, 42, 0.08);
            color: inherit;
        }

        .sort-box {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 18px;
            color: #475569;
        }

        .sort-select {
            height: 50px;
            min-width: 220px;
            border: 1px solid #d2dbe6;
            border-radius: 12px;
            padding: 0 16px;
            font-size: 16px;
            background: #fff;
            color: #334155;
        }

        .application-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .application-card {
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            padding: 24px 26px;
            box-shadow: 0 6px 16px rgba(15, 23, 42, 0.04);
            display: flex;
            justify-content: space-between;
            gap: 20px;
            align-items: center;
        }

        .application-main h2 {
            margin: 0 0 12px;
            font-size: 22px;
            font-weight: 800;
            color: #1e293b;
        }

        .application-meta {
            font-size: 17px;
            color: #64748b;
            line-height: 1.8;
        }

        .status-row {
            margin-top: 8px;
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap;
        }

        .status-tag {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 15px;
            font-weight: 600;
        }

        .pending {
            background: var(--pending-bg);
            color: var(--pending-text);
        }

        .accepted {
            background: var(--accepted-bg);
            color: var(--accepted-text);
        }

        .rejected {
            background: var(--rejected-bg);
            color: var(--rejected-text);
        }

        .application-actions {
            display: flex;
            gap: 12px;
            flex-shrink: 0;
        }

        .action-btn {
            min-width: 130px;
            height: 50px;
            border-radius: 12px;
            border: 1px solid #ccd6e2;
            background: #fff;
            color: #334155;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .action-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 18px rgba(31, 41, 55, 0.08);
        }

        .action-btn.withdraw {
            background: linear-gradient(135deg, #9db7d0 0%, #86a8c5 100%);
            color: #fff;
            border: none;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 0;
            margin-top: 24px;
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

        .empty-box {
            display: none;
            text-align: center;
            padding: 38px 20px 8px;
            color: #64748b;
            font-size: 18px;
        }

        @media (max-width: 960px) {
            .application-card {
                flex-direction: column;
                align-items: flex-start;
            }

            .application-actions {
                width: 100%;
                flex-wrap: wrap;
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

            .title {
                font-size: 34px;
            }

            .filter-group {
                width: 100%;
            }

            .filter-btn {
                min-width: 96px;
                flex: 1;
            }

            .sort-box {
                width: 100%;
                flex-direction: column;
                align-items: flex-start;
            }

            .sort-select {
                width: 100%;
            }

            .application-actions {
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
                <a href="jobs.jsp">Job List</a>
                <a href="applications.jsp" class="active">My Applications</a>
                <a href="profile.jsp">Profile</a>
            </nav>
        </header>

        <main class="content">
            <div class="breadcrumb">
                <a href="index.jsp">Home</a> &nbsp;›&nbsp; My Applications
            </div>

            <h1 class="title">My Applications</h1>
            <div class="divider"></div>

            <div class="toolbar">
                <div class="filter-group">
                    <button class="filter-btn active" onclick="filterStatus('all', this)">
                        All <span class="badge-count">4</span>
                    </button>
                    <button class="filter-btn" onclick="filterStatus('pending', this)">
                        Pending <span class="badge-count">1</span>
                    </button>
                    <button class="filter-btn" onclick="filterStatus('accepted', this)">
                        Accepted <span class="badge-count">2</span>
                    </button>
                    <button class="filter-btn" onclick="filterStatus('rejected', this)">
                        Rejected <span class="badge-count">1</span>
                    </button>
                </div>

                <div class="sort-box">
                    <span>Sort by:</span>
                    <select class="sort-select">
                        <option>Most Recent</option>
                        <option>Oldest First</option>
                    </select>
                </div>
            </div>

            <section id="applicationList" class="application-list">
                <article class="application-card" data-status="pending">
                    <div class="application-main">
                        <h2>Programming TA</h2>
                        <div class="application-meta">
                            <div>Course: Java Programming</div>
                        </div>
                        <div class="status-row">
                            <span class="status-tag pending">Pending</span>
                            <span class="application-meta">Applied: Jan 20, 2024</span>
                        </div>
                    </div>
                    <div class="application-actions">
                        <a class="action-btn" href="application-detail.jsp?id=1">View Details</a>
                        <button class="action-btn withdraw" onclick="withdrawApplication('Programming TA')">Withdraw</button>
                    </div>
                </article>

                <article class="application-card" data-status="accepted">
                    <div class="application-main">
                        <h2>Database TA</h2>
                        <div class="application-meta">
                            <div>Course: Database Systems</div>
                        </div>
                        <div class="status-row">
                            <span class="status-tag accepted">Accepted</span>
                            <span class="application-meta">Applied: Jan 15, 2024</span>
                        </div>
                    </div>
                    <div class="application-actions">
                        <a class="action-btn" href="application-detail.jsp?id=2">View Details</a>
                    </div>
                </article>

                <article class="application-card" data-status="accepted">
                    <div class="application-main">
                        <h2>Web Development TA</h2>
                        <div class="application-meta">
                            <div>Course: Web Technologies</div>
                        </div>
                        <div class="status-row">
                            <span class="status-tag accepted">Accepted</span>
                            <span class="application-meta">Applied: Jan 14, 2024</span>
                        </div>
                    </div>
                    <div class="application-actions">
                        <a class="action-btn" href="application-detail.jsp?id=3">View Details</a>
                    </div>
                </article>

                <article class="application-card" data-status="rejected">
                    <div class="application-main">
                        <h2>Networking TA</h2>
                        <div class="application-meta">
                            <div>Course: Networking Fundamentals</div>
                        </div>
                        <div class="status-row">
                            <span class="status-tag rejected">Rejected</span>
                            <span class="application-meta">Applied: Jan 10, 2024</span>
                        </div>
                    </div>
                    <div class="application-actions">
                        <a class="action-btn" href="#">View Details</a>
                    </div>
                </article>
            </section>

            <div id="emptyBox" class="empty-box">No applications found for this status.</div>

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
    function filterStatus(status, button) {
        const cards = document.querySelectorAll(".application-card");
        const emptyBox = document.getElementById("emptyBox");
        const buttons = document.querySelectorAll(".filter-btn");

        buttons.forEach(btn => btn.classList.remove("active"));
        button.classList.add("active");

        let visibleCount = 0;

        cards.forEach(card => {
            const cardStatus = card.getAttribute("data-status");

            if (status === "all" || cardStatus === status) {
                card.style.display = "flex";
                visibleCount++;
            } else {
                card.style.display = "none";
            }
        });

        emptyBox.style.display = visibleCount === 0 ? "block" : "none";
    }

    function withdrawApplication(jobTitle) {
        const confirmed = confirm("Are you sure you want to withdraw your application for " + jobTitle + "?");
        if (confirmed) {
            alert("Application withdrawn successfully.");
        }
    }
</script>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TA Recruitment System</title>
    <style>
        :root {
            --bg: #eef2f6;
            --card: #ffffff;
            --text: #1f2937;
            --muted: #6b7280;
            --line: #d6dde6;
            --primary: #8fb3d1;
            --primary-dark: #6f97bb;
            --shadow: 0 10px 30px rgba(31, 41, 55, 0.08);
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
            margin: 48px auto;
            padding: 0 24px;
        }

        .hero {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 28px;
            box-shadow: var(--shadow);
            padding: 54px 52px 48px;
            border: 1px solid #e5ebf2;
        }

        .school {
            font-size: 14px;
            letter-spacing: 4px;
            color: #64748b;
            margin-bottom: 22px;
            text-transform: uppercase;
        }

        .title {
            margin: 0;
            font-size: 64px;
            line-height: 1.08;
            font-weight: 800;
            color: #10213f;
        }

        .subtitle {
            margin: 26px 0 32px;
            font-size: 18px;
            color: #667085;
        }

        .action-row {
            display: flex;
            gap: 18px;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 170px;
            height: 58px;
            padding: 0 24px;
            border-radius: 16px;
            border: 1px solid #cfd9e5;
            background: #fff;
            color: #183153;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 20px rgba(17, 24, 39, 0.08);
        }

        .btn-primary {
            background: linear-gradient(135deg, #1f8fff 0%, #2bb8c7 100%);
            color: #fff;
            border: none;
        }

        .section-divider {
            height: 1px;
            background: #d9e1ea;
            margin: 28px 0 26px;
        }

        .cards {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 22px;
        }

        .card {
            background: rgba(255, 255, 255, 0.92);
            border-radius: 26px;
            box-shadow: var(--shadow);
            padding: 32px 30px 28px;
            min-height: 250px;
            border: 1px solid #e6ecf3;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .card-title {
            margin: 0 0 18px;
            font-size: 30px;
            font-weight: 800;
            color: #10213f;
        }

        .card-desc {
            font-size: 17px;
            line-height: 1.55;
            color: #334155;
            margin: 0 0 26px;
        }

        .card-link {
            display: inline-block;
            margin-top: auto;
            font-size: 16px;
            font-weight: 700;
            color: #1f6fe5;
            text-decoration: none;
        }

        .card-link:hover {
            text-decoration: underline;
        }

        @media (max-width: 980px) {
            .title {
                font-size: 46px;
            }

            .cards {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 640px) {
            .page {
                margin: 24px auto;
                padding: 0 14px;
            }

            .hero {
                padding: 30px 22px;
                border-radius: 20px;
            }

            .title {
                font-size: 36px;
            }

            .subtitle {
                font-size: 16px;
            }

            .btn {
                width: 100%;
            }

            .action-row {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<div class="page">
    <section class="hero">
        <div class="school">BUPT INTERNATIONAL SCHOOL</div>

        <h1 class="title">TA Recruitment System</h1>

        <p class="subtitle">
            iPhone-inspired interface, stable text-file backend, agile delivery.
        </p>

        <div class="action-row">
            <a class="btn btn-primary" href="jobs.jsp">Browse Jobs</a>
            <a class="btn" href="mo-console.jsp">MO Console</a>
            <a class="btn" href="admin-dashboard.jsp">Admin Workload</a>
        </div>
    </section>

    <div class="section-divider"></div>

    <section class="cards">
        <div class="card">
            <div>
                <h2 class="card-title">TA</h2>
                <p class="card-desc">
                    Find open roles and submit applications with idempotent API behavior.
                </p>
            </div>
            <a class="card-link" href="jobs.jsp">Open TA Page</a>
        </div>

        <div class="card">
            <div>
                <h2 class="card-title">MO</h2>
                <p class="card-desc">
                    Post jobs quickly, keep required skills and module details structured.
                </p>
            </div>
            <a class="card-link" href="mo-console.jsp">Open MO Page</a>
        </div>

        <div class="card">
            <div>
                <h2 class="card-title">Admin</h2>
                <p class="card-desc">
                    Watch workload distribution and overloaded candidates in real time.
                </p>
            </div>
            <a class="card-link" href="admin-dashboard.jsp">Open Dashboard</a>
        </div>
    </section>
</div>
</body>
</html>

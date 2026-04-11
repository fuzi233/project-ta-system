<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_TA.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<%
    String id = request.getParameter("id");

    String jobTitle = "Programming TA";
    if ("2".equals(id)) {
        jobTitle = "Database TA";
    } else if ("3".equals(id)) {
        jobTitle = "Web Development TA";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply - <%= jobTitle %></title>
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
            font-size: 44px;
            font-weight: 800;
            color: #10213f;
        }

        .divider {
            height: 1px;
            background: #dbe3ec;
            margin-bottom: 26px;
        }

        .form-layout {
            display: grid;
            grid-template-columns: 1fr 1.8fr 0.75fr;
            gap: 16px;
        }

        .panel {
            background: #fff;
            border: 1px solid #d9e2ec;
            border-radius: 16px;
            overflow: hidden;
            min-height: 520px;
        }

        .panel-header {
            padding: 18px 20px;
            font-size: 18px;
            font-weight: 700;
            color: #334155;
            border-bottom: 1px solid #e5ebf2;
            background: #f8fafc;
        }

        .panel-body {
            padding: 20px;
        }

        .field {
            margin-bottom: 22px;
        }

        .field label {
            display: block;
            font-size: 16px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 8px;
        }

        .input,
        .textarea,
        .select,
        .file-input {
            width: 100%;
            border: 1px solid #ced8e3;
            border-radius: 10px;
            padding: 12px 14px;
            font-size: 16px;
            color: #334155;
            background: #fff;
        }

        .textarea {
            min-height: 120px;
            resize: vertical;
            font-family: inherit;
        }

        .hint {
            margin-top: 8px;
            font-size: 14px;
            color: #6b7280;
        }

        .action-col {
            display: flex;
            flex-direction: column;
            gap: 14px;
            padding: 18px 16px;
        }

        .action-btn {
            height: 52px;
            border-radius: 12px;
            border: 1px solid #ccd6e2;
            background: #fff;
            color: #334155;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .action-btn.primary {
            background: linear-gradient(135deg, #9db7d0 0%, #86a8c5 100%);
            color: #fff;
            border: none;
        }

        .footer-actions {
            display: flex;
            gap: 14px;
            margin-top: 18px;
        }

        .footer-btn {
            min-width: 170px;
            height: 52px;
            border-radius: 12px;
            border: 1px solid #ccd6e2;
            background: #fff;
            color: #334155;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
        }

        .footer-btn.primary {
            background: linear-gradient(135deg, #9db7d0 0%, #86a8c5 100%);
            color: #fff;
            border: none;
        }

        .success-box {
            display: none;
            margin-top: 22px;
            padding: 16px 18px;
            border-radius: 12px;
            background: #edf6ee;
            border: 1px solid #cfe4d1;
            color: #2f5d34;
            font-size: 16px;
            font-weight: 600;
        }

        @media (max-width: 1100px) {
            .form-layout {
                grid-template-columns: 1fr;
            }

            .panel {
                min-height: auto;
            }

            .action-col {
                padding: 0;
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

            .footer-actions {
                flex-direction: column;
            }

            .footer-btn {
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
            <div class="breadcrumb">
                <a href="index.jsp">Home</a> &nbsp;›&nbsp;
                <a href="jobs.jsp">Job List</a> &nbsp;›&nbsp;
                Apply for <%= jobTitle %>
            </div>

            <h1 class="title"><%= jobTitle %> Application Form</h1>
            <div class="divider"></div>

            <form id="applyForm" onsubmit="submitApplication(event)">
                <div class="form-layout">
                    <section class="panel">
                        <div class="panel-header">Personal Information</div>
                        <div class="panel-body">
                            <div class="field">
                                <label for="fullName">Full Name</label>
                                <input class="input" type="text" id="fullName" name="fullName">
                            </div>

                            <div class="field">
                                <label for="studentId">Student ID</label>
                                <input class="input" type="text" id="studentId" name="studentId">
                            </div>

                            <div class="field">
                                <label for="email">Email</label>
                                <input class="input" type="email" id="email" name="email" placeholder="example@student.com">
                            </div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="panel-header">Skills and Experience</div>
                        <div class="panel-body">
                            <div class="field">
                                <label for="skills">Skills</label>
                                <select class="select" id="skills" name="skills">
                                    <option value="">Select skills...</option>
                                    <option>Java</option>
                                    <option>SQL</option>
                                    <option>HTML/CSS</option>
                                    <option>JavaScript</option>
                                    <option>Git</option>
                                </select>
                            </div>

                            <div class="field">
                                <label for="experience">Experience</label>
                                <textarea class="textarea" id="experience" name="experience"
                                          placeholder="Describe your relevant experience..."></textarea>
                            </div>

                            <div class="field">
                                <label for="cvFile">Upload CV</label>
                                <input class="file-input" type="file" id="cvFile" name="cvFile">
                            </div>

                            <div class="field">
                                <label for="transcriptFile">Upload Transcript</label>
                                <input class="file-input" type="file" id="transcriptFile" name="transcriptFile">
                                <div class="hint">Accepted formats: PDF, DOC, DOCX</div>
                            </div>

                            <div class="footer-actions">
                                <button class="footer-btn primary" type="submit">Submit Application</button>
                                <button class="footer-btn" type="reset">Cancel</button>
                            </div>

                            <div id="successBox" class="success-box">
                                Application submitted successfully.
                            </div>
                        </div>
                    </section>

                    <section class="panel">
                        <div class="action-col">
                            <button class="action-btn primary" type="submit">Apply Now</button>
                            <a class="action-btn" href="jobs.jsp">Back</a>
                        </div>
                    </section>
                </div>
            </form>
        </main>
    </div>
</div>

<script>
    function submitApplication(event) {
        event.preventDefault();

        const fullName = document.getElementById("fullName").value.trim();
        const studentId = document.getElementById("studentId").value.trim();
        const email = document.getElementById("email").value.trim();
        const skills = document.getElementById("skills").value.trim();
        const experience = document.getElementById("experience").value.trim();

        if (!fullName) {
            alert("Please enter your full name.");
            return;
        }

        if (!studentId) {
            alert("Please enter your student ID.");
            return;
        }

        if (!email) {
            alert("Please enter your email.");
            return;
        }

        if (!skills) {
            alert("Please select at least one skill.");
            return;
        }

        if (!experience) {
            alert("Please fill in your experience.");
            return;
        }

        document.getElementById("successBox").style.display = "block";

        setTimeout(function () {
            window.location.href = "applications.jsp";
        }, 1200);
    }
</script>
</body>
</html>

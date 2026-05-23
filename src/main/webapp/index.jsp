<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    boolean isLoggedIn = (role != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TA Recruitment - BUPT</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        :root {
            --bg: #eef3ff;
            --text: #102039;
            --muted: #4c5e7a;
            --line: #d6e4ff;
            --primary: #1575ff;
            --accent: #00b7a5;
            --shadow: 0 24px 50px rgba(16, 32, 57, 0.15);
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "SF Pro Text", "Segoe UI", sans-serif;
            background: radial-gradient(circle at 20% 15%, #ffffff 0%, #eef3ff 45%, #d9e8ff 100%);
            color: var(--text);
            min-height: 100vh;
        }
        .shell {
            width: min(1080px, calc(100% - 2rem));
            margin: 2rem auto 3rem;
            position: relative;
            z-index: 2;
        }
        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: .6rem 1.2rem;
            margin-bottom: 1rem;
            border: 1px solid var(--line);
            border-radius: 18px;
            background: rgba(255,255,255,0.78);
            backdrop-filter: blur(24px);
            box-shadow: var(--shadow);
        }
        .brand {
            font-size: 1.05rem;
            font-weight: 700;
            color: #0e3369;
        }
        .topbar-right {
            display: flex;
            align-items: center;
            gap: .8rem;
            position: relative;
        }
        .signin-btn {
            border: 1px solid #c2d6ff;
            border-radius: 10px;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            padding: .5rem 1rem;
            font-size: .88rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 120ms ease;
            text-decoration: none;
            display: inline-block;
        }
        .signin-btn:hover { transform: translateY(-1px); }
        .signin-btn.ghost {
            background: rgba(255,255,255,0.72);
            color: #0f2d58;
            border: 1px solid #c2d6ff;
        }

        .login-drop {
            display: none;
            position: absolute;
            right: 0;
            top: 100%;
            margin-top: 8px;
            width: 380px;
            max-width: calc(100vw - 2rem);
            background: rgba(255,255,255,0.96);
            backdrop-filter: blur(24px);
            border: 1px solid #d6e4ff;
            border-radius: 18px;
            box-shadow: 0 24px 50px rgba(16,32,57,0.2);
            padding: 1.4rem;
            z-index: 10;
        }
        .login-drop.show { display: block; animation: rise 240ms ease; }
        .login-drop h3 { margin: 0 0 .8rem; font-size: 1rem; color: #0e3369; }
        .login-drop .field { position: relative; margin-bottom: .7rem; }
        .login-drop input {
            width: 100%;
            border: 1px solid #c2d6ff;
            border-radius: 10px;
            padding: .65rem .75rem;
            font-size: .9rem;
            background: #fff;
            color: #16315b;
        }
        .login-drop input:focus { border-color: #1575ff; outline: none; }
        .login-drop .role-row {
            display: flex;
            gap: .4rem;
            margin-bottom: .7rem;
        }
        .login-drop .role-chip {
            flex: 1;
            border: 1px solid #c2d6ff;
            border-radius: 8px;
            background: #f8fafc;
            color: #475569;
            font-size: .8rem;
            font-weight: 600;
            padding: .4rem .3rem;
            cursor: pointer;
            text-align: center;
            transition: all 120ms ease;
        }
        .login-drop .role-chip.active {
            border-color: #1575ff;
            background: #eff6ff;
            color: #1575ff;
        }
        .login-drop .login-submit {
            width: 100%;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #1575ff, #0094ff 55%, #00b7a5);
            color: #fff;
            padding: .6rem;
            font-size: .9rem;
            font-weight: 700;
            cursor: pointer;
            margin-top: .3rem;
        }
        .login-drop .error-msg { color: #EF4444; font-size: .78rem; min-height: 16px; margin-bottom: .3rem; }
        .login-drop .bottom-note { text-align: center; font-size: .8rem; color: #64748B; margin-top: .6rem; }
        .login-drop .bottom-note button { border: 0; background: none; color: #1D4ED8; cursor: pointer; font-weight: 700; padding: 0; }
        .login-drop .demo-strip { display: flex; gap: .4rem; margin-top: .6rem; flex-wrap: wrap; }
        .login-drop .demo-btn {
            border: 1px solid #c2d6ff;
            border-radius: 8px;
            background: #f8fafc;
            color: #475569;
            font-size: .73rem;
            font-weight: 600;
            padding: .3rem .6rem;
            cursor: pointer;
        }

        .page-title { margin: 0 0 1.5rem; font-size: 2.2rem; font-weight: 800; color: #10213f; }
        .job-list { display: flex; flex-direction: column; gap: 1rem; }
        .job-card {
            display: flex;
            align-items: center;
            gap: 1.2rem;
            border: 1px solid #d6e4ff;
            border-radius: 16px;
            padding: 1.4rem 1.4rem;
            background: rgba(255,255,255,0.72);
            backdrop-filter: blur(12px);
            box-shadow: 0 6px 16px rgba(15,23,42,0.04);
        }
        .job-check { display: flex; align-items: center; flex-shrink: 0; cursor: pointer; }
        .job-check input { width: 20px; height: 20px; accent-color: #1575ff; cursor: pointer; }
        .job-main { flex: 1; }
        .job-main h2 { margin: 0 0 .5rem; font-size: 1.3rem; font-weight: 800; color: #1e293b; }
        .job-meta { display: flex; gap: 1.2rem; color: var(--muted); font-size: .9rem; }
        .selection-bar {
            display: flex; align-items: center; justify-content: space-between; gap: 1rem;
            padding: .9rem 1.2rem; margin-bottom: 1rem;
            border: 1px solid #d6e4ff; border-radius: 14px;
            background: rgba(255,255,255,0.88); backdrop-filter: blur(12px);
        }
        .selection-count { font-size: .95rem; font-weight: 700; color: #16315b; }
        .selection-msg {
            display: none; margin-bottom: 1rem; padding: .7rem 1rem; border-radius: 12px;
            background: #fef3c7; border: 1px solid #fcd34d; color: #92400e; font-size: .85rem; font-weight: 600;
        }

        .toast {
            position: fixed; left: 50%; transform: translate(-50%, -140%); top: 18px;
            padding: .6rem 1rem; border-radius: 9999px; background: #10B981; color: #fff;
            font-size: .85rem; box-shadow: 0 10px 22px rgba(16,185,129,0.28);
            opacity: 0; pointer-events: none; transition: transform .3s ease, opacity .3s ease; z-index: 99;
        }
        .toast.show { transform: translate(-50%, 0); opacity: 1; }

        #loggedInBar { display: none; }
        @media (max-width: 720px) {
            .page-title { font-size: 1.6rem; }
            .job-card { flex-direction: column; align-items: flex-start; }
            .login-drop { width: calc(100vw - 2rem); right: -10px; }
        }
        @keyframes rise { from { opacity: 0; transform: translateY(9px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>
<div id="toast" class="toast" role="status">Ready</div>

<div class="shell">
    <header class="topbar">
        <div class="brand">TA Recruitment</div>
        <div class="topbar-right">
            <span id="loggedInBar">
                <span id="loggedInRole"></span> &middot;
                <a href="javascript:void(0)" onclick="signOut()" style="color:#1575ff;font-weight:600;">Sign Out</a>
            </span>
            <button id="signinToggle" class="signin-btn" onclick="toggleLogin()">Sign In</button>

            <div id="loginDrop" class="login-drop">
                <h3>Sign In</h3>
                <div class="role-row" id="loginRoleRow">
                    <button class="role-chip active" data-login-role="TA">TA</button>
                    <button class="role-chip" data-login-role="MO">MO</button>
                    <button class="role-chip" data-login-role="ADMIN">Admin</button>
                </div>
                <input type="hidden" id="loginRole" value="TA"/>
                <div class="field">
                    <input id="loginIdentifier" type="text" placeholder="Student ID / Staff ID / Username"/>
                </div>
                <div class="field">
                    <input id="loginPassword" type="password" placeholder="Password"/>
                </div>
                <div class="error-msg" id="loginError"></div>
                <button class="login-submit" onclick="doLogin()">Sign In</button>
                <div class="demo-strip">
                    <button class="demo-btn" data-demo-role="TA" data-demo-id="ta001@bupt.edu.cn" data-demo-pw="TaDemo@123">TA Demo</button>
                    <button class="demo-btn" data-demo-role="MO" data-demo-id="mo001@bupt.edu.cn" data-demo-pw="MoDemo@123">MO Demo</button>
                    <button class="demo-btn" data-demo-role="ADMIN" data-demo-id="hradmin" data-demo-pw="HrDemo@123">Admin Demo</button>
                </div>
                <div class="bottom-note">
                    Need an account? <button onclick="window.location.href='register.jsp'">Create account</button>
                </div>
            </div>
        </div>
    </header>

    <h1 class="page-title">Available TA Positions</h1>

    <div id="selectionBar" class="selection-bar" style="display:none;">
        <span id="selectionCount" class="selection-count">0 jobs selected</span>
        <button id="batchApplyBtn" class="signin-btn">Apply to Selected Jobs</button>
    </div>
    <div id="selectionMsg" class="selection-msg">Please select at least one job to apply.</div>

    <section id="jobList" class="job-list">
        <article class="job-card" data-job-id="1" data-title="programming ta">
            <label class="job-check">
                <input type="checkbox" class="job-checkbox" data-job-id="1" onchange="updateSelection()"/>
            </label>
            <div class="job-main">
                <h2>Programming TA</h2>
                <div class="job-meta">
                    <span>Course: Java Programming</span>
                    <span>Deadline: Jan 25, 2026</span>
                </div>
            </div>
            <a class="signin-btn ghost" href="job-detail.jsp?id=1">View Details</a>
        </article>

        <article class="job-card" data-job-id="2" data-title="database ta">
            <label class="job-check">
                <input type="checkbox" class="job-checkbox" data-job-id="2" onchange="updateSelection()"/>
            </label>
            <div class="job-main">
                <h2>Database TA</h2>
                <div class="job-meta">
                    <span>Course: Database Systems</span>
                    <span>Deadline: Jan 30, 2026</span>
                </div>
            </div>
            <a class="signin-btn ghost" href="job-detail.jsp?id=2">View Details</a>
        </article>

        <article class="job-card" data-job-id="3" data-title="web development ta">
            <label class="job-check">
                <input type="checkbox" class="job-checkbox" data-job-id="3" onchange="updateSelection()"/>
            </label>
            <div class="job-main">
                <h2>Web Development TA</h2>
                <div class="job-meta">
                    <span>Course: Web Technologies</span>
                    <span>Deadline: Feb 5, 2026</span>
                </div>
            </div>
            <a class="signin-btn ghost" href="job-detail.jsp?id=3">View Details</a>
        </article>
    </section>
</div>

<script>
    var loginRole = document.getElementById("loginRole");

    document.querySelectorAll("[data-login-role]").forEach(function(btn) {
        btn.addEventListener("click", function() {
            document.querySelectorAll("[data-login-role]").forEach(function(b) { b.classList.remove("active"); });
            btn.classList.add("active");
            loginRole.value = btn.getAttribute("data-login-role");
            document.getElementById("loginError").textContent = "";
        });
    });

    function toggleLogin() {
        document.getElementById("loginDrop").classList.toggle("show");
    }

    document.addEventListener("click", function(e) {
        var drop = document.getElementById("loginDrop");
        var toggle = document.getElementById("signinToggle");
        if (!drop.contains(e.target) && e.target !== toggle) {
            drop.classList.remove("show");
        }
    });

    document.querySelectorAll(".demo-btn").forEach(function(btn) {
        btn.addEventListener("click", function() {
            var r = btn.getAttribute("data-demo-role");
            document.querySelectorAll("[data-login-role]").forEach(function(b) {
                b.classList.toggle("active", b.getAttribute("data-login-role") === r);
            });
            loginRole.value = r;
            document.getElementById("loginIdentifier").value = btn.getAttribute("data-demo-id");
            document.getElementById("loginPassword").value = btn.getAttribute("data-demo-pw");
            document.getElementById("loginError").textContent = "";
            showToast("Demo credentials filled");
        });
    });

    async function doLogin() {
        var role = loginRole.value;
        var identifier = document.getElementById("loginIdentifier").value.trim();
        var password = document.getElementById("loginPassword").value;
        var error = document.getElementById("loginError");

        if (!identifier) { error.textContent = "Please enter your identifier."; return; }
        if (!password) { error.textContent = "Please enter your password."; return; }

        try {
            var resp = await fetch("auth/login", {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({role: role, identifier: identifier, password: password})
            });
            var result = await resp.json();
            if (!resp.ok) {
                error.textContent = result.error || "Login failed";
                return;
            }
            showToast("Signed in. Redirecting...");
            document.getElementById("loginDrop").classList.remove("show");
            setTimeout(function() {
                window.location.href = result.redirect || "index.jsp";
            }, 400);
        } catch (_) {
            error.textContent = "Network error, please try again";
        }
    }

    function signOut() {
        fetch("auth/logout", {method: "POST"}).then(function() {
            window.location.reload();
        });
    }

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
            document.getElementById("selectionMsg").style.display = "block";
            return;
        }
        window.location.href = "apply.jsp?jobIds=" + jobIds.join(",");
    });

    function showToast(msg) {
        var t = document.getElementById("toast");
        t.textContent = msg;
        t.classList.add("show");
        setTimeout(function() { t.classList.remove("show"); }, 2200);
    }

    <% if (isLoggedIn) { %>
    document.getElementById("signinToggle").style.display = "none";
    document.getElementById("loggedInBar").style.display = "inline";
    document.getElementById("loggedInRole").textContent = "<%= role %>";
    <% } %>
</script>
</body>
</html>

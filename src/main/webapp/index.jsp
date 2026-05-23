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
            --primary: #1575ff; --accent: #00b7a5; --muted: #4c5e7a;
            --line: #d6e4ff; --shadow: 0 24px 50px rgba(16,32,57,0.15);
        }
        *{box-sizing:border-box;}
        body{
            margin:0;font-family:"SF Pro Text","Segoe UI",sans-serif;
            background:radial-gradient(circle at 20% 15%,#ffffff 0%,#eef3ff 45%,#d9e8ff 100%);
            color:#102039;min-height:100vh;
        }
        .shell{width:min(1080px,calc(100% - 2rem));margin:2rem auto 3rem;position:relative;z-index:2;}
        .topbar{
            display:flex;align-items:center;justify-content:space-between;
            padding:.6rem 1.2rem;margin-bottom:1rem;
            border:1px solid var(--line);border-radius:18px;
            background:rgba(255,255,255,0.78);backdrop-filter:blur(24px);box-shadow:var(--shadow);
        }
        .brand{font-size:1.05rem;font-weight:700;color:#0e3369;}
        .topbar-right{display:flex;align-items:center;gap:.8rem;position:relative;}
        .signin-btn{
            border:1px solid #c2d6ff;border-radius:10px;
            background:linear-gradient(135deg,#1575ff,#0094ff 55%,#00b7a5);
            color:#fff;padding:.5rem 1rem;font-size:.88rem;font-weight:600;
            cursor:pointer;transition:transform 120ms ease;text-decoration:none;display:inline-block;
        }
        .signin-btn:hover{transform:translateY(-1px);}
        .signin-btn.ghost{background:rgba(255,255,255,0.72);color:#0f2d58;border:1px solid #c2d6ff;}

        .login-drop{
            display:none;position:absolute;right:0;top:100%;margin-top:8px;width:380px;
            max-width:calc(100vw - 2rem);background:rgba(255,255,255,0.96);
            backdrop-filter:blur(24px);border:1px solid #d6e4ff;border-radius:18px;
            box-shadow:0 24px 50px rgba(16,32,57,0.2);padding:1.4rem;z-index:10;
        }
        .login-drop.show{display:block;animation:rise 240ms ease;}
        .login-drop h3{margin:0 0 .8rem;font-size:1rem;color:#0e3369;}
        .login-drop .field{margin-bottom:.7rem;}
        .login-drop input{
            width:100%;border:1px solid #c2d6ff;border-radius:10px;
            padding:.65rem .75rem;font-size:.9rem;background:#fff;color:#16315b;
        }
        .login-drop input:focus{border-color:#1575ff;outline:none;}
        .login-drop .role-row{display:flex;gap:.4rem;margin-bottom:.7rem;}
        .login-drop .role-chip{
            flex:1;border:1px solid #c2d6ff;border-radius:8px;background:#f8fafc;
            color:#475569;font-size:.8rem;font-weight:600;padding:.4rem .3rem;
            cursor:pointer;text-align:center;transition:all 120ms ease;
        }
        .login-drop .role-chip.active{border-color:#1575ff;background:#eff6ff;color:#1575ff;}
        .login-drop .login-submit{
            width:100%;border:none;border-radius:10px;
            background:linear-gradient(135deg,#1575ff,#0094ff 55%,#00b7a5);
            color:#fff;padding:.6rem;font-size:.9rem;font-weight:700;cursor:pointer;margin-top:.3rem;
        }
        .login-drop .error-msg{color:#EF4444;font-size:.78rem;min-height:16px;margin-bottom:.3rem;}
        .login-drop .bottom-note{text-align:center;font-size:.8rem;color:#64748B;margin-top:.6rem;}
        .login-drop .bottom-note button{border:0;background:none;color:#1D4ED8;cursor:pointer;font-weight:700;padding:0;}
        .login-drop .demo-strip{display:flex;gap:.4rem;margin-top:.6rem;flex-wrap:wrap;}
        .login-drop .demo-btn{
            border:1px solid #c2d6ff;border-radius:8px;background:#f8fafc;
            color:#475569;font-size:.73rem;font-weight:600;padding:.3rem .6rem;cursor:pointer;
        }

        .page-title{margin:0 0 1.2rem;font-size:2rem;font-weight:800;color:#10213f;}
        .toolbar{display:flex;gap:.6rem;margin-bottom:1rem;flex-wrap:wrap;}
        .toolbar input,.toolbar select{
            border:1px solid #c2d6ff;border-radius:10px;padding:.6rem .8rem;
            font-size:.9rem;background:#fff;color:#16315b;
        }
        .toolbar input{flex:1;min-width:200px;}

        .selection-bar{
            display:flex;align-items:center;justify-content:space-between;gap:1rem;
            padding:.8rem 1.2rem;margin-bottom:1rem;
            border:1px solid #d6e4ff;border-radius:14px;
            background:rgba(255,255,255,0.88);backdrop-filter:blur(12px);
        }
        .sel-count{font-size:.92rem;font-weight:700;color:#0e3369;}

        .job-group{margin-bottom:1.2rem;}
        .group-head{
            display:flex;align-items:center;justify-content:space-between;gap:1rem;
            padding:.7rem 1rem;border-radius:14px;
            border:1px solid #d6e4ff;background:rgba(234,243,255,0.85);
            cursor:pointer;user-select:none;
        }
        .group-head:hover{background:rgba(220,235,255,0.9);}
        .group-head h3{margin:0;font-size:1rem;color:#12396a;}
        .group-meta{font-size:.82rem;color:var(--muted);}
        .group-arrow{transition:transform 200ms ease;font-size:.85rem;color:var(--muted);}
        .job-group.collapsed .group-arrow{transform:rotate(-90deg);}
        .group-body{display:flex;flex-direction:column;gap:.6rem;margin-top:.5rem;padding-left:.3rem;}
        .job-group.collapsed .group-body{display:none;}

        .job-card{
            display:flex;align-items:center;gap:1rem;
            border:1px solid #d6e4ff;border-radius:12px;padding:1rem;
            background:rgba(255,255,255,0.72);backdrop-filter:blur(12px);
            box-shadow:0 4px 12px rgba(15,23,42,0.03);
            transition:border-color 150ms ease;
        }
        .job-card:hover{border-color:#b0cbff;}
        .job-check{display:flex;align-items:center;flex-shrink:0;cursor:pointer;}
        .job-check input{width:18px;height:18px;accent-color:#1575ff;cursor:pointer;}
        .job-main{flex:1;}
        .job-main h4{margin:0 0 .3rem;font-size:1.05rem;font-weight:700;color:#1e293b;}
        .job-info{display:flex;gap:1.2rem;flex-wrap:wrap;font-size:.82rem;color:var(--muted);}
        .job-info span{white-space:nowrap;}
        .job-actions{display:flex;gap:.5rem;flex-shrink:0;}

        .empty-tip{display:none;text-align:center;padding:2rem;color:var(--muted);font-size:1rem;}
        .toast{
            position:fixed;left:50%;transform:translate(-50%,-140%);top:18px;
            padding:.6rem 1rem;border-radius:9999px;background:#10B981;color:#fff;
            font-size:.85rem;box-shadow:0 10px 22px rgba(16,185,129,0.28);
            opacity:0;pointer-events:none;transition:transform .3s ease,opacity .3s ease;z-index:99;
        }
        .toast.show{transform:translate(-50%,0);opacity:1;}
        #loggedInBar{display:none;}

        @media(max-width:720px){
            .page-title{font-size:1.5rem;}
            .job-card{flex-direction:column;align-items:flex-start;}
            .login-drop{width:calc(100vw - 2rem);right:-10px;}
            .toolbar{flex-direction:column;}
            .toolbar input{min-width:auto;}
        }
        @keyframes rise{from{opacity:0;transform:translateY(9px);}to{opacity:1;transform:translateY(0);}}
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
                <div class="role-row">
                    <button class="role-chip active" data-login-role="TA">TA</button>
                    <button class="role-chip" data-login-role="MO">MO</button>
                    <button class="role-chip" data-login-role="ADMIN">Admin</button>
                </div>
                <input type="hidden" id="loginRole" value="TA"/>
                <div class="field"><input id="loginIdentifier" type="text" placeholder="Student ID / Staff ID / Username"/></div>
                <div class="field"><input id="loginPassword" type="password" placeholder="Password"/></div>
                <div class="error-msg" id="loginError"></div>
                <button class="login-submit" onclick="doLogin()">Sign In</button>
                <div class="demo-strip">
                    <button class="demo-btn" data-demo-role="TA" data-demo-id="ta001@bupt.edu.cn" data-demo-pw="TaDemo@123">TA Demo</button>
                    <button class="demo-btn" data-demo-role="MO" data-demo-id="mo001@bupt.edu.cn" data-demo-pw="MoDemo@123">MO Demo</button>
                    <button class="demo-btn" data-demo-role="ADMIN" data-demo-id="hradmin" data-demo-pw="HrDemo@123">Admin Demo</button>
                </div>
                <div class="bottom-note">Need an account? <button onclick="window.location.href='register.jsp'">Create account</button></div>
            </div>
        </div>
    </header>

    <h1 class="page-title">Available TA Positions</h1>

    <div class="toolbar">
        <input id="searchInput" type="text" placeholder="Search by title, module, or skills..."/>
        <select id="statusFilter"><option value="OPEN">Open</option><option value="">All Status</option></select>
        <button class="signin-btn ghost" onclick="loadJobs()">Refresh</button>
    </div>

    <div id="selectionBar" class="selection-bar" style="display:none;">
        <span id="selCount" class="sel-count">0 jobs selected</span>
        <button id="batchApplyBtn" class="signin-btn">Apply to Selected Jobs</button>
    </div>

    <section id="jobArea"></section>
    <div id="emptyTip" class="empty-tip">No open positions at this time.</div>
</div>

<script>
    var loginRole = document.getElementById("loginRole");
    var state = { jobs: [], selected: new Set(), collapsed: {} };

    // ---- Login ----
    document.querySelectorAll("[data-login-role]").forEach(function(b) {
        b.addEventListener("click", function() {
            document.querySelectorAll("[data-login-role]").forEach(function(x){x.classList.remove("active");});
            b.classList.add("active");
            loginRole.value = b.getAttribute("data-login-role");
            document.getElementById("loginError").textContent = "";
        });
    });

    function toggleLogin() { document.getElementById("loginDrop").classList.toggle("show"); }
    document.addEventListener("click", function(e) {
        var d = document.getElementById("loginDrop");
        if (!d.contains(e.target) && e.target !== document.getElementById("signinToggle")) d.classList.remove("show");
    });

    document.querySelectorAll(".demo-btn").forEach(function(b) {
        b.addEventListener("click", function() {
            var r = b.getAttribute("data-demo-role");
            document.querySelectorAll("[data-login-role]").forEach(function(x){x.classList.toggle("active", x.getAttribute("data-login-role")===r);});
            loginRole.value = r;
            document.getElementById("loginIdentifier").value = b.getAttribute("data-demo-id");
            document.getElementById("loginPassword").value = b.getAttribute("data-demo-pw");
            document.getElementById("loginError").textContent = "";
            showToast("Demo credentials filled");
        });
    });

    async function doLogin() {
        var role = loginRole.value, id = document.getElementById("loginIdentifier").value.trim(), pw = document.getElementById("loginPassword").value;
        var err = document.getElementById("loginError");
        if (!id) { err.textContent = "Please enter your identifier."; return; }
        if (!pw) { err.textContent = "Please enter your password."; return; }
        try {
            var r = await fetch("auth/login", {method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({role:role,identifier:id,password:pw})});
            var j = await r.json();
            if (!r.ok) { err.textContent = j.error || "Login failed"; return; }
            showToast("Signed in. Redirecting...");
            document.getElementById("loginDrop").classList.remove("show");
            setTimeout(function(){ window.location.href = j.redirect || "index.jsp"; }, 400);
        } catch(_) { err.textContent = "Network error"; }
    }

    function signOut() { fetch("auth/logout",{method:"POST"}).then(function(){window.location.reload();}); }

    // ---- Jobs ----
    async function loadJobs() {
        var q = document.getElementById("searchInput").value.trim();
        var st = document.getElementById("statusFilter").value;
        var data = await api("/jobs?status=" + (st||"OPEN") + "&page=1&size=200&q=" + encodeURIComponent(q));
        state.jobs = data.items || [];
        groupAndRender();
    }

    function groupAndRender() {
        var area = document.getElementById("jobArea");
        var empty = document.getElementById("emptyTip");
        area.innerHTML = "";

        var kw = document.getElementById("searchInput").value.trim().toLowerCase();
        var filtered = state.jobs;
        if (kw) {
            filtered = state.jobs.filter(function(j) {
                return (j.title||"").toLowerCase().indexOf(kw)>=0 || (j.moduleCode||"").toLowerCase().indexOf(kw)>=0 || (j.requiredSkills||"").toLowerCase().indexOf(kw)>=0;
            });
        }
        if (!filtered.length) { empty.style.display = "block"; return; }
        empty.style.display = "none";

        var groups = {};
        filtered.forEach(function(j) {
            var m = j.moduleCode || "Other";
            if (!groups[m]) groups[m] = [];
            groups[m].push(j);
        });

        Object.keys(groups).sort().forEach(function(mod) {
            var jobs = groups[mod];
            var cid = "grp_" + mod.replace(/[^A-Za-z0-9]/g,"_");
            if (state.collapsed[cid] === undefined) state.collapsed[cid] = false;
            var isCollapsed = state.collapsed[cid];

            var group = document.createElement("div");
            group.className = "job-group" + (isCollapsed ? " collapsed" : "");
            group.innerHTML =
                '<div class="group-head" onclick="toggleGroup(\'' + cid + '\')">' +
                '<div><h3>' + esc(mod) + ' <span class="group-meta">(' + jobs.length + ' position' + (jobs.length>1?'s':'') + ')</span></h3></div>' +
                '<span class="group-arrow">&#9660;</span></div>' +
                '<div class="group-body" id="' + cid + '"></div>';
            area.appendChild(group);

            var body = document.getElementById(cid);
            jobs.forEach(function(j) {
                var card = document.createElement("div");
                card.className = "job-card";
                card.innerHTML =
                    '<label class="job-check"><input type="checkbox" class="job-checkbox" data-job-id="' + esc(j.jobId) + '" onchange="updateSelection()"/></label>' +
                    '<div class="job-main"><h4>' + esc(j.title) + '</h4>' +
                    '<div class="job-info">' +
                    '<span>ID: ' + esc(j.jobId) + '</span>' +
                    '<span>Module: ' + esc(j.moduleCode) + '</span>' +
                    '<span>Skills: ' + esc(j.requiredSkills||"-") + '</span>' +
                    '<span>Slots: ' + j.slots + '</span>' +
                    (j.hoursPerWeek ? '<span>' + j.hoursPerWeek + 'h/wk</span>' : '') +
                    (j.applicationDeadline ? '<span>Deadline: ' + j.applicationDeadline + '</span>' : '') +
                    '</div></div>' +
                    '<div class="job-actions"><a class="signin-btn ghost" href="job-detail.jsp?id=' + esc(j.jobId) + '">Details</a></div>';
                body.appendChild(card);
            });
        });
        updateSelection();
    }

    function toggleGroup(cid) {
        state.collapsed[cid] = !state.collapsed[cid];
        var el = document.getElementById(cid);
        if (el) el.parentElement.classList.toggle("collapsed");
    }

    function updateSelection() {
        var cbs = document.querySelectorAll(".job-checkbox:checked");
        var bar = document.getElementById("selectionBar");
        if (cbs.length === 0) { bar.style.display = "none"; }
        else {
            bar.style.display = "flex";
            document.getElementById("selCount").textContent = cbs.length + (cbs.length===1?" job selected":" jobs selected");
        }
    }

    document.getElementById("batchApplyBtn").addEventListener("click", function() {
        var ids = [];
        document.querySelectorAll(".job-checkbox:checked").forEach(function(cb){ids.push(cb.getAttribute("data-job-id"));});
        if (!ids.length) { showToast("Please select at least one job"); return; }
        window.location.href = "apply.jsp?jobIds=" + ids.join(",");
    });

    function esc(s) { return String(s||"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;"); }
    function showToast(m) { var t=document.getElementById("toast"); t.textContent=m; t.classList.add("show"); setTimeout(function(){t.classList.remove("show");},2200); }

    async function api(url) {
        var r = await fetch(url, {headers:{"Content-Type":"application/json"}});
        var t = await r.text();
        var b = {};
        try { b = t ? JSON.parse(t) : {}; } catch(_) { b = {error: t || ("HTTP "+r.status)}; }
        if (!r.ok) throw new Error(b.error || ("HTTP "+r.status));
        return b;
    }

    document.getElementById("searchInput").addEventListener("keydown", function(e) { if (e.key === "Enter") loadJobs(); });

    <% if (isLoggedIn) { %>
    document.getElementById("signinToggle").style.display = "none";
    document.getElementById("loggedInBar").style.display = "inline";
    document.getElementById("loggedInRole").textContent = "<%= role %>";
    <% } %>
    loadJobs();
</script>
</body>
</html>

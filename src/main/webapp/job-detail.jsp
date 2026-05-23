<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Job Detail - TA Recruit</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        :root{--primary:#1575ff;--accent:#00b7a5;--muted:#4c5e7a;--line:#d6e4ff;}
        *{box-sizing:border-box;}
        body{font-family:"SF Pro Text","Segoe UI",sans-serif;background:radial-gradient(circle at 20% 15%,#ffffff 0%,#eef3ff 45%,#d9e8ff 100%);color:#102039;min-height:100vh;margin:0;}
        .shell{width:min(860px,calc(100% - 2rem));margin:2rem auto 3rem;}
        .topbar{display:flex;align-items:center;justify-content:space-between;padding:.6rem 1.2rem;margin-bottom:1rem;border:1px solid var(--line);border-radius:18px;background:rgba(255,255,255,0.78);backdrop-filter:blur(24px);box-shadow:0 24px 50px rgba(16,32,57,0.15);}
        .brand{font-size:1.05rem;font-weight:700;color:#0e3369;}
        .nav{display:flex;gap:1.5rem;align-items:center;}
        .nav a{text-decoration:none;color:var(--muted);font-size:.9rem;font-weight:500;}
        .glass{border:1px solid var(--line);border-radius:18px;background:rgba(255,255,255,0.72);backdrop-filter:blur(24px);box-shadow:0 24px 50px rgba(16,32,57,0.15);padding:1.4rem;margin-bottom:1rem;}
        h1{margin:0 0 .3rem;font-size:1.6rem;color:#10213f;}
        h2{font-size:1rem;color:#12396a;margin:0 0 .5rem;}
        .detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
        .detail-grid .full{grid-column:1/-1;}
        ul{margin:0;padding-left:1.2rem;color:var(--muted);font-size:.9rem;line-height:1.7;}
        .info-row{display:flex;gap:.5rem;margin-bottom:.35rem;font-size:.9rem;color:var(--muted);flex-wrap:wrap;}
        .info-row strong{color:#102039;min-width:80px;}
        .btn{border:1px solid #c2d6ff;border-radius:10px;background:linear-gradient(135deg,#1575ff,#0094ff 55%,#00b7a5);color:#fff;padding:.6rem 1.2rem;font-size:.9rem;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block;}
        .btn.ghost{background:rgba(255,255,255,0.72);color:#0f2d58;}
        .actions{display:flex;gap:.8rem;margin-top:1rem;}
        .toast{position:fixed;left:50%;transform:translate(-50%,-140%);top:18px;padding:.6rem 1rem;border-radius:9999px;background:#10B981;color:#fff;font-size:.85rem;box-shadow:0 10px 22px rgba(16,185,129,0.28);opacity:0;pointer-events:none;transition:transform .3s ease,opacity .3s ease;z-index:99;}
        .toast.show{transform:translate(-50%,0);opacity:1;}
        #loading{padding:3rem;text-align:center;color:var(--muted);font-size:1rem;}
        #error{display:none;padding:3rem;text-align:center;color:#EF4444;}
        @media(max-width:720px){.detail-grid{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<div id="toast" class="toast"></div>

<div class="shell">
    <header class="topbar">
        <div class="brand">TA Recruitment</div>
        <nav class="nav">
            <a href="index.jsp">Home</a>
            <a href="index.jsp">Job List</a>
        </nav>
    </header>

    <div id="loading">Loading job details...</div>
    <div id="error"></div>

    <div id="detail" style="display:none;">
        <section class="glass">
            <h1 id="jobTitle"></h1>
            <p style="color:var(--muted);margin:0;font-size:.9rem;" id="jobSubtitle"></p>
        </section>

        <section class="detail-grid">
            <div class="glass">
                <h2>Basic Info</h2>
                <div class="info-row"><strong>Job ID</strong> <span id="jobId"></span></div>
                <div class="info-row"><strong>Module</strong> <span id="moduleCode"></span></div>
                <div class="info-row"><strong>Status</strong> <span id="status"></span></div>
                <div class="info-row"><strong>Slots</strong> <span id="slots"></span></div>
                <div class="info-row" id="hoursRow"><strong>Hours/wk</strong> <span id="hoursPerWeek"></span></div>
                <div class="info-row" id="stipendRow"><strong>Stipend</strong> <span id="stipend"></span></div>
                <div class="info-row" id="deadlineRow"><strong>Deadline</strong> <span id="deadline"></span></div>
            </div>
            <div class="glass">
                <h2>Required Skills</h2>
                <ul id="skillsList"></ul>
            </div>
            <div class="glass full">
                <h2>Responsibilities</h2>
                <ul>
                    <li>Support module learning activities and lab sessions</li>
                    <li>Assist in grading assignments and providing feedback</li>
                    <li>Hold weekly office hours for student consultation</li>
                    <li>Coordinate with the module owner on course workflow</li>
                </ul>
            </div>
        </section>

        <div class="actions">
            <a id="applyBtn" class="btn" href="#">Apply Now</a>
            <a class="btn ghost" href="javascript:history.back()">Back</a>
        </div>
    </div>
</div>

<script>
    var jobId = new URLSearchParams(window.location.search).get("id") || new URLSearchParams(window.location.search).get("jobId") || "";

    function esc(s) { return String(s||"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;"); }
    function showToast(m) { var t=document.getElementById("toast"); t.textContent=m; t.classList.add("show"); setTimeout(function(){t.classList.remove("show");},2200); }

    async function loadJob() {
        if (!jobId) { document.getElementById("loading").textContent = "No job ID specified."; return; }
        try {
            var data = await api("/jobs?status=&page=1&size=500");
            var jobs = data.items || [];
            var job = jobs.find(function(j) { return j.jobId === jobId || (j.jobId||"").toLowerCase() === jobId.toLowerCase(); });
            if (!job) {
                document.getElementById("loading").style.display = "none";
                document.getElementById("error").style.display = "block";
                document.getElementById("error").textContent = "Job not found: " + esc(jobId);
                return;
            }
            document.getElementById("loading").style.display = "none";
            document.getElementById("detail").style.display = "block";
            document.title = job.title + " - Job Detail";

            document.getElementById("jobTitle").textContent = job.title;
            document.getElementById("jobSubtitle").textContent = job.jobId + " | Module: " + (job.moduleCode||"-");
            document.getElementById("jobId").textContent = job.jobId || "-";
            document.getElementById("moduleCode").textContent = job.moduleCode || "-";
            document.getElementById("status").textContent = job.status || "-";
            document.getElementById("slots").textContent = job.slots || "-";
            if (job.hoursPerWeek) { document.getElementById("hoursPerWeek").textContent = job.hoursPerWeek + " h/wk"; }
            else { document.getElementById("hoursRow").style.display = "none"; }
            if (job.monthlyStipend) { document.getElementById("stipend").textContent = "¥" + job.monthlyStipend + "/mo"; }
            else { document.getElementById("stipendRow").style.display = "none"; }
            if (job.applicationDeadline) { document.getElementById("deadline").textContent = job.applicationDeadline; }
            else { document.getElementById("deadlineRow").style.display = "none"; }

            var skills = (job.requiredSkills || "").split(",").map(function(s) { return s.trim(); }).filter(Boolean);
            var list = document.getElementById("skillsList");
            if (skills.length) { skills.forEach(function(s) { var li = document.createElement("li"); li.textContent = s; list.appendChild(li); }); }
            else { list.innerHTML = "<li>No specific skills listed</li>"; }
            document.getElementById("applyBtn").href = "apply.jsp?jobId=" + encodeURIComponent(job.jobId);
        } catch(e) {
            document.getElementById("loading").style.display = "none";
            document.getElementById("error").style.display = "block";
            document.getElementById("error").textContent = "Failed to load job: " + esc(e.message);
        }
    }

    async function api(url) {
        var r = await fetch(url, {headers:{"Content-Type":"application/json"}});
        var t = await r.text();
        var b = {};
        try { b = t ? JSON.parse(t) : {}; } catch(_) { b = {error:t||("HTTP "+r.status)}; }
        if (!r.ok) throw new Error(b.error||("HTTP "+r.status));
        return b;
    }

    loadJob();
</script>
</body>
</html>

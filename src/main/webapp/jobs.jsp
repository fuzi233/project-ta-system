<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String role = (String) session.getAttribute("role");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Jobs - TA Recruitment</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
    <style>
        :root{--primary:#1575ff;--accent:#00b7a5;--muted:#4c5e7a;--line:#d6e4ff;--shadow:0 24px 50px rgba(16,32,57,0.15);}
        *{box-sizing:border-box;}
        body{font-family:"SF Pro Text","Segoe UI",sans-serif;background:radial-gradient(circle at 20% 15%,#ffffff 0%,#eef3ff 45%,#d9e8ff 100%);color:#102039;min-height:100vh;margin:0;}
        .shell{width:min(1080px,calc(100% - 2rem));margin:2rem auto 3rem;}
        .topbar{display:flex;align-items:center;justify-content:space-between;padding:.6rem 1.2rem;margin-bottom:1rem;border:1px solid var(--line);border-radius:18px;background:rgba(255,255,255,0.78);backdrop-filter:blur(24px);box-shadow:var(--shadow);}
        .brand{font-size:1.05rem;font-weight:700;color:#0e3369;}
        .nav{display:flex;gap:1.5rem;align-items:center;}
        .nav a{text-decoration:none;color:var(--muted);font-size:.9rem;font-weight:500;}
        .nav a.active{color:#1575ff;font-weight:700;}
        .signin-btn{border:1px solid #c2d6ff;border-radius:10px;background:linear-gradient(135deg,#1575ff,#0094ff 55%,#00b7a5);color:#fff;padding:.5rem 1rem;font-size:.88rem;font-weight:600;cursor:pointer;transition:transform 120ms ease;text-decoration:none;display:inline-block;}
        .signin-btn:hover{transform:translateY(-1px);}
        .signin-btn.ghost{background:rgba(255,255,255,0.72);color:#0f2d58;border:1px solid #c2d6ff;}
        .page-title{margin:0 0 1.2rem;font-size:2rem;font-weight:800;color:#10213f;}
        .toolbar{display:flex;gap:.6rem;margin-bottom:1rem;flex-wrap:wrap;}
        .toolbar input,.toolbar select{border:1px solid #c2d6ff;border-radius:10px;padding:.6rem .8rem;font-size:.9rem;background:#fff;color:#16315b;}
        .toolbar input{flex:1;min-width:200px;}
        .selection-bar{display:flex;align-items:center;justify-content:space-between;gap:1rem;padding:.8rem 1.2rem;margin-bottom:1rem;border:1px solid #d6e4ff;border-radius:14px;background:rgba(255,255,255,0.88);backdrop-filter:blur(12px);}
        .sel-count{font-size:.92rem;font-weight:700;color:#0e3369;}

        .job-group{margin-bottom:1.2rem;}
        .group-head{display:flex;align-items:center;justify-content:space-between;gap:1rem;padding:.7rem 1rem;border-radius:14px;border:1px solid #d6e4ff;background:rgba(234,243,255,0.85);cursor:pointer;user-select:none;}
        .group-head:hover{background:rgba(220,235,255,0.9);}
        .group-head h3{margin:0;font-size:1rem;color:#12396a;}
        .group-meta{font-size:.82rem;color:var(--muted);}
        .group-arrow{transition:transform 200ms ease;font-size:.85rem;color:var(--muted);}
        .job-group.collapsed .group-arrow{transform:rotate(-90deg);}
        .group-body{display:flex;flex-direction:column;gap:.6rem;margin-top:.5rem;padding-left:.3rem;}
        .job-group.collapsed .group-body{display:none;}

        .job-card{display:flex;align-items:center;gap:1rem;border:1px solid #d6e4ff;border-radius:12px;padding:1rem;background:rgba(255,255,255,0.72);backdrop-filter:blur(12px);box-shadow:0 4px 12px rgba(15,23,42,0.03);}
        .job-card:hover{border-color:#b0cbff;}
        .job-check{display:flex;align-items:center;flex-shrink:0;cursor:pointer;}
        .job-check input{width:18px;height:18px;accent-color:#1575ff;cursor:pointer;}
        .job-main{flex:1;}
        .job-main h4{margin:0 0 .3rem;font-size:1.05rem;font-weight:700;color:#1e293b;}
        .job-info{display:flex;gap:1.2rem;flex-wrap:wrap;font-size:.82rem;color:var(--muted);}
        .job-info span{white-space:nowrap;}
        .job-actions{display:flex;gap:.5rem;flex-shrink:0;}
        .empty-tip{display:none;text-align:center;padding:2rem;color:var(--muted);font-size:1rem;}
        @media(max-width:720px){.page-title{font-size:1.5rem;}.job-card{flex-direction:column;align-items:flex-start;}.toolbar{flex-direction:column;}.toolbar input{min-width:auto;}}
    </style>
</head>
<body>
<div class="shell">
    <header class="topbar">
        <div class="brand">TA Recruitment</div>
        <nav class="nav">
            <a href="index.jsp">Home</a>
            <a href="jobs.jsp" class="active">Job List</a>
            <a href="applications.jsp">My Applications</a>
            <a href="profile.jsp">Profile</a>
        </nav>
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
    var state = { jobs: [], collapsed: {} };

    async function loadJobs() {
        var q = document.getElementById("searchInput").value.trim();
        var st = document.getElementById("statusFilter").value;
        var data = await api("/jobs?status=" + (st||"OPEN") + "&page=1&size=200&q=" + encodeURIComponent(q));
        state.jobs = data.items || [];
        render();
    }

    function render() {
        var area = document.getElementById("jobArea");
        var empty = document.getElementById("emptyTip");
        area.innerHTML = "";

        var kw = document.getElementById("searchInput").value.trim().toLowerCase();
        var filtered = state.jobs;
        if (kw) filtered = state.jobs.filter(function(j){return (j.title||"").toLowerCase().indexOf(kw)>=0||(j.moduleCode||"").toLowerCase().indexOf(kw)>=0||(j.requiredSkills||"").toLowerCase().indexOf(kw)>=0;});
        if (!filtered.length) { empty.style.display = "block"; return; }
        empty.style.display = "none";

        var groups = {};
        filtered.forEach(function(j){var m=j.moduleCode||"Other";if(!groups[m])groups[m]=[];groups[m].push(j);});

        Object.keys(groups).sort().forEach(function(mod){
            var jobs = groups[mod];
            var cid = "grp_"+mod.replace(/[^A-Za-z0-9]/g,"_");
            if (state.collapsed[cid]===undefined) state.collapsed[cid]=false;
            var isCollapsed = state.collapsed[cid];

            var g = document.createElement("div");
            g.className = "job-group" + (isCollapsed?" collapsed":"");
            g.innerHTML = '<div class="group-head" onclick="toggleGroup(\''+cid+'\')"><div><h3>'+esc(mod)+' <span class="group-meta">('+jobs.length+' position'+(jobs.length>1?'s':'')+')</span></h3></div><span class="group-arrow">&#9660;</span></div><div class="group-body" id="'+cid+'"></div>';
            area.appendChild(g);

            var body = document.getElementById(cid);
            jobs.forEach(function(j){
                var card = document.createElement("div");
                card.className="job-card";
                card.innerHTML = '<label class="job-check"><input type="checkbox" class="job-checkbox" data-job-id="'+esc(j.jobId)+'" onchange="updateSelection()"/></label><div class="job-main"><h4>'+esc(j.title)+'</h4><div class="job-info"><span>ID: '+esc(j.jobId)+'</span><span>Module: '+esc(j.moduleCode)+'</span><span>Skills: '+esc(j.requiredSkills||"-")+'</span><span>Slots: '+j.slots+'</span>'+(j.hoursPerWeek?'<span>'+j.hoursPerWeek+'h/wk</span>':'')+(j.applicationDeadline?'<span>Deadline: '+j.applicationDeadline+'</span>':'')+'</div></div><div class="job-actions"><a class="signin-btn ghost" href="job-detail.jsp?id='+esc(j.jobId)+'">Details</a></div>';
                body.appendChild(card);
            });
        });
        updateSelection();
    }

    function toggleGroup(cid){state.collapsed[cid]=!state.collapsed[cid];var el=document.getElementById(cid);if(el)el.parentElement.classList.toggle("collapsed");}

    function updateSelection(){
        var cbs=document.querySelectorAll(".job-checkbox:checked");
        var bar=document.getElementById("selectionBar");
        if(cbs.length===0){bar.style.display="none";}
        else{bar.style.display="flex";document.getElementById("selCount").textContent=cbs.length+(cbs.length===1?" job selected":" jobs selected");}
    }

    document.getElementById("batchApplyBtn").addEventListener("click",function(){
        var ids=[];document.querySelectorAll(".job-checkbox:checked").forEach(function(cb){ids.push(cb.getAttribute("data-job-id"));});
        if(!ids.length){alert("Please select at least one job");return;}
        window.location.href="apply.jsp?jobIds="+ids.join(",");
    });

    function esc(s){return String(s||"").replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;");}
    async function api(u){var r=await fetch(u,{headers:{"Content-Type":"application/json"}});var t=await r.text();var b={};try{b=t?JSON.parse(t):{};}catch(_){b={error:t||("HTTP "+r.status)};}if(!r.ok)throw new Error(b.error||("HTTP "+r.status));return b;}

    document.getElementById("searchInput").addEventListener("keydown",function(e){if(e.key==="Enter")loadJobs();});
    loadJobs();
</script>
</body>
</html>

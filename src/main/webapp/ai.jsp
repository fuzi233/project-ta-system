<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruit - AI Insights</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
</head>
<body>
<div class="bg-orb orb-a"></div>
<div class="bg-orb orb-b"></div>
<main class="shell narrow">
    <a class="link" href="index.jsp">&larr; Exit</a>

    <section class="glass card">
        <h1>AI Insights Lab</h1>
        <p class="subtitle">
            This page demonstrates LLM-assisted recommendations. If no API key is configured,
            the system automatically uses deterministic heuristic fallback.
        </p>
    </section>

    <section class="glass card">
        <h2>1) Match Score</h2>
        <form id="ai-match-form" class="inline-form">
            <input type="text" name="applicantId" placeholder="applicantId" required/>
            <input type="text" name="jobId" placeholder="jobId" required/>
            <button class="btn" type="submit">Run Match</button>
        </form>
        <pre id="ai-match-output" class="panel"></pre>
    </section>

    <section class="glass card">
        <h2>2) Missing Skills + Coaching</h2>
        <form id="ai-missing-form" class="inline-form">
            <input type="text" name="applicantId" placeholder="applicantId" required/>
            <input type="text" name="jobId" placeholder="jobId" required/>
            <button class="btn" type="submit">Analyze Gaps</button>
        </form>
        <pre id="ai-missing-output" class="panel"></pre>
    </section>

    <section class="glass card">
        <h2>3) Workload-aware Shortlist</h2>
        <form id="ai-workload-form" class="inline-form">
            <input type="text" name="jobId" placeholder="jobId" required/>
            <input type="number" name="limit" min="1" max="20" value="5"/>
            <button class="btn" type="submit">Generate Shortlist</button>
        </form>
        <pre id="ai-workload-output" class="panel"></pre>
    </section>
</main>
<script src="assets/js/app.js"></script>
</body>
</html>

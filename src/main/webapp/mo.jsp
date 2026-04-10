<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_MO.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruit - MO</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
</head>
<body>
<main class="shell narrow">
    <a class="link" href="index.jsp">← Home</a>
    
    <!-- Job Posting Section -->
    <section class="glass card">
        <h1>Post New Job</h1>
        <form id="mo-job-form" class="stack-form">
            <input type="text" name="jobId" placeholder="jobId" required/>
            <input type="text" name="title" placeholder="title" required/>
            <input type="text" name="moduleCode" placeholder="moduleCode" required/>
            <input type="text" name="requiredSkills" placeholder="requiredSkills" required/>
            <input type="number" name="slots" placeholder="slots" min="1" required/>
            <button class="btn" type="submit">Create Job</button>
        </form>
        <pre id="mo-output" class="panel"></pre>
    </section>

    <!-- Candidate Screening Section -->
    <section class="glass card">
        <h1>Screen Candidates</h1>
        <form id="candidate-filter-form" class="stack-form">
            <input type="text" name="jobId" placeholder="jobId" required/>
            <select name="status">
                <option value="">All Status</option>
                <option value="SUBMITTED">SUBMITTED</option>
                <option value="INTERVIEWED">INTERVIEWED</option>
                <option value="ACCEPTED">ACCEPTED</option>
                <option value="REJECTED">REJECTED</option>
            </select>
            <input type="number" name="page" placeholder="page" min="1" value="1"/>
            <input type="number" name="size" placeholder="size" min="1" value="20"/>
            <button class="btn" type="submit">Load Candidates</button>
        </form>
        <div id="candidates-container" class="panel">
            <pre id="candidates-output"></pre>
        </div>
    </section>

    <!-- Status Update Section -->
    <section class="glass card">
        <h1>Update Application Status</h1>
        <form id="status-update-form" class="stack-form">
            <input type="text" name="applicationId" placeholder="applicationId" required/>
            <select name="status" required>
                <option value="">--Select Status--</option>
                <option value="SUBMITTED">SUBMITTED</option>
                <option value="INTERVIEWED">INTERVIEWED</option>
                <option value="ACCEPTED">ACCEPTED</option>
                <option value="REJECTED">REJECTED</option>
            </select>
            <button class="btn" type="submit">Update Status</button>
        </form>
        <pre id="status-output" class="panel"></pre>
    </section>
</main>
<script src="assets/js/app.js"></script>
</body>
</html>

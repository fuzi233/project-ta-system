<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruit - Jobs</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
</head>
<body>
<main class="shell narrow">
    <a class="link" href="index.jsp">← Home</a>
    <section class="glass card">
        <h1>Open Jobs</h1>
        <form id="job-filter" class="inline-form">
            <input type="text" id="q" placeholder="Search module/title/skills"/>
            <button type="submit" class="btn">Search</button>
        </form>
        <pre id="jobs-output" class="panel">Loading...</pre>
    </section>

    <section class="glass card">
        <h2>Apply</h2>
        <form id="apply-form" class="stack-form">
            <input type="text" name="applicationId" placeholder="applicationId (optional)"/>
            <input type="text" name="applicantId" placeholder="applicantId" required/>
            <input type="text" name="jobId" placeholder="jobId" required/>
            <button class="btn" type="submit">Submit Application</button>
        </form>
        <pre id="apply-output" class="panel"></pre>
    </section>

    <section class="glass card">
        <h2>Check Status</h2>
        <form id="status-form" class="inline-form">
            <input type="text" name="applicantId" placeholder="applicantId" required/>
            <button class="btn" type="submit">Query</button>
        </form>
        <pre id="status-output" class="panel"></pre>
    </section>
</main>
<script src="assets/js/app.js"></script>
</body>
</html>

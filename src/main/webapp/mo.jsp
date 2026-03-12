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
    <section class="glass card">
        <h1>MO Job Posting</h1>
        <form id="mo-job-form" class="stack-form">
            <input type="text" name="jobId" placeholder="jobId" required/>
            <input type="text" name="title" placeholder="title" required/>
            <input type="text" name="moduleCode" placeholder="moduleCode" required/>
            <input type="text" name="requiredSkills" placeholder="requiredSkills" required/>
            <input type="number" name="slots" placeholder="slots" min="1" required/>
            <input type="text" name="createdBy" placeholder="createdBy" required/>
            <button class="btn" type="submit">Create Job</button>
        </form>
        <pre id="mo-output" class="panel"></pre>
    </section>
</main>
<script src="assets/js/app.js"></script>
</body>
</html>

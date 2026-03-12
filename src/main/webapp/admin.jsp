<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>TA Recruit - Admin</title>
    <link rel="stylesheet" href="assets/css/style.css"/>
</head>
<body>
<main class="shell narrow">
    <a class="link" href="index.jsp">← Home</a>
    <section class="glass card">
        <h1>Workload Dashboard</h1>
        <form id="admin-form" class="inline-form">
            <input type="number" min="1" id="threshold" placeholder="threshold (default 3)"/>
            <button class="btn" type="submit">Refresh</button>
        </form>
        <pre id="admin-output" class="panel">No data loaded.</pre>
    </section>
</main>
<script src="assets/js/app.js"></script>
</body>
</html>

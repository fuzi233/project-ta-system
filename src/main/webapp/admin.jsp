<%@ page import="cn.ebu6304.tarecruitment.controller.AuthSession" %>
<%
    String role = (String) session.getAttribute(AuthSession.ATTR_ROLE);
    if (role == null || !AuthSession.ROLE_ADMIN.equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
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
        <p class="subtitle">Monitor TA workload, filter by threshold, and identify overloaded applicants.</p>
        <form id="admin-form" class="inline-form">
            <input type="number" min="0" id="threshold" value="3" placeholder="threshold (default 3)"/>
            <label class="checkbox-line">
                <input type="checkbox" id="only-overloaded"/>
                <span>Show only overloaded</span>
            </label>
            <button class="btn" type="submit">Refresh</button>
        </form>
        <p id="admin-hint" class="hint">Loading workload data...</p>

        <div class="stats-grid">
            <article class="glass stat-card">
                <p class="stat-label">Applications</p>
                <p class="stat-value" id="stat-total-applications">-</p>
            </article>
            <article class="glass stat-card">
                <p class="stat-label">Applicants</p>
                <p class="stat-value" id="stat-total-applicants">-</p>
            </article>
            <article class="glass stat-card">
                <p class="stat-label">Overloaded</p>
                <p class="stat-value" id="stat-overloaded">-</p>
            </article>
        </div>

        <div class="table-wrap">
            <table class="admin-table">
                <thead>
                <tr>
                    <th>Applicant</th>
                    <th>Active Workload</th>
                    <th>Total Applications</th>
                    <th>Status Breakdown</th>
                    <th>Warning</th>
                </tr>
                </thead>
                <tbody id="admin-table-body">
                <tr>
                    <td colspan="5" class="empty-note">No data loaded.</td>
                </tr>
                </tbody>
            </table>
        </div>
    </section>
</main>
<script src="assets/js/app.js"></script>
</body>
</html>

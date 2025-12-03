<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="javax.servlet.http.*" %>
<%
HttpSession session1 = request.getSession(false);
if (session1 == null || session1.getAttribute("isAdmin") == null || !(Boolean)session1.getAttribute("isAdmin")) {
    response.sendRedirect("admin_login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Panel - Create Account</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">My Bank - Admin</a>
        <div class="d-flex">
            <a href="BankServlet?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="container py-4">
    <h3>Create New Bank Account</h3>
    <div class="card shadow mt-3">
        <div class="card-body">
            <form action="BankServlet" method="post">
                <input type="hidden" name="action" value="createAccount">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Account Number</label>
                        <input type="text" name="accountNo" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Customer Name</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">PIN</label>
                        <input type="password" name="pin" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Initial Balance (Rs.)</label>
                        <input type="number" name="balance" class="form-control" min="0" value="0" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-success">Create Account</button>
            </form>
        </div>
    </div>

    <div class="mt-3 d-flex gap-2">
    <a href="admin_accounts.jsp" class="btn btn-info">View All Accounts</a>
    <a href="index.jsp" class="btn btn-secondary">Go to User Login</a>
</div>

</div>
</body>
</html>

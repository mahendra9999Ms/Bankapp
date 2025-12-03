<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%
HttpSession session1 = request.getSession(false);
if (session1 == null || session1.getAttribute("accountNo") == null) {
    response.sendRedirect("index.jsp");
    return;
}
String name = (String) session1.getAttribute("name");
int balance = (Integer) session1.getAttribute("balance");
String accNo = (String) session1.getAttribute("accountNo");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Bank Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body style="background: linear-gradient(135deg,#0f172a,#1d4ed8); min-height:100vh;">
<nav class="navbar navbar-expand-lg navbar-dark" style="background: rgba(15,23,42,0.9);">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">My Bank</a>
        <div class="d-flex">
            <span class="navbar-text text-light me-3">
                <strong><%= name %></strong> (Acc: <%= accNo %>)
            </span>
            <a href="BankServlet?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="container py-4">
    <div class="row g-4">
        <div class="col-md-4">
            <div class="card text-white shadow" style="background: linear-gradient(135deg,#22c55e,#16a34a);">
                <div class="card-body">
                    <h5 class="card-title">Current Balance</h5>
                    <p class="display-6 mb-0">&#8377; <%= balance %></p>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    Deposit Money
                </div>
                <div class="card-body">
                    <form action="BankServlet" method="post">
                        <input type="hidden" name="action" value="deposit">
                        <div class="mb-2">
                            <label class="form-label">Amount</label>
                            <input type="number" name="amount" class="form-control" min="1" required>
                        </div>
                        <button type="submit" class="btn btn-success w-100">Deposit</button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header bg-danger text-white">
                    Withdraw Money
                </div>
                <div class="card-body">
                    <form action="BankServlet" method="post">
                        <input type="hidden" name="action" value="withdraw">
                        <div class="mb-2">
                            <label class="form-label">Amount</label>
                            <input type="number" name="amount" class="form-control" min="1" required>
                        </div>
                        <button type="submit" class="btn btn-danger w-100">Withdraw</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="mt-4">
        <a href="BankServlet?action=history" class="btn btn-warning">
            View Transaction History
        </a>
    </div>
</div>
</body>
</html>

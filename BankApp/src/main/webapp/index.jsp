<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Bank Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-gradient" style="background: linear-gradient(135deg,#3b82f6,#a855f7); min-height:100vh;">
<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
    <div class="card shadow-lg" style="width: 380px;">
        <div class="card-header text-center text-white" style="background: linear-gradient(135deg,#6366f1,#ec4899);">
            <h3 class="mb-0">My Bank App</h3>
            <small>Secure Login</small>
        </div>
        <div class="card-body">
            <form action="BankServlet" method="post">
                <input type="hidden" name="action" value="login">
                <div class="mb-3">
                    <label class="form-label">Account Number</label>
                    <input type="text" name="accountNo" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">PIN</label>
                    <input type="password" name="pin" class="form-control" required>
                </div>
                <button type="submit" class="btn w-100 text-white" style="background: linear-gradient(135deg,#22c55e,#16a34a);">
                    Login
                </button>
            </form>
        </div>
         <div class="card-footer text-center text-muted">
    <small>&copy; 2025 My Bank</small><br>
    <a href="admin_login.jsp">Admin Login</a>
</div>
    </div>
</div>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-dark d-flex align-items-center" style="min-height:100vh;">
<div class="container d-flex justify-content-center">
    <div class="card shadow-lg" style="width: 380px;">
        <div class="card-header text-white" style="background: linear-gradient(135deg,#f97316,#ea580c);">
            <h4 class="mb-0 text-center">Admin Login</h4>
        </div>
        <div class="card-body">
            <form action="BankServlet" method="post">
                <input type="hidden" name="action" value="adminLogin">
                <div class="mb-3">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Password</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-warning w-100">Login as Admin</button>
            </form>
        </div>
        <div class="card-footer text-center">
            <a href="index.jsp">Back to User Login</a>
        </div>
    </div>
</div>
</body>
</html>

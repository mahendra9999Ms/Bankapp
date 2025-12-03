<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="javax.servlet.http.*,java.sql.*" %>
<%
HttpSession session1 = request.getSession(false);
if (session1 == null || session1.getAttribute("isAdmin") == null || !(Boolean)session1.getAttribute("isAdmin")) {
    response.sendRedirect("admin_login.jsp");
    return;
}

String accNo = request.getParameter("accountNo");
String name = "";
String pin = "";
int balance = 0;
String errorMsg = null;

if (accNo == null || accNo.trim().isEmpty()) {
    errorMsg = "No account number provided.";
} else {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/bankdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
            "root",      // 🔁 your MySQL username
            "root"       // 🔁 your MySQL password
        );

        String sql = "SELECT name, pin, balance FROM accounts WHERE account_no=?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, accNo);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            pin = rs.getString("pin");
            balance = rs.getInt("balance");
        } else {
            errorMsg = "Account not found.";
        }
        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        errorMsg = e.getMessage();
    }
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Account - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="admin.jsp">My Bank - Admin</a>
        <div class="d-flex">
            <a href="BankServlet?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="container py-4">
    <h3>Edit Account</h3>

    <% if (errorMsg != null) { %>
        <div class="alert alert-danger mt-3">
            <%= errorMsg %>
        </div>
        <a href="admin_accounts.jsp" class="btn btn-secondary mt-2">Back</a>
    <% } else { %>

    <div class="card shadow mt-3">
        <div class="card-body">
            <form action="BankServlet" method="post">
                <input type="hidden" name="action" value="updateAccount">
                <div class="mb-3">
                    <label class="form-label">Account Number</label>
                    <input type="text" name="accountNo" class="form-control" value="<%= accNo %>" readonly>
                </div>
                <div class="mb-3">
                    <label class="form-label">Customer Name</label>
                    <input type="text" name="name" class="form-control" value="<%= name %>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">PIN</label>
                    <input type="text" name="pin" class="form-control" value="<%= pin %>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Balance (Rs.)</label>
                    <input type="number" name="balance" class="form-control" value="<%= balance %>" min="0" required>
                </div>
                <button type="submit" class="btn btn-success">Save Changes</button>
                <a href="admin_accounts.jsp" class="btn btn-secondary">Cancel</a>
            </form>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>

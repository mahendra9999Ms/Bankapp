<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="javax.servlet.http.*,java.sql.*,java.util.*" %>
<%
HttpSession session1 = request.getSession(false);
if (session1 == null || session1.getAttribute("isAdmin") == null || !(Boolean)session1.getAttribute("isAdmin")) {
    response.sendRedirect("admin_login.jsp");
    return;
}

List<String[]> accounts = new ArrayList<String[]>();
String errorMsg = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/bankdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
        "root",      // 🔁 your MySQL username
        "root"       // 🔁 your MySQL password
    );

    String sql = "SELECT account_no, name, pin, balance FROM accounts ORDER BY account_no";
    PreparedStatement ps = con.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        String accNo = rs.getString("account_no");
        String name = rs.getString("name");
        String pin = rs.getString("pin");
        String bal = String.valueOf(rs.getInt("balance"));
        accounts.add(new String[]{accNo, name, pin, bal});
    }
    rs.close();
    ps.close();
    con.close();
} catch (Exception e) {
    errorMsg = e.getMessage();
}
%>
<!DOCTYPE html>
<html>
<head>
    <title>All Accounts - Admin</title>
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
    <h3>All Customer Accounts</h3>

    <% if (errorMsg != null) { %>
        <div class="alert alert-danger mt-3">
            Error loading accounts: <%= errorMsg %>
        </div>
    <% } else { %>

        <table class="table table-striped table-bordered mt-3">
        <thead class="table-dark">
            <tr>
                <th>#</th>
                <th>Account No</th>
                <th>Customer Name</th>
                <th>PIN</th>
                <th>Balance (Rs.)</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <% if (accounts.isEmpty()) { %>
            <tr>
                <td colspan="6" class="text-center">No accounts found.</td>
            </tr>
        <% } else {
               int i = 1;
               for (String[] a : accounts) { %>
            <tr>
                <td><%= i++ %></td>
                <td><%= a[0] %></td>
                <td><%= a[1] %></td>
                <td><%= a[2] %></td>
                <td><%= a[3] %></td>
                <td class="d-flex gap-1">
                    <!-- Edit button -->
                    <a href="admin_edit_account.jsp?accountNo=<%= a[0] %>"
                       class="btn btn-sm btn-primary">Edit</a>

                    <!-- Delete button -->
                    <form action="BankServlet" method="post" style="display:inline;"
                          onsubmit="return confirm('Delete account <%= a[0] %>?');">
                        <input type="hidden" name="action" value="deleteAccount">
                        <input type="hidden" name="accountNo" value="<%= a[0] %>">
                        <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                    </form>
                </td>
            </tr>
        <%     }
           } %>
        </tbody>
    </table>

    <% } %>

    <a href="admin.jsp" class="btn btn-primary">Back to Admin Panel</a>
</div>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="javax.servlet.http.*,java.sql.*,java.util.*,java.text.*" %>
<%
HttpSession session1 = request.getSession(false);
if (session1 == null || session1.getAttribute("accountNo") == null) {
    response.sendRedirect("index.jsp");
    return;
}
String accNo = (String) session1.getAttribute("accountNo");
String name = (String) session1.getAttribute("name");

int count = 0;
List<String[]> rows = new ArrayList<String[]>();
String errorMsg = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/bankdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
        "root",      // 🔁 change if your MySQL user is different
        "root"       // 🔁 change to your MySQL password
    );

    String sql = "SELECT type, amount, tx_time FROM transactions WHERE account_no=? ORDER BY tx_time DESC LIMIT 20";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, accNo);
    ResultSet rs = ps.executeQuery();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    while (rs.next()) {
        String type = rs.getString("type");
        String amount = String.valueOf(rs.getInt("amount"));
        String time = sdf.format(rs.getTimestamp("tx_time"));
        rows.add(new String[]{type, amount, time});
        count++;
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
    <title>Transaction History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="home.jsp">My Bank</a>
        <div class="d-flex">
            <span class="navbar-text text-light me-3">
                <strong><%= name %></strong> (Acc: <%= accNo %>)
            </span>
            <a href="BankServlet?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="container py-4">
    <h3>Last Transactions</h3>

    <% if (errorMsg != null) { %>
        <div class="alert alert-danger mt-3">
            Error loading history: <%= errorMsg %>
        </div>
    <% } else { %>

    <table class="table table-striped table-bordered mt-3">
        <thead class="table-dark">
            <tr>
                <th>#</th>
                <th>Type</th>
                <th>Amount (₹)</th>
                <th>Time</th>
            </tr>
        </thead>
        <tbody>
        <% if (rows.isEmpty()) { %>
            <tr>
                <td colspan="4" class="text-center">No transactions yet.</td>
            </tr>
        <% } else {
               int i = 1;
               for (String[] r : rows) { %>
            <tr>
                <td><%= i++ %></td>
                <td><%= r[0] %></td>
                <td><%= r[1] %></td>
                <td><%= r[2] %></td>
            </tr>
        <%     }
           } %>
        </tbody>
    </table>
    <% } %>

    <a href="home.jsp" class="btn btn-primary">Back to Dashboard</a>
</div>
</body>
</html>

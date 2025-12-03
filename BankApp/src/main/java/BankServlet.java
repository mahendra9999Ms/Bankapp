import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class BankServlet extends HttpServlet {

    // simple admin credentials (you can change these)
    private static final String ADMIN_USER = "admin";
    private static final String ADMIN_PASS = "admin123";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("login".equals(action)) {
            handleLogin(request, response);
        } else if ("deposit".equals(action)) {
            handleDeposit(request, response);
        } else if ("withdraw".equals(action)) {
            handleWithdraw(request, response);
        } else if ("adminLogin".equals(action)) {
            handleAdminLogin(request, response);
        } else if ("createAccount".equals(action)) {
            handleCreateAccount(request, response);
        } else if ("deleteAccount".equals(action)) {
            handleDeleteAccount(request, response);
        } else if ("updateAccount".equals(action)) {
            handleUpdateAccount(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect("index.jsp");
        } else if ("history".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("accountNo") == null) {
                response.sendRedirect("index.jsp");
            } else {
                request.getRequestDispatcher("history.jsp").forward(request, response);
            }
        } else if ("admin".equals(action)) {
            response.sendRedirect("admin_login.jsp");
        }
    }

    // --------- Normal user login ----------
    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String accNo = request.getParameter("accountNo");
        String pin = request.getParameter("pin");

        try (Connection con = DBUtil.getConnection()) {

            String sql = "SELECT name, balance FROM accounts WHERE account_no=? AND pin=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, accNo);
            ps.setString(2, pin);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String name = rs.getString("name");
                int balance = rs.getInt("balance");

                HttpSession session = request.getSession();
                session.setAttribute("accountNo", accNo);
                session.setAttribute("name", name);
                session.setAttribute("balance", balance);
                session.setAttribute("isAdmin", false);

                response.sendRedirect("home.jsp");
            } else {
                response.setContentType("text/html");
                PrintWriter out = response.getWriter();
                out.println("Invalid account number or PIN. <a href='index.jsp'>Try again</a>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("Error in login: " + e.getMessage());
        }
    }

    // --------- Deposit ----------
    private void handleDeposit(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountNo") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String accNo = (String) session.getAttribute("accountNo");
        int amount = Integer.parseInt(request.getParameter("amount"));

        try (Connection con = DBUtil.getConnection()) {

            String sql = "UPDATE accounts SET balance = balance + ? WHERE account_no = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, amount);
            ps.setString(2, accNo);
            ps.executeUpdate();

            String txSql = "INSERT INTO transactions (account_no, type, amount) VALUES (?, 'DEPOSIT', ?)";
            PreparedStatement psTx = con.prepareStatement(txSql);
            psTx.setString(1, accNo);
            psTx.setInt(2, amount);
            psTx.executeUpdate();

            String getSql = "SELECT balance FROM accounts WHERE account_no = ?";
            PreparedStatement ps2 = con.prepareStatement(getSql);
            ps2.setString(1, accNo);
            ResultSet rs = ps2.executeQuery();
            if (rs.next()) {
                session.setAttribute("balance", rs.getInt("balance"));
            }

            response.sendRedirect("home.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("Error in deposit: " + e.getMessage());
        }
    }

    // --------- Withdraw ----------
    private void handleWithdraw(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("accountNo") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String accNo = (String) session.getAttribute("accountNo");
        int amount = Integer.parseInt(request.getParameter("amount"));

        try (Connection con = DBUtil.getConnection()) {

            String checkSql = "SELECT balance FROM accounts WHERE account_no = ?";
            PreparedStatement psCheck = con.prepareStatement(checkSql);
            psCheck.setString(1, accNo);
            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                int currentBalance = rs.getInt("balance");
                if (amount > currentBalance) {
                    response.setContentType("text/html");
                    PrintWriter out = response.getWriter();
                    out.println("Insufficient balance. <a href='home.jsp'>Back</a>");
                    return;
                }
            }

            String sql = "UPDATE accounts SET balance = balance - ? WHERE account_no = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, amount);
            ps.setString(2, accNo);
            ps.executeUpdate();

            String txSql = "INSERT INTO transactions (account_no, type, amount) VALUES (?, 'WITHDRAW', ?)";
            PreparedStatement psTx = con.prepareStatement(txSql);
            psTx.setString(1, accNo);
            psTx.setInt(2, amount);
            psTx.executeUpdate();

            String getSql = "SELECT balance FROM accounts WHERE account_no = ?";
            PreparedStatement ps2 = con.prepareStatement(getSql);
            ps2.setString(1, accNo);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) {
                session.setAttribute("balance", rs2.getInt("balance"));
            }

            response.sendRedirect("home.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("Error in withdraw: " + e.getMessage());
        }
    }

    // --------- Admin login ----------
    private void handleAdminLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        if (ADMIN_USER.equals(user) && ADMIN_PASS.equals(pass)) {
            HttpSession session = request.getSession();
            session.setAttribute("isAdmin", true);
            response.sendRedirect("admin.jsp");
        } else {
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("Invalid admin credentials. <a href='admin_login.jsp'>Try again</a>");
        }
    }

    // --------- Create account (admin only) ----------
    private void handleCreateAccount(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            accessDenied(response);
            return;
        }

        String accNo = request.getParameter("accountNo");
        String name = request.getParameter("name");
        String pin = request.getParameter("pin");
        int balance = Integer.parseInt(request.getParameter("balance"));

        try (Connection con = DBUtil.getConnection()) {

            String sql = "INSERT INTO accounts (account_no, name, pin, balance) VALUES (?,?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, accNo);
            ps.setString(2, name);
            ps.setString(3, pin);
            ps.setInt(4, balance);
            ps.executeUpdate();

            response.sendRedirect("admin_accounts.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("Error creating account: " + e.getMessage() + " <a href='admin.jsp'>Back</a>");
        }
    }

    // --------- Delete account (admin only) ----------
    private void handleDeleteAccount(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            accessDenied(response);
            return;
        }

        String accNo = request.getParameter("accountNo");

        try (Connection con = DBUtil.getConnection()) {

            // delete related transactions first (optional but safe)
            String txSql = "DELETE FROM transactions WHERE account_no = ?";
            PreparedStatement psTx = con.prepareStatement(txSql);
            psTx.setString(1, accNo);
            psTx.executeUpdate();

            String sql = "DELETE FROM accounts WHERE account_no = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, accNo);
            ps.executeUpdate();

            response.sendRedirect("admin_accounts.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("Error deleting account: " + e.getMessage() + " <a href='admin_accounts.jsp'>Back</a>");
        }
    }

    // --------- Update account (admin only) ----------
    private void handleUpdateAccount(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            accessDenied(response);
            return;
        }

        String accNo = request.getParameter("accountNo");
        String name = request.getParameter("name");
        String pin = request.getParameter("pin");
        int balance = Integer.parseInt(request.getParameter("balance"));

        try (Connection con = DBUtil.getConnection()) {

            String sql = "UPDATE accounts SET name=?, pin=?, balance=? WHERE account_no=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, pin);
            ps.setInt(3, balance);
            ps.setString(4, accNo);
            ps.executeUpdate();

            response.sendRedirect("admin_accounts.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            PrintWriter out = response.getWriter();
            out.println("Error updating account: " + e.getMessage() + " <a href='admin_accounts.jsp'>Back</a>");
        }
    }

    // --------- Helpers ----------
    private boolean isAdmin(HttpSession session) {
        return session != null && session.getAttribute("isAdmin") != null
                && (Boolean) session.getAttribute("isAdmin");
    }

    private void accessDenied(HttpServletResponse response) throws IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("Access denied. <a href='admin_login.jsp'>Admin Login</a>");
    }
}

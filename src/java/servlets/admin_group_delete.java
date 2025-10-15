package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 *
 * @author ralph
 */
public class admin_group_delete extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        try
        {
            HttpSession session = request.getSession();
            Connection con = db.db_util.get_connection(session);
            String group_id = request.getParameter("b");
            PreparedStatement stmt = con.prepareStatement("DELETE FROM groups WHERE id=?");
            stmt.setString(1, group_id);
            stmt.execute();
            
            stmt = con.prepareStatement("DELETE FROM user_group WHERE `group_id`=?");
            stmt.setString(1, group_id);
            stmt.execute();
            
            stmt = con.prepareStatement("DELETE FROM group_safe WHERE `group_id`=?");
            stmt.setString(1, group_id);
            stmt.execute();
            con.close();
        }
        catch(SQLException e)
        {
            System.out.println("Exception in admin_group_delete servlet=" + e);
        }
        String RedirectURL = "admin_groups.jsp";
        response.sendRedirect(RedirectURL);
        
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}

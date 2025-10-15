package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 *
 * @author ralph
 */
public class admin_user_delete extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        
        String RedirectURL = "admin_users.jsp";
        try
        {
            HttpSession session = request.getSession();
            Connection con = db.db_util.get_connection(session);
            String user_id = request.getParameter("user_id");
            String query = "DELETE FROM users WHERE id=?";
            PreparedStatement stmt = con.prepareStatement(query);  
            stmt.setString(1,user_id);
            stmt.executeUpdate();
            
            //group_ids
            try
            {
                stmt = con.prepareStatement("DELETE FROM user_group WHERE user_id=?");
                stmt.setString(1,user_id);
                stmt.executeUpdate();
            }
            catch(Exception e)
            {
                System.out.println("ERROR Exception in servlet admin_users_delete do group membership:=" + e);
            }
            con.close();
        }
        catch(Exception e)
        {
            System.out.println("Exception in admin_users_delte servlet=" + e);
            RedirectURL = "admin_users.jsp?error=Something went wrong!";
        }
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

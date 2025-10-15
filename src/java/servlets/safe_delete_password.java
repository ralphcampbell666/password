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
public class safe_delete_password extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        HttpSession session = request.getSession();
        boolean nuke = false;
        String password_id = request.getParameter("delete_password_id");
        String safe_id = request.getParameter("safe_id");
        try
        {
            nuke = request.getParameter("password_nuke") != null;
        }
        catch(Exception e)
        {
            nuke = false;
        }
        if(session.getAttribute("authenticated")==null )
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else 
        {
            try 
            {
                Connection con = db.db_util.get_connection(session);
                String password_info[] = db.password.password_info_encrypted(con, password_id, session);   
                if(nuke)
                {
                    PreparedStatement stmt = con.prepareStatement("DELETE FROM passwords WHERE id=?");
                    stmt.setString(1, password_id);
                    stmt.executeUpdate();
                    stmt = con.prepareStatement("DELETE FROM password_history WHERE password_id=?");
                    stmt.setString(1, password_id);
                    stmt.execute();
                }
                else
                {
                    PreparedStatement stmt = con.prepareStatement("DELETE FROM passwords WHERE id=?");
                    stmt.setString(1, password_id);
                    stmt.executeUpdate();
                    //add a history record
                    boolean results = db.password.add_password_history_record(con, session, "Delete", String.valueOf(password_info[0]), password_info[1], password_info[2], password_info[3], password_info[4], password_info[5], password_info[6], password_info[7]);
                }
                con.close();
            }
            catch(IOException | SQLException e)
            {
                System.out.println("Exception in safe_delete_password=" + e);
            } 
        }
        response.sendRedirect("safe.jsp?b=" + safe_id);
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

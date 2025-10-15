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
public class admin_password_restore extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        HttpSession session = request.getSession();
        if(session.getAttribute("authenticated")==null)
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else 
        {
            try 
            {
                String session_user_id = session.getAttribute("user_id").toString();
                Connection con = db.db_util.get_connection(session);          
                String password_history_id = request.getParameter("b");              
                String[] history_password = db.password.get_password_history_by_id_encrypted(con, session, password_history_id);
                
                //String password_history_id = history_password[0];//id                
                String password_history_changed_by_user_id = history_password[1];//changed_by_user_id,
                String password_history_action = history_password[2];//action,
                String password_history_date_changed = history_password[3];//date_changed,
                String password_history_password_id = history_password[4];//password_id,
                String password_history_safe_id = history_password[5];//password_id,     
                String password_history_name = history_password[6];//name,
                String password_history_description = history_password[7];//description,
                String password_history_password = history_password[8];//password,
                String password_history_expires_on = history_password[9];//expires_on,
                String password_history_date_created = history_password[10];//date_created,
                String password_history_creator_user_id = history_password[11];//creator_user_id       
                
                if(password_history_safe_id.equalsIgnoreCase("") || password_history_safe_id == null)
                {
                    password_history_safe_id = "-1";
                }
                PreparedStatement stmt = con.prepareStatement("UPDATE passwords SET safe_id=?,name=?,description=?,password=?,expires_on=?,date_created=?,creator_user_id=? WHERE id=?");
                
                //stmt.setString(1, safe_id);
                stmt.setString(1, password_history_safe_id);
                stmt.setString(2, password_history_name);
                stmt.setString(3, password_history_description);
                stmt.setString(4, password_history_password);
                stmt.setString(5, password_history_expires_on);
                stmt.setString(6, password_history_date_created);
                stmt.setString(7, password_history_creator_user_id);
                stmt.setString(8, password_history_password_id);
                stmt.executeUpdate();
                //add a history record
                boolean results = db.password.add_password_history_record(con, session, "Restore", password_history_password_id, password_history_safe_id, password_history_name, password_history_description, password_history_password, password_history_expires_on, password_history_date_created, password_history_creator_user_id);
                con.close();
            }
            catch(SQLException e)
            {
                System.out.println("Exception in admin_password_restore servlet=" + e);
            } 
        }
        //System.out.println("redirect to=" + "safe.jsp?b=" + safe_id);
        response.sendRedirect("admin_passwords.jsp");
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

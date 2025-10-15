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
import java.text.ParseException;
import java.text.SimpleDateFormat;

/**
 *
 * @author ralph
 */
public class admin_safe_password_edit extends HttpServlet 
{
    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
        //SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
        SimpleDateFormat jquery_datetime_picker_format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");//MM-dd-YYYY hh:mm a
        HttpSession session = request.getSession();
        String safe_id = "-1";
        if(session.getAttribute("authenticated")==null)
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else 
        {
            try 
            {
                String system_salt = session.getAttribute("system_salt").toString();
                String system_key = session.getAttribute("system_key").toString();
                String session_user_id = session.getAttribute("user_id").toString();
                java.util.Date history_expires_date = new java.util.Date();
                java.util.Date history_created_date = new java.util.Date();
                Connection con = db.db_util.get_connection(session);          
                String password_id = request.getParameter("edit_id");              
                String name = request.getParameter("edit_name");
                String description = request.getParameter("edit_description");
                String password = request.getParameter("edit_password");
                try
                {
                    password = support.encryption.encrypt_aes256(password, system_key, system_salt);
                }
                catch(Exception e)
                {
                    password = "";
                }
                //password_expires_
                String expires = request.getParameter("edit_expires");
                expires= expires.replace("T", " ");
                try
                {
                    history_expires_date = jquery_datetime_picker_format.parse(expires);
                    expires = timestamp_format.format(history_expires_date);
                }
                catch(ParseException e)
                {
                    expires = "";
                }
                //password_created_
                String created = request.getParameter("edit_created");
                created= created.replace("T", " ");
                try
                {
                    history_created_date = jquery_datetime_picker_format.parse(created);
                    created = timestamp_format.format(history_created_date);
                }
                catch(ParseException e)
                {
                    created = "";
                }
                String creator_user_id = request.getParameter("edit_creator_user_id"); 
                safe_id = request.getParameter("edit_old_safe_id");
                //safe_id = request.getParameter("edit_safe_id");
                
                PreparedStatement stmt = con.prepareStatement("UPDATE passwords SET name=?,description=?,password=?,expires_on=?,date_created=?,creator_user_id=? WHERE id=?");
                //stmt.setString(1, safe_id);
                stmt.setString(1, name);
                stmt.setString(2, description);
                stmt.setString(3, password);
                stmt.setString(4, expires);
                stmt.setString(5, created);
                stmt.setString(6, creator_user_id);
                stmt.setString(7, password_id);
                stmt.executeUpdate();
                //add a history record
                boolean results = db.password.add_password_history_record(con, session, "Update", password_id, safe_id, name, description, password, expires, created, creator_user_id);
                con.close();
            }
            catch(SQLException e)
            {
                System.out.println("Exception in admin_safe_password_edit=" + e);
            } 
        }
        //System.out.println("redirect to=" + "safe.jsp?b=" + safe_id);
        response.sendRedirect("admin_safe_edit.jsp?b=" + safe_id);
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

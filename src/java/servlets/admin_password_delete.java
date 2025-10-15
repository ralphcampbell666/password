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
//import java.text.SimpleDateFormat;

/**
 *
 * @author ralph
 */
public class admin_password_delete extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        HttpSession session = request.getSession();
        boolean is_admin = false;
        String password_id = request.getParameter("b");
        try
        {
            if(session.getAttribute("is_admin").toString().equalsIgnoreCase("1"))
            {
                is_admin = true;
            }
        }
        catch(Exception e)
        {
            is_admin = false;
        }
        //SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
        //SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
        if(session.getAttribute("authenticated")==null )
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else if(!is_admin)
        {
            String main_url = "safes.jsp";
            response.sendRedirect(main_url);
        }
        else 
        {
            try 
            {
                Connection con = db.db_util.get_connection(session);
                String password_info[] = db.password.password_info_encrypted(con, password_id, session);   
                PreparedStatement stmt = con.prepareStatement("DELETE FROM passwords WHERE id=?");
                stmt.setString(1, password_id);
                stmt.executeUpdate();
                //add a history record
                boolean results = db.password.add_password_history_record(con, session, "Delete", String.valueOf(password_info[0]), password_info[1], password_info[2], password_info[3], password_info[4], password_info[5], password_info[6], password_info[7]);
                con.close();
            }
            catch(IOException | SQLException e)
            {
                System.out.println("Exception in admin_password_delete=" + e);
            } 
        }
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

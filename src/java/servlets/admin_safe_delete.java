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
import java.util.ArrayList;

/**
 *
 * @author ralph
 */
public class admin_safe_delete extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        String query = "";
        String RedirectURL = "admin_safes.jsp";
        try
        {
            PreparedStatement stmt = null;
            HttpSession session = request.getSession();
            Connection con = db.db_util.get_connection(session);
            String safe_id = request.getParameter("safe_id");
            String password_action = "";
            boolean has_password_action = true;
            try
            {
                password_action = request.getParameter("password_action");
                if(password_action == null)
                {
                    has_password_action = false;
                }
            }
            catch(Exception e)
            {
                has_password_action = false;
            }
            if(!has_password_action)
            {
                //get passwords in safe_id
                ArrayList <String[]> all_passwords_in_safe = db.password.all_passwords_from_safe_id(con, safe_id);
                for(String[] password: all_passwords_in_safe)
                {
                    boolean results = db.password.add_password_history_record(con, session, "Update", password[0], "-1", password[2], password[3], password[4], password[5], password[6], password[7]);
                }
                query = "DELETE FROM safes WHERE id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();
                
                query = "DELETE FROM group_safe WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();                
                
                query = "UPDATE passwords SET safe_id='-1' WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();    
            }            
            else if(password_action.equalsIgnoreCase("password_action_orphan"))
            {
                //get passwords in safe_id
                ArrayList <String[]> all_passwords_in_safe = db.password.all_passwords_from_safe_id(con, safe_id);
                for(String[] password: all_passwords_in_safe)
                {
                    boolean results = db.password.add_password_history_record(con, session, "Update", password[0], "-1", password[2], password[3], password[4], password[5], password[6], password[7]);
                }
                query = "DELETE FROM safes WHERE id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();
                
                query = "DELETE FROM group_safe WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();                
                
                query = "UPDATE passwords SET safe_id='-1' WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();   
            }
            else if(password_action.equalsIgnoreCase("password_action_delete"))
            {
                //get passwords in safe_id
                ArrayList <String[]> all_passwords_in_safe = db.password.all_passwords_from_safe_id(con, safe_id);
                for(String[] password: all_passwords_in_safe)
                {
                    boolean results = db.password.add_password_history_record(con, session, "Delete", password[0], password[1], password[2], password[3], password[4], password[5], password[6], password[7]);
                }
                query = "DELETE FROM safes WHERE id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();
                
                query = "DELETE FROM group_safe WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();  
                
                query = "DELETE FROM passwords WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();  
                
            }        
            else if(password_action.equalsIgnoreCase("password_action_move"))
            {
                String move_to_safe = request.getParameter("move_to_safe");
                //get passwords in safe_id
                ArrayList <String[]> all_passwords_in_safe = db.password.all_passwords_from_safe_id(con, safe_id);
                for(String[] password: all_passwords_in_safe)
                {
                    boolean results = db.password.add_password_history_record(con, session, "Move", password[0], move_to_safe, password[2], password[3], password[4], password[5], password[6], password[7]);
                }
                query = "DELETE FROM safes WHERE id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();
                
                query = "DELETE FROM group_safe WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,safe_id);
                stmt.executeUpdate();                
                
                query = "UPDATE passwords SET safe_id=? WHERE safe_id=?";
                stmt = con.prepareStatement(query);  
                stmt.setString(1,move_to_safe);
                stmt.setString(2,safe_id);
                stmt.executeUpdate();  
            } 
            con.close();
        }
        catch(SQLException e)
        {
            System.out.println("Exception in admin_safe_delete servlet=" + e);
            RedirectURL = "admin_safes.jsp?error=Something went wrong!";
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

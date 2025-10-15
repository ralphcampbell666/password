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
public class admin_user_new extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        String RedirectURL = "admin_users.jsp";
        try
        {
            HttpSession session = request.getSession();
            String key = session.getAttribute("system_key").toString();
            String salt = session.getAttribute("system_salt").toString();
            Connection con = db.db_util.get_connection(session);
            //get the next id
            int user_id = db.user.next_user_id(con);
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String is_admin = "0";
            try
            {
                is_admin = request.getParameter("is_admin");
                if(is_admin == null)
                {
                    is_admin = "0";
                }
                else
                {
                    is_admin = "1";
                }
            }
            catch(Exception e)
            {
                is_admin = "0";
            }            
            String safe_creator = "0";
            try
            {
                safe_creator = request.getParameter("safe_creator");
                if(safe_creator == null)
                {
                    safe_creator = "0";
                }
                else
                {
                    safe_creator = "1";
                }
            }
            catch(Exception e)
            {
                safe_creator = "0";
            }
            String first = request.getParameter("first");
            String mi = request.getParameter("mi");
            String last = request.getParameter("last");
            String address_1 = request.getParameter("address_1");
            String address_2 = request.getParameter("address_2");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String zip = request.getParameter("zip");
            String phone_office = request.getParameter("phone_office");
            String phone_mobile = request.getParameter("phone_mobile");
            String email = request.getParameter("email");
            String notes = request.getParameter("notes");
            String encrypted_password = support.encryption.encrypt_aes256(password, key, salt);
            PreparedStatement stmt = con.prepareStatement("INSERT INTO users (id,username,password,first,mi,last,address_1,address_2,city,state,zip,email,phone_office,phone_mobile,notes,is_admin,safe_creator) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");            
            stmt.setInt(1,user_id);
            stmt.setString(2,username);
            stmt.setString(3,encrypted_password);
            stmt.setString(4,first);
            stmt.setString(5,mi);
            stmt.setString(6,last);
            stmt.setString(7,address_1);
            stmt.setString(8,address_2);
            stmt.setString(9,city);
            stmt.setString(10,state);
            stmt.setString(11,zip);
            stmt.setString(12,email);
            stmt.setString(13,phone_office);
            stmt.setString(14,phone_mobile);
            stmt.setString(15,notes);
            stmt.setString(16,is_admin);
            stmt.setString(17,safe_creator);
            stmt.executeUpdate();
            
            //group_ids
            try
            {
                String groups[] = request.getParameterValues("group_ids");
                if(groups != null)
                {
                    stmt = con.prepareStatement("INSERT INTO user_group (user_id,group_id) VALUES (?,?)");
                    for (String group : groups) {
                        stmt.setInt(1,user_id);
                        stmt.setString(2, group);                    
                        stmt.executeUpdate();
                    }    
                }
            }
            catch(Exception e)
            {
                System.out.println("ERROR Exception in servlet admin_users_new do group membership:=" + e);
            }
            con.close();
        }
        catch(Exception e)
        {
            System.out.println("Exception in admin_users_new servlet=" + e);
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

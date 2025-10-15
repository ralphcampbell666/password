package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedHashMap;

/**
 *
 * @author ralph
 */
public class login extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        String context_dir = request.getServletContext().getRealPath("");
        HttpSession session = request.getSession();        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String RedirectURL = "";
        //check user inputs
        if(username == null || password == null)
        {
            RedirectURL = "index.jsp?error=missing_parameter";
        }
        else
        {
            try
            {
                LinkedHashMap config = support.config.get_config(context_dir);
                session.setAttribute("db", config.get("db").toString());
                session.setAttribute("system_key", config.get("system_key").toString());
                session.setAttribute("system_salt", config.get("system_salt").toString());
                session.setAttribute("debug", config.get("debug").toString());
                
                Connection con = db.db_util.get_connection(session);
                String user[] = db.user.validate(con, session, username, password);
                if(user[0] == null)
                {
                    RedirectURL = "index.jsp?error=Login failed";
                }
                else
                {
                    session.setAttribute("username", user[1]);
                    session.setAttribute("user_id", user[0]);
                    
                    session.setAttribute("authenticated", "1");
                    if(user[15].equalsIgnoreCase("1"))
                    {
                        session.setAttribute("is_admin", "1");
                    }
                    else
                    {
                        session.setAttribute("is_admin", "0");
                    }
                    if(user[16].equalsIgnoreCase("1"))
                    {
                        session.setAttribute("safe_creator", "1");
                    }
                    else
                    {
                        session.setAttribute("safe_creator", "0");
                    }
                    RedirectURL = "safes.jsp";
                }
                con.close();
            }
            catch(IOException | SQLException e)
            {
                System.out.println("Exception in login=" + e);
            }            
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

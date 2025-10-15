package ajax;

import java.io.PrintWriter;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

/**
 *
 * @author ralph
 */
public class ajax_password extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss"); 
        //SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
        SimpleDateFormat jquery_datetime_picker_format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");//MM-dd-YYYY hh:mm a
        java.util.Date expire = new java.util.Date();
        java.util.Date created = new java.util.Date();
        
        boolean found_record = false;
        HttpSession session = request.getSession();
        PreparedStatement stmt;
        StringBuilder stringBuilder = new StringBuilder();
        if(session.getAttribute("authenticated")==null)
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else 
        {
            try 
            {
                String search = request.getParameter("search");
                response.setContentType("text/html;charset=UTF-8");
                String key = session.getAttribute("system_key").toString();
                String salt = session.getAttribute("system_salt").toString(); 
                Connection con = db.db_util.get_connection(session);
                ArrayList <String[]> users = db.user.all_users(con);
                String p_word = "";
                String expires_on = "";
                String date_created = "";
                stmt = con.prepareStatement("SELECT  * FROM passwords WHERE id=?");
                stmt.setString(1, search);
                ResultSet rs = stmt.executeQuery();
                
                while(rs.next())
                {
                    stringBuilder.setLength(0);
                    try
                    {
                        p_word = support.encryption.decrypt_aes256(rs.getString("password"), key, salt);
                        if(p_word == null)
                        {
                            p_word = "*Encryption Error*";
                        }
                    }
                    catch(SQLException e)
                    {
                        p_word = "";
                    }
                    try
                    {
                        expires_on = "";
                        expire = timestamp_format.parse(rs.getString("expires_on"));
                        expires_on = jquery_datetime_picker_format.format(expire);
                    }
                    catch(SQLException | ParseException e)
                    {
                        expires_on = "";
                    }
                    try
                    {
                        date_created = "";
                        created = timestamp_format.parse(rs.getString("date_created"));
                        date_created = jquery_datetime_picker_format.format(created);
                    }
                    catch(SQLException | ParseException e)
                    {
                        date_created = "";
                    }
                    found_record = true;
                    stringBuilder.append("{");
                    stringBuilder.append("\"id\": \"").append(rs.getString("id")).append("\",");
                    stringBuilder.append("\"safe_id\": \"").append(rs.getString("safe_id")).append("\",");
                    stringBuilder.append("\"name\": \"").append(rs.getString("name")).append("\",");
                    stringBuilder.append("\"description\": \"").append(rs.getString("description")).append("\",");
                    stringBuilder.append("\"password\":\"").append(p_word).append("\",");
                    stringBuilder.append("\"expires_on\": \"").append(expires_on).append("\",");
                    stringBuilder.append("\"date_created\": \"").append(date_created).append("\",");
                    stringBuilder.append("\"creator_user_id\": \"").append(rs.getString("creator_user_id")).append("\"");
                    stringBuilder.append("}");
                }
                
                if(!found_record)
                {
                    stringBuilder.setLength(0);
                    stringBuilder.append("{");
                    stringBuilder.append("\"id\": \"null\",");
                    stringBuilder.append("\"safe_id\": \"null\",");
                    stringBuilder.append("\"name\": \"null\",");
                    stringBuilder.append("\"description\": \"null\",");
                    stringBuilder.append("\"password\": \"null\",");
                    stringBuilder.append("\"expires_on\": \"null\",");
                    stringBuilder.append("\"date_created\": \"null\",");
                    stringBuilder.append("\"creator_user_id\": \"null\"");
                    stringBuilder.append("}");
                }
                
                con.close();
            }
            catch(IOException | SQLException e)
            {
                System.out.println("Exception in ajax_password=" + e);
                stringBuilder.setLength(0);
                stringBuilder.append("{");
                stringBuilder.append("\"id\": \"null\",");
                stringBuilder.append("\"safe_id\": \"null\",");
                stringBuilder.append("\"name\": \"null\",");
                stringBuilder.append("\"description\": \"null\",");
                stringBuilder.append("\"password\": \"null\",");
                stringBuilder.append("\"expires_on\": \"null\",");
                stringBuilder.append("\"date_created\": \"null\",");
                stringBuilder.append("\"creator_user_id\": \"null\"");
                stringBuilder.append("}");
            }
            PrintWriter out = response.getWriter();
            out.print(stringBuilder.toString());
        }
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

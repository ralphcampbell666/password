package ajax;

import java.io.IOException;
import java.io.PrintWriter;
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
import java.util.ArrayList;

/**
 *
 * @author ralph
 */
public class ajax_password_history extends HttpServlet {

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
        stringBuilder.setLength(0);
        
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
                response.setContentType("text/html;charset=UTF-8");
                String key = session.getAttribute("system_key").toString();
                String salt = session.getAttribute("system_salt").toString(); 
                Connection con = db.db_util.get_connection(session);
                StringBuilder table_stringBuilder = new StringBuilder();
                String password_id = request.getParameter("search");
                String safe_id = request.getParameter("safe_id");
                
                
                String[] my_permissions_for_this_safe = db.safe.my_permissions_for_safe(con, safe_id, session_user_id); //CRUD
                String create = my_permissions_for_this_safe[0];
                String read = my_permissions_for_this_safe[1];
                String update = my_permissions_for_this_safe[2];
                String delete = my_permissions_for_this_safe[3];
                //System.out.println("Create=" + create + " Read=" + read + " Update=" + update + " Delete=" + delete);
                //Permission inheritance 
                if(create.equalsIgnoreCase("1"))
                {
                    read = "1";
                    update = "1";
                    delete = "1";
                }
                if(update.equalsIgnoreCase("1"))
                {
                    read = "1";
                }
                if(delete.equalsIgnoreCase("1"))
                {
                    read = "1";
                }

                ArrayList <String[]> past_passwords = db.password.get_password_history(con, session, password_id);
                for(String[] password: past_passwords)
                {
                    found_record = true;
                    String this_id = password[0];
                    String this_changed_by_user_id = password[1];
                    String this_action = password[2];
                    String this_date_changed = password[3];
                    String this_password_id = password[4];
                    String this_safe_id = password[5];
                    String this_name = password[6];
                    String this_description = password[7];
                    String this_password = password[8];
                    String this_expires_on = password[9];
                    String this_date_created = password[10];
                    String this_creator_user_id = password[11];
                    String this_changed_by_username = password[12];
                    String this_creator_useruser = password[13];
                    String this_safe_name = password[14];

                    this_date_changed = "";
                    try
                    {
                        java.util.Date date = timestamp_format.parse(password[3]);
                        this_date_changed = jquery_datetime_picker_format.format(date);
                    }
                    catch(ParseException e)
                    {
                        this_date_changed = "";
                    }
                    this_expires_on = "";
                    try
                    {
                        java.util.Date date = timestamp_format.parse(password[9]);
                        this_expires_on = jquery_datetime_picker_format.format(date);
                    }
                    catch(ParseException e)
                    {
                        this_expires_on = "";
                    }
                    this_date_created = "";
                    try
                    {
                        java.util.Date date = timestamp_format.parse(password[10]);
                        this_date_created = jquery_datetime_picker_format.format(date);
                    }
                    catch(ParseException e)
                    {
                        this_date_created = "";
                    }

                    table_stringBuilder.append("<tr>");
                    table_stringBuilder.append("<td NOWRAP>");
                    if(update.equalsIgnoreCase("1"))
                    {
                        table_stringBuilder.append("<a title='Replace the existing Password with this version?' href='safe_password_restore?b=").append(this_id).append("' onclick='return confirm('Are you sure you want to Restore this Password?');'><i style='cursor: pointer' class='bi bi-arrow-counterclockwise link-primary'></i></a>");
                    }
                    else
                    {
                        table_stringBuilder.append("<a title='Disabled' href='#');'><i style='cursor: pointer' class='bi bi-arrow-counterclockwise unknown'></i></a>");
                    }
                    
                    table_stringBuilder.append("&nbsp;").append(this_date_changed);
                    table_stringBuilder.append("</td>");
                    table_stringBuilder.append("<td>").append(this_action).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_changed_by_username).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_name).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_description).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_password).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_expires_on).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_date_created).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_safe_name).append("</td>");    
                    table_stringBuilder.append("<td>").append(this_creator_useruser).append("</td>");    
                    table_stringBuilder.append("</tr>");
                }
                
                if(!found_record)
                {
                    stringBuilder.setLength(0);
                    stringBuilder.append("{");
                    stringBuilder.append("\"id\": \"-1\",");
                    stringBuilder.append("\"table_body\": \"None\"");
                    stringBuilder.append("}");
                }
                else
                {
                    stringBuilder.setLength(0);
                    stringBuilder.append("{");
                    stringBuilder.append("\"id\": \"").append(password_id).append("\",");
                    stringBuilder.append("\"table_body\": \"").append(table_stringBuilder.toString()).append("\"");
                    stringBuilder.append("}");
                }               
                
                con.close();
            }
            catch(SQLException e)
            {
                System.out.println("Exception in ajax_password_history=" + e);
                stringBuilder.setLength(0);
                stringBuilder.append("{");
                stringBuilder.append("\"id\": \"-1\",");
                stringBuilder.append("\"table_body\": \"None\"");
                stringBuilder.append("}");
            }
            //System.out.println("json=" + stringBuilder.toString());
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

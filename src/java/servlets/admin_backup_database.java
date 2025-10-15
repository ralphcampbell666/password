package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;

/**
 *
 * @author ralph
 */
public class admin_backup_database extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        int count = 0;
        HttpSession session = request.getSession();
        if(session.getAttribute("authenticated") == null)   
        {
            response.sendRedirect("admin_backup_database.jsp");
        }
        else
        {
            //System.out.println("session is " + session);
            String system_key = session.getAttribute("system_key").toString();
            String system_salt = session.getAttribute("system_salt").toString();
            SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
            java.util.Date now = new java.util.Date();
            String timestamp = timestamp_format.format(now);
            response.setContentType("text/plain");
            response.setHeader("Content-Disposition", "attachment; filename=\"backup_" + timestamp + ".password_backup\"");
            String encrypt = request.getParameter("backup_encrypt");
            encrypt = "encrypted"; //always encrypt
            //System.out.println("backup_encrypt=" + encrypt);
            try 
            {
                Connection con = db.db_util.get_connection(session);
                StringBuilder stringBuilder = new StringBuilder(); 
                stringBuilder.append("{"); //{
                    stringBuilder.append("\"date\" : \"").append(timestamp).append("\","); //"date" : "",
                    stringBuilder.append("\"version\" : \"1.0\","); //"version" : "1.0",
                    stringBuilder.append("\"value_a\" : \"").append(system_key).append("\","); //"value_a" : "",
                    stringBuilder.append("\"value_b\" : \"").append(system_salt).append("\","); //"value_b" : "",
                    stringBuilder.append("\"group_safe\" : {"); //"group_safe": {
                    stringBuilder.append("\"rows\" : ["); //"rows" :[
                        PreparedStatement stmt = con.prepareStatement("SELECT * FROM group_safe");
                        ResultSet rs = stmt.executeQuery();
                        count = 0;
                        while(rs.next())
                        {   
                            if(count > 0)
                            {
                                stringBuilder.append(",{"); //,{
                            }
                            else
                            {
                                stringBuilder.append("{"); //{
                            }
                            stringBuilder.append("\"row_number\": \"").append(count).append("\","); 
                            stringBuilder.append("\"group_id\": \"").append(rs.getString("group_id")).append("\",");
                            stringBuilder.append("\"safe_id\": \"").append(rs.getString("safe_id")).append("\",");
                            stringBuilder.append("\"c\": \"").append(rs.getString("c")).append("\",");
                            stringBuilder.append("\"r\": \"").append(rs.getString("r")).append("\",");
                            stringBuilder.append("\"u\": \"").append(rs.getString("u")).append("\",");
                            stringBuilder.append("\"d\": \"").append(rs.getString("d")).append("\"");     
                            stringBuilder.append("}"); //}
                            count++;
                        }
                        stringBuilder.append("]"); //]
                    stringBuilder.append("}"); //}

                    stringBuilder.append(",");

                    stringBuilder.append("\"groups\" : {"); //"group_safe": {
                    stringBuilder.append("\"rows\" : ["); //"rows" :[
                        stmt = con.prepareStatement("SELECT * FROM groups");
                        rs = stmt.executeQuery();
                        count = 0;
                        while(rs.next())
                        {   
                            if(count > 0)
                            {
                                stringBuilder.append(",{"); //,{
                            }
                            else
                            {
                                stringBuilder.append("{"); //{
                            }
                            stringBuilder.append("\"row_number\": \"").append(count).append("\","); 
                            stringBuilder.append("\"id\": \"").append(rs.getString("id")).append("\",");
                            stringBuilder.append("\"name\": \"").append(rs.getString("name")).append("\",");
                            stringBuilder.append("\"description\": \"").append(rs.getString("description")).append("\"");           
                            stringBuilder.append("}"); //}
                            count++;
                        }
                        stringBuilder.append("]"); //]
                    stringBuilder.append("}"); //}

                    stringBuilder.append(",");

                    stringBuilder.append("\"password_history\" : {"); //"group_safe": {
                    stringBuilder.append("\"rows\" : ["); //"rows" :[
                        stmt = con.prepareStatement("SELECT * FROM password_history");
                        rs = stmt.executeQuery();
                        count = 0;
                        while(rs.next())
                        {   
                            if(count > 0)
                            {
                                stringBuilder.append(",{"); //,{
                            }
                            else
                            {
                                stringBuilder.append("{"); //{
                            }
                            stringBuilder.append("\"row_number\": \"").append(count).append("\","); 
                            stringBuilder.append("\"id\": \"").append(rs.getString("id")).append("\",");
                            stringBuilder.append("\"changed_by_user_id\": \"").append(rs.getString("changed_by_user_id")).append("\",");
                            stringBuilder.append("\"action\": \"").append(rs.getString("action")).append("\",");
                            stringBuilder.append("\"date_changed\": \"").append(rs.getString("date_changed")).append("\",");
                            stringBuilder.append("\"password_id\": \"").append(rs.getString("password_id")).append("\",");
                            stringBuilder.append("\"safe_id\": \"").append(rs.getString("safe_id")).append("\",");
                            stringBuilder.append("\"name\": \"").append(rs.getString("name")).append("\",");
                            stringBuilder.append("\"description\": \"").append(rs.getString("description")).append("\",");
                            String password = "";
                            if(encrypt.equalsIgnoreCase("unencrypted"))
                            {
                                password = support.encryption.decrypt_aes256(rs.getString("password"), system_key, system_salt);
                            }
                            else
                            {
                                password = rs.getString("password");
                            }
                            stringBuilder.append("\"password\": \"").append(password).append("\",");
                            stringBuilder.append("\"expires_on\": \"").append(rs.getString("expires_on")).append("\",");
                            stringBuilder.append("\"date_created\": \"").append(rs.getString("date_created")).append("\",");
                            stringBuilder.append("\"creator_user_id\": \"").append(rs.getString("creator_user_id")).append("\"");           
                            stringBuilder.append("}"); //}
                            count++;
                        }
                        stringBuilder.append("]"); //]
                    stringBuilder.append("}"); //}

                    stringBuilder.append(",");

                    stringBuilder.append("\"passwords\" : {"); //"passwords": {
                    stringBuilder.append("\"rows\" : ["); //"rows" :[
                        stmt = con.prepareStatement("SELECT * FROM passwords");
                        rs = stmt.executeQuery();
                        count = 0;
                        while(rs.next())
                        {   
                            if(count > 0)
                            {
                                stringBuilder.append(",{"); //,{
                            }
                            else
                            {
                                stringBuilder.append("{"); //{
                            }
                            stringBuilder.append("\"row_number\": \"").append(count).append("\","); 
                            stringBuilder.append("\"id\": \"").append(rs.getString("id")).append("\",");
                            stringBuilder.append("\"safe_id\": \"").append(rs.getString("safe_id")).append("\",");
                            stringBuilder.append("\"name\": \"").append(rs.getString("name")).append("\",");
                            stringBuilder.append("\"description\": \"").append(rs.getString("description")).append("\",");
                            String password = "";
                            if(encrypt.equalsIgnoreCase("unencrypted"))
                            {
                                password = support.encryption.decrypt_aes256(rs.getString("password"), system_key, system_salt);
                            }
                            else
                            {
                                password = rs.getString("password");
                            }
                            stringBuilder.append("\"password\": \"").append(password).append("\",");
                            stringBuilder.append("\"expires_on\": \"").append(rs.getString("expires_on")).append("\",");
                            stringBuilder.append("\"date_created\": \"").append(rs.getString("date_created")).append("\",");
                            stringBuilder.append("\"creator_user_id\": \"").append(rs.getString("creator_user_id")).append("\"");           
                            stringBuilder.append("}"); //}
                            count++;
                        }
                        stringBuilder.append("]"); //]
                    stringBuilder.append("}"); //}

                    stringBuilder.append(",");

                    stringBuilder.append("\"safes\" : {"); //"safes": {
                    stringBuilder.append("\"rows\" : ["); //"rows" :[
                        stmt = con.prepareStatement("SELECT * FROM safes");
                        rs = stmt.executeQuery();
                        count = 0;
                        while(rs.next())
                        {   
                            if(count > 0)
                            {
                                stringBuilder.append(",{"); //,{
                            }
                            else
                            {
                                stringBuilder.append("{"); //{
                            }
                            stringBuilder.append("\"row_number\": \"").append(count).append("\","); 
                            stringBuilder.append("\"id\": \"").append(rs.getString("id")).append("\",");
                            stringBuilder.append("\"owner_id\": \"").append(rs.getString("owner_id")).append("\",");
                            stringBuilder.append("\"name\": \"").append(rs.getString("name")).append("\",");
                            stringBuilder.append("\"description\": \"").append(rs.getString("description")).append("\"");          
                            stringBuilder.append("}"); //}
                            count++;
                        }
                        stringBuilder.append("]"); //]
                    stringBuilder.append("}"); //}

                    stringBuilder.append(",");
                    
                    stringBuilder.append("\"user_group\" : {"); //"user_group": {
                    stringBuilder.append("\"rows\" : ["); //"rows" :[
                        stmt = con.prepareStatement("SELECT * FROM user_group");
                        rs = stmt.executeQuery();
                        count = 0;
                        while(rs.next())
                        {   
                            if(count > 0)
                            {
                                stringBuilder.append(",{"); //,{
                            }
                            else
                            {
                                stringBuilder.append("{"); //{
                            }
                            stringBuilder.append("\"row_number\": \"").append(count).append("\","); 
                            stringBuilder.append("\"user_id\": \"").append(rs.getString("user_id")).append("\",");
                            stringBuilder.append("\"group_id\": \"").append(rs.getString("group_id")).append("\"");        
                            stringBuilder.append("}"); //}
                            count++;
                        }
                        stringBuilder.append("]"); //]
                    stringBuilder.append("}"); //}

                    stringBuilder.append(",");
                    
                    stringBuilder.append("\"users\" : {"); //"users": {
                    stringBuilder.append("\"rows\" : ["); //"rows" :[
                        stmt = con.prepareStatement("SELECT * FROM users");
                        rs = stmt.executeQuery();
                        count = 0;
                        while(rs.next())
                        {   
                            if(count > 0)
                            {
                                stringBuilder.append(",{"); //,{
                            }
                            else
                            {
                                stringBuilder.append("{"); //{
                            }
                            stringBuilder.append("\"row_number\": \"").append(count).append("\","); 
                            stringBuilder.append("\"id\": \"").append(rs.getString("id")).append("\",");
                            stringBuilder.append("\"username\": \"").append(rs.getString("username")).append("\",");
                            String password = "";
                            if(encrypt.equalsIgnoreCase("unencrypted"))
                            {
                                password = support.encryption.decrypt_aes256(rs.getString("password"), system_key, system_salt);
                            }
                            else
                            {
                                password = rs.getString("password");
                            }
                            stringBuilder.append("\"password\": \"").append(password).append("\",");
                            stringBuilder.append("\"first\": \"").append(rs.getString("first")).append("\",");
                            stringBuilder.append("\"mi\": \"").append(rs.getString("mi")).append("\",");
                            stringBuilder.append("\"last\": \"").append(rs.getString("last")).append("\",");
                            stringBuilder.append("\"address_1\": \"").append(rs.getString("address_1")).append("\",");
                            stringBuilder.append("\"address_2\": \"").append(rs.getString("address_2")).append("\",");          
                            stringBuilder.append("\"city\": \"").append(rs.getString("city")).append("\",");           
                            stringBuilder.append("\"state\": \"").append(rs.getString("state")).append("\",");           
                            stringBuilder.append("\"zip\": \"").append(rs.getString("zip")).append("\",");           
                            stringBuilder.append("\"email\": \"").append(rs.getString("email")).append("\",");           
                            stringBuilder.append("\"phone_office\": \"").append(rs.getString("phone_office")).append("\",");           
                            stringBuilder.append("\"phone_mobile\": \"").append(rs.getString("phone_mobile")).append("\",");           
                            stringBuilder.append("\"notes\": \"").append(rs.getString("notes")).append("\",");           
                            stringBuilder.append("\"is_admin\": \"").append(rs.getString("is_admin")).append("\",");           
                            stringBuilder.append("\"safe_creator\": \"").append(rs.getString("safe_creator")).append("\"");           
                            stringBuilder.append("}"); //}
                            count++;
                        }
                        stringBuilder.append("]"); //]
                    stringBuilder.append("}"); //}  
                stringBuilder.append("}");//}
                con.close();

                OutputStream outputStream = response.getOutputStream();
                //String outputResult = "This is Test";
                outputStream.write(stringBuilder.toString().getBytes());
                outputStream.flush();
                outputStream.close();
            } 
            catch (IOException | SQLException e) 
            {
                System.out.println("Exception in admin_backup_database servlet:=" + e);
            }
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

package servlets;


import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 *
 * @author ralph
 */

@MultipartConfig(
  fileSizeThreshold = 1024 * 1024 * 10, // 10 MB
  maxFileSize = 1024 * 1024 * 100,      // 100 MB
  maxRequestSize = 1024 * 1024 * 1000   // 1000 MB
)

public class admin_restore_database extends HttpServlet 
{

    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        HttpSession session = request.getSession();
        String return_value = "";
        String number_of_records = "Unknown";
        int records_restored = 0;
        String name = "";
        String description = "";
        String unencrypted_restore_password = "";
        String encrypted_password = "";
        String expires_on = "";
        String date_created = "";
        String creator_user_id = "";
        
        if(session.getAttribute("authenticated")==null)
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else 
        {
            try
            {
                String system_key = session.getAttribute("system_key").toString();
                String system_salt = session.getAttribute("system_salt").toString();
                Connection con = db.db_util.get_connection(session);
                PreparedStatement stmt = null;
                
                String context_dir = request.getServletContext().getRealPath("");
                File file_location = new File(context_dir + "/WEB-INF/uploaded_restore_files/");

                if (!file_location.exists()) 
                {
                    file_location.mkdir();
                }                
                //String backup_encrypt = request.getParameter("backup_encrypt");  //encrypted   or   unencrypted
                //System.out.println("backup_encrypt=" + backup_encrypt);
                String restore_option = request.getParameter("restore_option"); 
                //System.out.println("restore_option=" + restore_option);  //delete or keep
                
                               
                /* Receive file uploaded to the Servlet from the HTML5 form */
                Part filePart = request.getPart("restore_file");
                String fileName = filePart.getSubmittedFileName();
                for (Part part : request.getParts()) 
                {
                    if(part.getContentType() != null)
                    {
                        //System.out.println("restore filename getContentType=" + part.getContentType());
                        //System.out.println("restore element name=" + part.getName());
                        //System.out.println("restore filename=" + fileName);

                        try
                        {
                            part.write(file_location + "/" + fileName);
                        }
                        catch(Exception e)
                        {
                            System.out.println("Exception writing download file=" + e);
                        }
                        
                        //System.out.println("file_location + \"/\" + fileName=" + file_location + "/" + fileName);
                        JsonReader reader = Json.createReader(new BufferedReader(new FileReader(file_location + "/" + fileName)));  
                        JsonObject backup_data = reader.readObject();
                        //System.out.println("date   : " + backup_data.getString("date"));
                        //System.out.println("version   : " + backup_data.getString("version"));
                        //System.out.println("value_a   : " + backup_data.getString("value_a"));//key
                        //System.out.println("value_b   : " + backup_data.getString("value_b"));//salt
                        String backup_file_key = backup_data.getString("value_a");
                        String backup_file_salt = backup_data.getString("value_b");    
                        //restore just passwords
                        
                        
                        if(restore_option.equalsIgnoreCase("keep"))
                        {
                            number_of_records = "Unknown";
                            records_restored = 0;
                            try
                            {
                                //insert the data from the backup file
                                JsonObject passwords_Object = backup_data.getJsonObject("passwords");
                                number_of_records = "Unknown";
                                records_restored = 0;
                                JsonArray passwords_rows = passwords_Object.getJsonArray("rows");  
                                number_of_records = String.valueOf(passwords_rows.size());
                                stmt = con.prepareStatement("INSERT INTO passwords (id,safe_id,name,description,password,expires_on,date_created,creator_user_id) VALUES (?,?,?,?,?,?,?,?)");
                                for(int a = 0; a < passwords_rows.size(); a++)
                                {
                                    JsonObject this_row = passwords_rows.getJsonObject(a);
                                    int password_id = db.password.next_id(con);
                                    stmt.setInt(1,password_id);
                                    stmt.setString(2,"-1");
                                    name = support.string_utils.check_for_null(this_row.getString("name"));
                                    stmt.setString(3,name);
                                    description = support.string_utils.check_for_null(this_row.getString("description"));
                                    stmt.setString(4,description);
                                    unencrypted_restore_password = support.encryption.decrypt_aes256(this_row.getString("password"), backup_file_key, backup_file_salt);
                                    encrypted_password = support.encryption.encrypt_aes256(unencrypted_restore_password, system_key, system_salt);
                                    stmt.setString(5,encrypted_password);
                                    expires_on = support.string_utils.check_for_null(this_row.getString("expires_on"));
                                    stmt.setString(6,expires_on);
                                    date_created = support.string_utils.check_for_null(this_row.getString("date_created"));
                                    stmt.setString(7,date_created);
                                    creator_user_id = support.string_utils.check_for_null(this_row.getString("creator_user_id"));
                                    stmt.setString(8,creator_user_id);
                                    stmt.execute();
                                    
                                    //create a history record
                                    boolean results = db.password.add_password_history_record(con, session, "Restore", String.valueOf(password_id), "-1", name, description, encrypted_password, expires_on, date_created, creator_user_id);
                                    records_restored++;
                                }
                            }
                            catch(SQLException e)
                            {
                                System.out.println("exception=" + e);
                                return_value = "FAIL,Number of Passwords in backup file=" + number_of_records + "<br> Number of Passwords restored=" + records_restored;
                            }
                            return_value = "SUCCESS,Number of Passwords in backup file=" + number_of_records + "<br> Number of Passwords restored=" + records_restored;
                                                        
                        }
                        else
                        {
                            //group_safe                            
                            //delete all existing data
                            number_of_records = "Unknown";
                            records_restored = 0;
                            try
                            {
                                stmt = con.prepareStatement("DELETE FROM group_safe");
                                stmt.executeUpdate(); 
                                //insert the data from the backup file
                                JsonObject group_safe_Object = backup_data.getJsonObject("group_safe");
                                JsonArray group_safe_rows = group_safe_Object.getJsonArray("rows");   
                                number_of_records = "Unknown";
                                records_restored = 0;
                                number_of_records = String.valueOf(group_safe_rows.size());
                                stmt = con.prepareStatement("INSERT INTO group_safe (group_id,safe_id,c,r,u,d) VALUES (?,?,?,?,?,?)");
                                for(int a = 0; a < group_safe_rows.size(); a++)
                                {
                                    JsonObject this_row = group_safe_rows.getJsonObject(a);
                                    //System.out.println("group_safe this_row row_number   : " + this_row.getString("row_number"));
                                    stmt.setString(1,support.string_utils.check_for_null(this_row.getString("group_id")));
                                    stmt.setString(2,support.string_utils.check_for_null(this_row.getString("safe_id")));
                                    stmt.setString(3,support.string_utils.check_for_null(this_row.getString("c")));
                                    stmt.setString(4,support.string_utils.check_for_null(this_row.getString("r")));
                                    stmt.setString(5,support.string_utils.check_for_null(this_row.getString("u")));
                                    stmt.setString(6,support.string_utils.check_for_null(this_row.getString("d")));
                                    stmt.execute();
                                    records_restored++;
                                }
                            }
                            catch(SQLException e)
                            {
                                System.out.println("admin_restore_database 177 FAILED insert group_safe_row=" + stmt);
                                return_value = "FAIL,Number of Group to Safe relationships in backup file=" + number_of_records + "<br> Number of Group to Safe relationships restored=" + records_restored;
                            }
                            return_value = "SUCCESS,Number of Group to Safe relationships in backup file=" + number_of_records + "&nbsp;&nbsp; Number of Group to Safe relationships restored=" + records_restored;
                            ///////////////////////////////////////////////////////////////////////////////
                            //groups
                            //delete all existing data
                            number_of_records = "Unknown";
                            records_restored = 0;
                            try
                            {
                                stmt = con.prepareStatement("DELETE FROM groups");
                                stmt.executeUpdate();  
                                //insert the data from the backup file
                                JsonObject groups_Object = backup_data.getJsonObject("groups");
                                JsonArray groups_rows = groups_Object.getJsonArray("rows");  
                                number_of_records = "Unknown";
                                records_restored = 0;
                                number_of_records = String.valueOf(groups_rows.size());
                                stmt = con.prepareStatement("INSERT INTO groups (id,name,description) VALUES (?,?,?)");
                                for(int a = 0; a < groups_rows.size(); a++)
                                {
                                    JsonObject this_row = groups_rows.getJsonObject(a);
                                    stmt.setString(1,support.string_utils.check_for_null(this_row.getString("id")));
                                    stmt.setString(2,support.string_utils.check_for_null(this_row.getString("name")));
                                    stmt.setString(3,support.string_utils.check_for_null(this_row.getString("description")));
                                    stmt.execute();
                                    records_restored++;
                                }
                            }
                            catch(SQLException e)
                            {
                                System.out.println("admin_restore_database 211  exception=" + e + " stmt=" + stmt);
                                return_value = return_value + "~EnDoFlInE~FAIL,Number of Groups in backup file=" + number_of_records + "<br> Number of Groups restored=" + records_restored;
                            }
                            return_value = return_value + "~EnDoFlInE~SUCCESS,Number of Groups in backup file=" + number_of_records + "&nbsp;&nbsp; Number of Groups restored=" + records_restored;
                            
                            ///////////////////////////////////////////////////////////////////////////////
                            //password_history
                            //delete all existing data
                            number_of_records = "Unknown";
                            records_restored = 0;
                            try
                            {
                                stmt = con.prepareStatement("DELETE FROM password_history");
                                stmt.executeUpdate();   
                                //insert the data from the backup file
                                JsonObject password_history_Object = backup_data.getJsonObject("password_history");
                                number_of_records = "Unknown";
                                records_restored = 0;
                                JsonArray password_history_rows = password_history_Object.getJsonArray("rows");    
                                number_of_records = String.valueOf(password_history_rows.size());
                                stmt = con.prepareStatement("INSERT INTO password_history (id,changed_by_user_id,action,date_changed,password_id,safe_id,name,description,password,expires_on,date_created,creator_user_id) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)");
                                for(int a = 0; a < password_history_rows.size(); a++)
                                {
                                    JsonObject this_row = password_history_rows.getJsonObject(a);
                                    //System.out.println("password_history this_row row_number   : " + this_row.getString("row_number"));
                                    stmt.setString(1,support.string_utils.check_for_null(this_row.getString("id")));
                                    stmt.setString(2,support.string_utils.check_for_null(this_row.getString("changed_by_user_id")));
                                    stmt.setString(3,support.string_utils.check_for_null(this_row.getString("action")));
                                    stmt.setString(4,support.string_utils.check_for_null(this_row.getString("date_changed")));
                                    stmt.setString(5,support.string_utils.check_for_null(this_row.getString("password_id")));
                                    stmt.setString(6,support.string_utils.check_for_null(this_row.getString("safe_id")));
                                    stmt.setString(7,support.string_utils.check_for_null(this_row.getString("name")));
                                    stmt.setString(8,support.string_utils.check_for_null(this_row.getString("description")));
                                    unencrypted_restore_password = support.encryption.decrypt_aes256(this_row.getString("password"), backup_file_key, backup_file_salt);
                                    stmt.setString(9,support.encryption.encrypt_aes256(unencrypted_restore_password, system_key, system_salt));
                                    stmt.setString(10,support.string_utils.check_for_null(this_row.getString("expires_on")));
                                    stmt.setString(11,support.string_utils.check_for_null(this_row.getString("date_created")));
                                    stmt.setString(12,support.string_utils.check_for_null(this_row.getString("creator_user_id")));
                                    stmt.execute();
                                    records_restored++;
                                }
                            }
                            catch(SQLException e)
                            {
                                System.out.println("admin_restore_database 257 Exception stmt=" + stmt + " e=" + e);
                                return_value = return_value + "~EnDoFlInE~FAIL,Number of Password History records in backup file=" + number_of_records + "<br> Number of Password History records restored=" + records_restored;
                            }
                            return_value = return_value + "~EnDoFlInE~SUCCESS,Number of Password History records in backup file=" + number_of_records + "&nbsp;&nbsp; Number of Password History records restored=" + records_restored;
                            
                            ///////////////////////////////////////////////////////////////////////////////
                            //passwords
                            //delete all existing data
                            try
                            {
                                stmt = con.prepareStatement("DELETE FROM passwords");
                                stmt.executeUpdate();     
                                //insert the data from the backup file
                                JsonObject passwords_Object = backup_data.getJsonObject("passwords");
                                number_of_records = "Unknown";
                                records_restored = 0;
                                JsonArray passwords_rows = passwords_Object.getJsonArray("rows");  
                                number_of_records = String.valueOf(passwords_rows.size());
                                stmt = con.prepareStatement("INSERT INTO passwords (id,safe_id,name,description,password,expires_on,date_created,creator_user_id) VALUES (?,?,?,?,?,?,?,?)");
                                for(int a = 0; a < passwords_rows.size(); a++)
                                {
                                    JsonObject this_row = passwords_rows.getJsonObject(a);
                                    //System.out.println("passwords this_row row_number   : " + this_row.getString("row_number"));
                                    stmt.setString(1,support.string_utils.check_for_null(this_row.getString("id")));
                                    stmt.setString(2,support.string_utils.check_for_null(this_row.getString("safe_id")));
                                    stmt.setString(3,support.string_utils.check_for_null(this_row.getString("name")));
                                    stmt.setString(4,support.string_utils.check_for_null(this_row.getString("description")));
                                    unencrypted_restore_password = support.encryption.decrypt_aes256(this_row.getString("password"), backup_file_key, backup_file_salt);
                                    stmt.setString(5,support.encryption.encrypt_aes256(unencrypted_restore_password, system_key, system_salt));
                                    stmt.setString(6,support.string_utils.check_for_null(this_row.getString("expires_on")));
                                    stmt.setString(7,support.string_utils.check_for_null(this_row.getString("date_created")));
                                    stmt.setString(8,support.string_utils.check_for_null(this_row.getString("creator_user_id")));
                                    stmt.execute();
                                    records_restored++;
                                }
                            }
                            catch(SQLException e)
                            {
                                System.out.println("admin_restore_database 297 Exception stmt=" + stmt + " e=" + e);
                                return_value = return_value + "~EnDoFlInE~FAIL,Number of Password records in backup file=" + number_of_records + "<br> Number of Password records restored=" + records_restored;
                            }
                            return_value = return_value + "~EnDoFlInE~SUCCESS,Number of Password records in backup file=" + number_of_records + "&nbsp;&nbsp; Number of Password records restored=" + records_restored;
                            
                            ///////////////////////////////////////////////////////////////////////////////
                            //safes
                            //delete all existing data
                            try
                            {
                                stmt = con.prepareStatement("DELETE FROM safes");
                                stmt.executeUpdate();  
                                //insert the data from the backup file
                                JsonObject safes_Object = backup_data.getJsonObject("safes");
                                number_of_records = "Unknown";
                                records_restored = 0;
                                JsonArray safes_rows = safes_Object.getJsonArray("rows");  
                                number_of_records = String.valueOf(safes_rows.size());
                                stmt = con.prepareStatement("INSERT INTO safes (id,owner_id,name,description) VALUES (?,?,?,?)");
                                for(int a = 0; a < safes_rows.size(); a++)
                                {
                                    JsonObject this_row = safes_rows.getJsonObject(a);
                                    //System.out.println("safes this_row row_number   : " + this_row.getString("row_number"));
                                    stmt.setString(1,support.string_utils.check_for_null(this_row.getString("id")));
                                    stmt.setString(2,support.string_utils.check_for_null(this_row.getString("owner_id")));
                                    stmt.setString(3,support.string_utils.check_for_null(this_row.getString("name")));
                                    stmt.setString(4,support.string_utils.check_for_null(this_row.getString("description")));
                                    stmt.execute();
                                    records_restored++;
                                }
                            }
                            catch(SQLException e)
                            {
                                System.out.println("admin_restore_database 332 Exception stmt=" + stmt + " e=" + e);
                                return_value = return_value + "~EnDoFlInE~FAIL,Number of Safe records in backup file=" + number_of_records + "<br> Number of Safe records restored=" + records_restored;
                            }
                            return_value = return_value + "~EnDoFlInE~SUCCESS,Number of Safe records in backup file=" + number_of_records + "&nbsp;&nbsp; Number of Safe records restored=" + records_restored;
                            
                            ///////////////////////////////////////////////////////////////////////////////
                            //user_group
                            //delete all existing data
                            try
                            {
                                stmt = con.prepareStatement("DELETE FROM user_group");
                                stmt.executeUpdate();   
                                //insert the data from the backup file
                                JsonObject user_group_Object = backup_data.getJsonObject("user_group");
                                number_of_records = "Unknown";
                                records_restored = 0;
                                JsonArray user_group_rows = user_group_Object.getJsonArray("rows");    
                                number_of_records = String.valueOf(user_group_rows.size());
                                stmt = con.prepareStatement("INSERT INTO user_group (user_id,group_id) VALUES (?,?)");
                                for(int a = 0; a < user_group_rows.size(); a++)
                                {
                                    JsonObject this_row = user_group_rows.getJsonObject(a);
                                    //System.out.println("user_group this_row row_number   : " + this_row.getString("row_number"));
                                    stmt.setString(1,support.string_utils.check_for_null(this_row.getString("user_id")));
                                    stmt.setString(2,support.string_utils.check_for_null(this_row.getString("group_id")));
                                    stmt.execute();
                                    records_restored++;
                                }
                            }
                            catch(SQLException e)
                            {
                                System.out.println("admin_restore_database 365 Exception stmt=" + stmt + " e=" + e);
                                return_value = return_value + "~EnDoFlInE~FAIL,Number of User Group Association records in backup file=" + number_of_records + "<br> Number of User Group Association  records restored=" + records_restored;
                            }
                            return_value = return_value + "~EnDoFlInE~SUCCESS,Number of User Group Association  records in backup file=" + number_of_records + "&nbsp;&nbsp; Number of User Group Association  records restored=" + records_restored;
                            
                            ///////////////////////////////////////////////////////////////////////////////
                            //users
                            //delete all existing data
                            try
                            {
                                stmt = con.prepareStatement("DELETE FROM users");
                                stmt.executeUpdate();                            
                                //insert the data from the backup file
                                JsonObject users_Object = backup_data.getJsonObject("users");
                                number_of_records = "Unknown";
                                records_restored = 0;
                                JsonArray users_rows = users_Object.getJsonArray("rows");    
                                number_of_records = String.valueOf(users_rows.size());
                                stmt = con.prepareStatement("INSERT INTO users (id,username,password,first,mi,last,address_1,address_2,city,state,zip,email,phone_office,phone_mobile,notes,is_admin,safe_creator) " +
                                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
                                for(int a = 0; a < users_rows.size(); a++)
                                {
                                    JsonObject this_row = users_rows.getJsonObject(a);
                                    //System.out.println("users this_row row_number   : " + this_row.getString("row_number"));                                
                                    stmt.setString(1,support.string_utils.check_for_null(this_row.getString("id")));
                                    stmt.setString(2,support.string_utils.check_for_null(this_row.getString("username"))); 
                                    //System.out.println("password from backup file=" + this_row.getString("password"));
                                    unencrypted_restore_password = support.encryption.decrypt_aes256(this_row.getString("password"), backup_file_key, backup_file_salt);
                                    //System.out.println("unencrypted_restore_password   : " + unencrypted_restore_password);   
                                    String new_encrypted_password = support.encryption.encrypt_aes256(unencrypted_restore_password, system_key, system_salt);
                                    stmt.setString(3,new_encrypted_password);
                                    stmt.setString(4,support.string_utils.check_for_null(this_row.getString("first")));
                                    stmt.setString(5,support.string_utils.check_for_null(this_row.getString("mi")));
                                    stmt.setString(6,support.string_utils.check_for_null(this_row.getString("last")));
                                    stmt.setString(7,support.string_utils.check_for_null(this_row.getString("address_1")));
                                    stmt.setString(8,support.string_utils.check_for_null(this_row.getString("address_2")));
                                    stmt.setString(9,support.string_utils.check_for_null(this_row.getString("city")));
                                    stmt.setString(10,support.string_utils.check_for_null(this_row.getString("state")));
                                    stmt.setString(11,support.string_utils.check_for_null(this_row.getString("zip")));
                                    stmt.setString(12,support.string_utils.check_for_null(this_row.getString("email")));
                                    stmt.setString(13,support.string_utils.check_for_null(this_row.getString("phone_office")));
                                    stmt.setString(14,support.string_utils.check_for_null(this_row.getString("phone_mobile")));
                                    stmt.setString(15,support.string_utils.check_for_null(this_row.getString("notes")));
                                    stmt.setString(16,support.string_utils.check_for_null(this_row.getString("is_admin")));
                                    stmt.setString(17,support.string_utils.check_for_null(this_row.getString("safe_creator")));
                                    stmt.execute();
                                    records_restored++;
                                }      
                            }
                            catch(SQLException e)
                            {
                                System.out.println("admin_restore_database 365 Exception stmt=" + stmt + " e=" + e);
                                return_value = return_value + "~EnDoFlInE~FAIL,Number of User records in backup file=" + number_of_records + "<br> Number of User records restored=" + records_restored;
                            }
                            return_value = return_value + "~EnDoFlInE~SUCCESS,Number of User records in backup file=" + number_of_records + "&nbsp;&nbsp; Number of User records restored=" + records_restored;
                                
                        }//end else                  
                    }
                }
                con.close();
                //System.out.println("backup_encrypt=" + request.getParameter("backup_encrypt"));
            }
            catch(Exception e)
            {
                System.out.println("Exception in admin_restore_database=" + e);
                return_value = return_value + "~EnDoFlInE~FAIL,Backup file is corrupt/damaged and can not be restored.";                            
            }
        }
        session.setAttribute("admin_restore_database",return_value );
        response.sendRedirect("admin_restore_database.jsp");
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

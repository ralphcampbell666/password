package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileWriter;
import java.sql.Connection;
import java.util.LinkedHashMap;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
/**
 *
 * @author ralph
 */
public class setup extends HttpServlet 
{
    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        //System.out.println("start setup servlet");        
        String newLine = System.getProperty("line.separator");
        boolean db_good = true;
        String result = "";
        String message = "";
        String url = "";
        LinkedHashMap source_linked_has_map = new LinkedHashMap(); 
        String context_dir = request.getServletContext().getRealPath("");
        File config_file = new File(context_dir + "/WEB-INF/config.properties");
        Connection con = null;
        try
        {
            if (config_file.exists()) 
            {
                try
                {
                    source_linked_has_map = properties_util.read.properties_file(config_file);
                    String config_db = source_linked_has_map.get("db").toString();
                    String config_system_key = source_linked_has_map.get("system_key").toString();
                    String config_system_salt = source_linked_has_map.get("system_salt").toString();
                    String config_debug = source_linked_has_map.get("debug").toString();
                    result = "fail";
                    message = "Password config file exists. To create a new config file, delete the old file and restart the Setup process. Existing file is " + config_file.getAbsolutePath();
                }
                catch(Exception e)
                {
                    result = "fail";
                    message = "Password config file exists. To create a new config file, delete the old file and restart the Setup process. Existing file is " + config_file.getAbsolutePath();
                }
            }
            else
            {
                //get parameters
                String admins_password = request.getParameter("admins_password");
                String system_key = support.generate_password.generatePassword(16);
                //String system_key = "abcdef";
                String system_salt = support.generate_password.generatePassword(10);
                //String system_salt = "1234567";
                String encrypted_admin_password = support.encryption.encrypt_aes256(admins_password, system_key, system_salt);
                String db = request.getParameter("db");   
                
                //does the db dir exist and can write?
                File db_file = new File(db);
                if(db_file.exists() && db_file.canWrite())
                {
                    db_good = true;
                    result = "success";
                }
                else
                {
                    db_good = false;
                    result = "fail";
                    message = message + " Can't read/write to db directory or the db directory does not exist";
                }                    
                //save params to config file
                try
                {
                    FileWriter fw = new FileWriter(config_file);                
                    fw.write("[DataBase]" + newLine);
                    fw.write("db=" + db + "/password.db" + newLine);
                    fw.write(newLine);
                    fw.write("[Security]" + newLine);
                    fw.write("system_key=" + system_key + newLine);                    
                    fw.write("system_salt=" + system_salt + newLine);
                    fw.write(newLine);
                    fw.write("[Debug]" + newLine);
                    fw.write("debug=false" + newLine);
                    fw.close(); 
                }
                catch(IOException e)
                {
                    result = "fail";
                    message = message + "Error writting config.properties file:= " + config_file.getAbsolutePath();
                }
                
                //create the database
                try 
                {
                    
                    // db parameters
                    //create the db file
                    String db_url = "jdbc:sqlite:" + db + "/" + "password.db";
                    // create a connection to the database
                    try
                    {
                        Class.forName("org.sqlite.JDBC"); 
                    }
                    catch(Exception e)
                    {
                        System.out.print("admin_users.jsp Can't find the database driver.  ClassNotFoundException: ");
                        System.out.println(e.getMessage());
                    }
                    con = DriverManager.getConnection(db_url);
                    //var meta = con.getMetaData();
                    //System.out.println("The driver name is " + meta.getDriverName());
                    //System.out.println("A new database has been created.");
                    //create the tables
                    PreparedStatement stmt = con.prepareStatement("CREATE TABLE group_safe (group_id INTEGER,safe_id  INTEGER,c INTEGER,r INTEGER,u INTEGER,d INTEGER)");
                    stmt.execute();
                    
                    stmt = con.prepareStatement("CREATE TABLE groups (id INTEGER PRIMARY KEY ASC,name TEXT,description TEXT)");
                    stmt.execute();
                    
                    stmt = con.prepareStatement("CREATE TABLE password_history (id INTEGER PRIMARY KEY,changed_by_user_id INTEGER,action TEXT(24),date_changed TEXT,password_id INTEGER,safe_id INTEGER DEFAULT(0),name TEXT(256),description TEXT,password TEXT, expires_on TEXT,date_created TEXT,creator_user_id INTEGER)");
                    stmt.execute();
                    
                    stmt = con.prepareStatement("CREATE TABLE passwords (id INTEGER PRIMARY KEY, safe_id INTEGER, name TEXT (256),description TEXT,password TEXT,expires_on TEXT,date_created TEXT, creator_user_id INTEGER)");
                    stmt.execute();
                    
                    stmt = con.prepareStatement("CREATE TABLE safes (id INTEGER PRIMARY KEY ASC,owner_id INTEGER,name TEXT,description TEXT)");
                    stmt.execute();
                    
                    stmt = con.prepareStatement("CREATE TABLE user_group (user_id  INTEGER,group_id INTEGER)");
                    stmt.execute();
                    
                    stmt = con.prepareStatement("CREATE TABLE users (id   INTEGER PRIMARY KEY ASC, username TEXT, password TEXT, first TEXT, mi   TEXT, last TEXT, address_1 TEXT, address_2 TEXT, city TEXT, state TEXT, zip  TEXT, email TEXT, phone_office TEXT, phone_mobile TEXT, notes TEXT, is_admin INTEGER, safe_creator INTEGER)");
                    stmt.execute();
                    
                    //add the admin user 
                    stmt = con.prepareStatement("INSERT INTO users (id,username,password,first,mi,last,address_1,address_2,city,state,zip,email,phone_office,phone_mobile,notes,is_admin,safe_creator) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");            
                    stmt.setInt(1,0);
                    stmt.setString(2,"admin");
                    stmt.setString(3,encrypted_admin_password);
                    stmt.setString(4,"admin");
                    stmt.setString(5,"");
                    stmt.setString(6,"");
                    stmt.setString(7,"");
                    stmt.setString(8,"");
                    stmt.setString(9,"");
                    stmt.setString(10,"");
                    stmt.setString(11,"");
                    stmt.setString(12,"");
                    stmt.setString(13,"");
                    stmt.setString(14,"");
                    stmt.setString(15,"");
                    stmt.setString(16,"1");
                    stmt.setString(17,"1");
                    stmt.executeUpdate();                    
                    con.close();
                } 
                catch (SQLException e) 
                {
                    con.close();
                    System.out.println("Exception setup get_connection=" + e.getMessage());
                    result = "fail";
                    message = message + "Error creating database and tables";
                } 
                
                
                //redirect back to index.jsp
                //dffsd
                
                System.out.println("in config.get_config: Can't find " + config_file.getAbsolutePath());
            }
        }
        catch (Exception exc)
        {
            System.out.println("in config.get_config:" +  exc);
            result = "fail";
            message = message + "Something totallu unexpected happened:=" + exc;
        } 
               
        if(result.equalsIgnoreCase("fail"))
        {
            url = "index.jsp?result=fail&message=" + message;
        }
        else
        {
            url = "index.jsp";
        }
        //System.out.println("url=" + url);
        response.sendRedirect(url);
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

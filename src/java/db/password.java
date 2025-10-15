package db;

import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.GregorianCalendar;

public class password {
    public static int next_id(Connection con) throws IOException, SQLException
    {
        int returnInt = 0;
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT max(password_id) FROM password_history");
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                returnInt = rs.getInt("max(password_id)");     
            }
            returnInt++;
            stmt.close();
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException password.next_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception password.next_id:=" + exc);
	}
        //System.out.println("password.next_id:=" + returnInt);
        return returnInt;
    }
    public static ArrayList <String[]> safe_and_passwords_for_safe_id(Connection con, String safe_id, HttpSession session) throws IOException, SQLException
    {
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        String p_word = "";
        ArrayList <String[]> returnList = new ArrayList();
        PreparedStatement stmt;
        try 
        {
            ArrayList <String[]> users = db.user.all_users(con);   
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT  `safes`.`id` AS safes_id,`safes`.`owner_id` AS safes_owner_id,`safes`.`name` AS safes_name,`safes`.`description` AS safes_description, " +
            "`passwords`.`id` AS passwords_id, `passwords`.`safe_id` AS passwords_safe_id,`passwords`.`name` AS passwords_name,`passwords`.`description` AS passwords_description,`passwords`.`password` AS passwords_password,`passwords`.`expires_on` AS passwords_expires_on,`passwords`.`date_created` AS passwords_date_created,`passwords`.`creator_user_id` as passwords_creator_user_id " +
            "FROM safes INNER JOIN passwords ON safes.id = passwords.safe_id WHERE safes.id=?");
            
            stmt.setString(1, safe_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                String temp[] = new String[13];
                temp[0] = rs.getString("safes_id");
                temp[1] = rs.getString("safes_owner_id");
                temp[2] = rs.getString("safes_name");
                temp[3] = rs.getString("safes_description");   
                temp[4] = rs.getString("passwords_id");   
                temp[5] = rs.getString("passwords_safe_id");   
                temp[6] = rs.getString("passwords_name");   
                temp[7] = rs.getString("passwords_description");   
                try
                {
                    p_word = support.encryption.decrypt_aes256(rs.getString("passwords_password"), key, salt);
                    if(p_word == null)
                    {
                        p_word = "*Encryption Error*";
                    }
                }
                catch(SQLException e)
                {
                    p_word = "";
                }
                temp[8] = p_word;   
                temp[9] = rs.getString("passwords_expires_on");   
                temp[10] = rs.getString("passwords_date_created");                  
                temp[11] = rs.getString("passwords_creator_user_id");   
                temp[12] = "";
                for(String[] user: users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("passwords_creator_user_id")))
                    {
                        temp[12] = user[1];
                    }
                }
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException password.safe_and_passwords_for_safe_id:=" + ex);
        }
        catch(IOException exc) 
        {
            System.out.println("ERROR Exception password.safe_and_passwords_for_safe_id:=" + exc);
	}
        return returnList;
    }   
    public static String password_count_in_safe_id(Connection con, String safe_id) throws IOException, SQLException
    {
        String returnString = "0";
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT count(password) as number_of_passwords FROM passwords WHERE safe_id=?");
            stmt.setString(1, safe_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                returnString = rs.getString("number_of_passwords");                  
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException password.password_count_in_safe_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception password.password_count_in_safe_id:=" + exc);
	}
        return returnString;
    }    
    public static ArrayList <String[]> all_passwords_with_safe_name (Connection con, HttpSession session)
    {
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        String p_word = "";
        ArrayList <String[]> returnList = new ArrayList();
        PreparedStatement stmt;   
        try 
        {
            ArrayList <String[]> users = db.user.all_users(con);  
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT passwords.id AS passwords_id,"
                    + "passwords.safe_id AS passwords_safe_id,"
                    + "passwords.name AS passwords_name,"
                    + "passwords.description AS passwords_description,"
                    + "passwords.password AS passwords_password,"
                    + "passwords.expires_on AS passwords_expires,"
                    + "passwords.date_created AS passwords_date_created,"
                    + "passwords.creator_user_id AS passwords_creator_user_id,"
                    + "safes.name AS safes_name "
                    + "FROM passwords LEFT JOIN safes ON safes.id = passwords.safe_id");
            ResultSet rs = stmt.executeQuery();
            
            //System.out.println("db.password.all_passwords_with_safe_name stmt=" + stmt);
            java.util.Date date1= new java.util.Date();
                    
            //System.out.println("q=" + myObj); // Display the current date
            while(rs.next())
            {                
                String temp[] = new String[13];
                temp[0] = rs.getString("passwords_id");
                temp[1] = rs.getString("passwords_safe_id");
                temp[2] = rs.getString("passwords_name");
                temp[3] = rs.getString("passwords_description");                   
                try
                {
                    p_word = support.encryption.decrypt_aes256(rs.getString("passwords_password"), key, salt);
                    if(p_word == null)
                    {
                        p_word = "*Encryption Error*";
                    }
                }
                catch(SQLException e)
                {
                    p_word = "";
                }
                temp[4] = p_word; 
                temp[5] = rs.getString("passwords_expires");   
                temp[6] = rs.getString("passwords_date_created");   
                temp[7] = rs.getString("passwords_creator_user_id"); 
                
                String safe_name = rs.getString("safes_name");
                try
                {
                    if(safe_name == null || safe_name.equalsIgnoreCase("null"))
                    {
                        temp[8] = "--";  
                    }
                    else
                    {
                        temp[8] = rs.getString("safes_name");  
                    }
                }
                catch(SQLException e)
                {
                    temp[8] = rs.getString("--");  
                }   
                temp[9] = "";
                for(String[] user: users)
                {
                    if(user[0].equalsIgnoreCase(temp[7]))
                    {
                        temp[9] = user[1];
                    }
                }
                returnList.add(temp);
            }
            java.util.Date date2= new java.util.Date();
            System.out.println("all_passwords_with_safe_name q time=" + (date2.getTime() - date1.getTime())); // Display the current date
            stmt.close();
        }
        catch(IOException | SQLException e)
        {
            System.out.println("ERROR SQLException password.all_passwords_with_safe_name:=" + e);
        }
        return returnList;
    }
    public static ArrayList <String[]> all_passwords_with_safe_name_filtered (Connection con, HttpSession session, String q)
    {
        //SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
        
        SimpleDateFormat datetime = new SimpleDateFormat("yyyyMMddHHmmss"); //'2023-01-01 23:59:59'
        
        //SimpleDateFormat display_format = new SimpleDateFormat("HH:mm / MM/dd/yyyy");//18:31 / 14-Jan-19
        //SimpleDateFormat date_time_picker_format = new SimpleDateFormat("HH:mm MM/dd/yyyy");//01:00 01/27/2020   
        //SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
        //SimpleDateFormat jquery_datetime_picker_format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");//MM-dd-YYYY hh:mm a
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        String p_word = "";
        ArrayList <String[]> returnList = new ArrayList();
        PreparedStatement stmt = null;   
        try 
        {
            ArrayList <String[]> users = db.user.all_users(con);  
            // Create a Statement Object
            if(q.equalsIgnoreCase("all"))
            {
                stmt = con.prepareStatement("SELECT passwords.id AS passwords_id,"
                    + "passwords.safe_id AS passwords_safe_id,"
                    + "passwords.name AS passwords_name,"
                    + "passwords.description AS passwords_description,"
                    + "passwords.password AS passwords_password,"
                    + "passwords.expires_on AS passwords_expires,"
                    + "passwords.date_created AS passwords_date_created,"
                    + "passwords.creator_user_id AS passwords_creator_user_id,"
                    + "safes.name AS safes_name "
                    + "FROM passwords LEFT JOIN safes ON safes.id = passwords.safe_id");
            }
            else if(q.equalsIgnoreCase("orphaned"))
            {
                stmt = con.prepareStatement("SELECT passwords.id AS passwords_id,"
                    + "passwords.safe_id AS passwords_safe_id,"
                    + "passwords.name AS passwords_name,"
                    + "passwords.description AS passwords_description,"
                    + "passwords.password AS passwords_password,"
                    + "passwords.expires_on AS passwords_expires,"
                    + "passwords.date_created AS passwords_date_created,"
                    + "passwords.creator_user_id AS passwords_creator_user_id,"
                    + "safes.name AS safes_name "
                    + "FROM passwords LEFT JOIN safes ON safes.id = passwords.safe_id WHERE passwords.safe_id =='-1' OR passwords.safe_id ==''");
            }
            else if(q.equalsIgnoreCase("expired"))
            {            
                GregorianCalendar cal = new GregorianCalendar();
                cal.add(cal.DATE, 30);
                String thirty_days = datetime.format(cal.getTime());
                stmt = con.prepareStatement("SELECT passwords.id AS passwords_id,"
                    + "passwords.safe_id AS passwords_safe_id,"
                    + "passwords.name AS passwords_name,"
                    + "passwords.description AS passwords_description,"
                    + "passwords.password AS passwords_password,"
                    + "passwords.expires_on AS passwords_expires,"
                    + "passwords.date_created AS passwords_date_created,"
                    + "passwords.creator_user_id AS passwords_creator_user_id,"
                    + "safes.name AS safes_name "
                    + "FROM passwords LEFT JOIN safes ON safes.id = passwords.safe_id WHERE expires_on < '" + thirty_days + "'");
            }
            ResultSet rs = stmt.executeQuery();
            
            while(rs.next())
            {                
                String temp[] = new String[13];
                temp[0] = rs.getString("passwords_id");
                temp[1] = rs.getString("passwords_safe_id");
                temp[2] = rs.getString("passwords_name");
                temp[3] = rs.getString("passwords_description");                   
                try
                {
                    p_word = support.encryption.decrypt_aes256(rs.getString("passwords_password"), key, salt);
                    if(p_word == null)
                    {
                        p_word = "*Encryption Error*";
                    }
                }
                catch(SQLException e)
                {
                    p_word = "";
                }
                temp[4] = p_word; 
                temp[5] = rs.getString("passwords_expires");   
                temp[6] = rs.getString("passwords_date_created");   
                temp[7] = rs.getString("passwords_creator_user_id"); 
                
                String safe_name = rs.getString("safes_name");
                try
                {
                    if(safe_name == null || safe_name.equalsIgnoreCase("null"))
                    {
                        temp[8] = "--";  
                    }
                    else
                    {
                        temp[8] = rs.getString("safes_name");  
                    }
                }
                catch(SQLException e)
                {
                    temp[8] = rs.getString("--");  
                }   
                temp[9] = "";
                for(String[] user: users)
                {
                    if(user[0].equalsIgnoreCase(temp[7]))
                    {
                        temp[9] = user[1];
                    }
                }
                returnList.add(temp);
            }
            stmt.close();
        }
        catch(IOException | SQLException e)
        {
            System.out.println("ERROR SQLException password.all_passwords_with_safe_name:=" + e);
        }
        return returnList;
    }
    public static int next_history_id(Connection con) throws IOException, SQLException
    {
        int returnInt = 0;
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT max(id) AS value FROM password_history");
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                returnInt = rs.getInt("value");              
            }
            returnInt++;
            stmt.close();
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException password.next_history_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception password.next_history_id:=" + exc);
	}
        return returnInt;
    }
    public static boolean add_password_history_record(
            Connection con, 
            HttpSession session,
            String action, 
            String password_id, 
            String safe_id,
            String name,
            String description,
            String password,
            String expires_on,
            String date_created,
            String creator_user_id
            )            
    {
        SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
        boolean return_boolean = true;
        int next_history_id = 0;
        java.util.Date date_changed = new java.util.Date();
        String changed_by_user_id = session.getAttribute("user_id").toString();
        try
        {
            java.util.Date temp1 = timestamp_format.parse(expires_on);
            expires_on = timestamp_format.format(temp1);
        }
        catch(ParseException e)
        {
            expires_on = "";
            System.out.println("password.add_password_history_record Date format error=" + e + " DATE=" + expires_on);
        }
        try
        {
            java.util.Date temp1 = timestamp_format.parse(date_created);
            date_created = timestamp_format.format(temp1);
        }
        catch(Exception e)
        {
            date_created = "";
        }
        PreparedStatement stmt;   
        try 
        {
            next_history_id = db.password.next_history_id(con);
            stmt = con.prepareStatement("INSERT INTO password_history (" +
                                        "id," + 
                                        "changed_by_user_id," + 
                                        "action," + 
                                        "date_changed," + 
                                        "password_id," + 
                                        "safe_id," + 
                                        "name," + 
                                        "description," + 
                                        "password," + 
                                        "expires_on," + 
                                        "date_created," + 
                                        "creator_user_id" + 
                                        ")" +
                                        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
            stmt.setInt(1, next_history_id);
            stmt.setString(2, changed_by_user_id);
            stmt.setString(3, action);
            stmt.setString(4, timestamp_format.format(date_changed));
            stmt.setString(5, password_id);
            stmt.setString(6, safe_id);
            stmt.setString(7, name);
            stmt.setString(8, description);
            stmt.setString(9, password);
            stmt.setString(10, expires_on);
            stmt.setString(11, date_created);
            stmt.setString(12, creator_user_id);
            stmt.executeUpdate();
            stmt.close();
        }
        catch(IOException | SQLException e)
        {
            //System.out.println("ERROR SQLException password.add_password_history_record:=" + e);
            return_boolean = false;
        }
        return return_boolean;
    }
    
    public static ArrayList <String[]> get_password_history(Connection con, HttpSession session, String password_id)
    {
        System.out.println("password_id=" + password_id);
        ArrayList <String[]> return_arraylist = new ArrayList();
        //SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
        //SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
        //SimpleDateFormat jquery_datetime_picker_format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");//MM-dd-YYYY hh:mm a
        
        String p_word = "";
        String creator_name = "";
        String change_user_name = "";
        String safe_name = "";
        java.util.Date date_changed = new java.util.Date();
        String system_key = session.getAttribute("system_key").toString();
        String system_salt = session.getAttribute("system_salt").toString();
        
        PreparedStatement stmt;   
        try 
        {
            ArrayList <String[]> users = db.user.all_users(con);
            ArrayList <String[]> safes = db.safe.all_safes(con);
            stmt = con.prepareStatement("SELECT * FROM password_history WHERE password_id=? ORDER BY date_changed DESC");
            stmt.setString(1, password_id);
            ResultSet rs = stmt.executeQuery();            
            while(rs.next())
            {      
                //System.out.println("password_id=" + password_id);
                String temp[] = new String[15];
                
                temp[0] = rs.getString("id");//id
                
                temp[1] = rs.getString("changed_by_user_id");//changed_by_user_id,
                temp[2] = rs.getString("action");//action,
                temp[3] = rs.getString("date_changed");//date_changed,
                temp[4] = rs.getString("password_id");//password_id,
                temp[5] = rs.getString("safe_id");//password_id,     
                temp[6] = rs.getString("name");//name,
                temp[7] = rs.getString("description");//description,
                try
                {
                    p_word = support.encryption.decrypt_aes256(rs.getString("password"), system_key, system_salt);
                    if(p_word == null)
                    {
                        p_word = "*Encryption Error*";
                    }
                }
                catch(SQLException e)
                {
                    p_word = "";
                }
                temp[8] = p_word;//password,
                temp[9] = rs.getString("expires_on");//expires_on,
                temp[10] = rs.getString("date_created");//date_created,
                temp[11] = rs.getString("changed_by_user_id");//date_created,
                change_user_name = "";
                for(String[] user : users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("changed_by_user_id")))
                    {
                        change_user_name = user[1];
                        break;
                    }
                }
                temp[12] = change_user_name;//change_user_name
                creator_name = "";
                for(String[] user : users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("creator_user_id")))
                    {
                        creator_name = user[1];
                        break;
                    }
                }
                temp[13] = creator_name;//creator_username
                safe_name = "";
                for(String[] safe : safes)
                {
                    if(safe[0].equalsIgnoreCase(rs.getString("safe_id")))
                    {
                        safe_name = safe[2];
                        break;
                    }
                }
                temp[14] = safe_name;//safe name,
                return_arraylist.add(temp);
            }
            
            stmt.close();
        }
        catch(SQLException e)
        {
            System.out.println("ERROR SQLException password.get_password_history:=" + e);
            
        } catch (IOException ex) 
        {
            System.out.println("ERROR IOException password.get_password_history:=" + ex);
        }
        return return_arraylist;
    }
    public static ArrayList <String[]> all_passwords_from_safe_id (Connection con, String safe_id)
    {
        ArrayList <String[]> returnList = new ArrayList();
        PreparedStatement stmt;   
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT passwords.id AS passwords_id,"
                    + "passwords.safe_id AS passwords_safe_id,"
                    + "passwords.name AS passwords_name,"
                    + "passwords.description AS passwords_description,"
                    + "passwords.password AS passwords_password,"
                    + "passwords.expires_on AS passwords_expires,"
                    + "passwords.date_created AS passwords_date_created,"
                    + "passwords.creator_user_id AS passwords_creator_user_id "
                    + "FROM passwords WHERE safe_id=?");
            stmt.setString(1, safe_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                String temp[] = new String[8];
                temp[0] = rs.getString("passwords_id");
                temp[1] = rs.getString("passwords_safe_id");
                temp[2] = rs.getString("passwords_name");
                temp[3] = rs.getString("passwords_description");                   
                temp[4] = rs.getString("passwords_password"); 
                temp[5] = rs.getString("passwords_expires");   
                temp[6] = rs.getString("passwords_date_created");   
                temp[7] = rs.getString("passwords_creator_user_id");   
                returnList.add(temp);
            }
            stmt.close();
        }
        catch(SQLException e)
        {
            System.out.println("ERROR SQLException password.all_passwords_from_safe_id:=" + e);
        }
        return returnList;
    }
    public static ArrayList <String[]> passwords_for_safe_id_with_user_name(Connection con, String safe_id, HttpSession session) throws IOException, SQLException
    {
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        String p_word = "";
        ArrayList <String[]> returnList = new ArrayList();
        PreparedStatement stmt;
        try 
        {
            ArrayList <String[]> users = db.user.all_users(con);
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT  * FROM passwords WHERE safe_id=?");
            stmt.setString(1, safe_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                String temp[] = new String[9];
                temp[0] = rs.getString("id");   
                temp[1] = rs.getString("safe_id");   
                temp[2] = rs.getString("name");   
                temp[3] = rs.getString("description");   
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
                temp[4] = p_word;   
                temp[5] = rs.getString("expires_on");   
                temp[6] = rs.getString("date_created");                  
                temp[7] = rs.getString("creator_user_id");   
                temp[8] = "";
                for(String[] user: users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("creator_user_id")))
                    {
                        temp[8] = user[1];
                    }
                }
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException password.passwords_for_safe_id_with_user_name:=" + ex);
        }
        catch(IOException exc) 
        {
            System.out.println("ERROR Exception password.passwords_for_safe_id_with_user_name:=" + exc);
	}
        return returnList;
    } 
    public static String[] password_info_decrypted(Connection con, String password_id, HttpSession session) throws IOException, SQLException
    {
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        String p_word = "";
        String[] returnArray = {"","","","","","","",""};
        PreparedStatement stmt;
        try 
        {
            stmt = con.prepareStatement("SELECT  * FROM passwords WHERE id=?");
            stmt.setString(1, password_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                returnArray[0] = rs.getString("id");   
                returnArray[1] = rs.getString("safe_id");   
                returnArray[2] = rs.getString("name");   
                returnArray[3] = rs.getString("description");   
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
                returnArray[4] = p_word;   
                returnArray[5] = rs.getString("expires_on");   
                returnArray[6] = rs.getString("date_created");                  
                returnArray[7] = rs.getString("creator_user_id");   
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException password.password_info_decrypted:=" + ex);
        }
        return returnArray;
    } 
    public static String[] password_info_encrypted(Connection con, String password_id, HttpSession session) throws IOException, SQLException
    {
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        String p_word = "";
        String[] returnArray = {"","","","","","","",""};
        PreparedStatement stmt;
        try 
        {
            stmt = con.prepareStatement("SELECT  * FROM passwords WHERE id=?");
            stmt.setString(1, password_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                returnArray[0] = rs.getString("id");   
                returnArray[1] = rs.getString("safe_id");   
                returnArray[2] = rs.getString("name");   
                returnArray[3] = rs.getString("description");   
                returnArray[4] = rs.getString("password");   
                returnArray[5] = rs.getString("expires_on");   
                returnArray[6] = rs.getString("date_created");                  
                returnArray[7] = rs.getString("creator_user_id");   
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException password.password_info_encrypted:=" + ex);
        }
        return returnArray;
    } 
    public static String[] get_password_history_by_id_encrypted(Connection con, HttpSession session, String password_history_id)
    {
        String[] return_array = {"","","","","","","","","","","",""};
        PreparedStatement stmt;   
        try 
        {
            stmt = con.prepareStatement("SELECT * FROM password_history WHERE id=?");
            stmt.setString(1, password_history_id);
            ResultSet rs = stmt.executeQuery();            
            while(rs.next())
            {                
                return_array[0] = rs.getString("id");//id                
                return_array[1] = rs.getString("changed_by_user_id");//changed_by_user_id,
                return_array[2] = rs.getString("action");//action,
                return_array[3] = rs.getString("date_changed");//date_changed,
                return_array[4] = rs.getString("password_id");//password_id,
                return_array[5] = rs.getString("safe_id");//password_id,     
                return_array[6] = rs.getString("name");//name,
                return_array[7] = rs.getString("description");//description,
                return_array[8] = rs.getString("password");//password,
                return_array[9] = rs.getString("expires_on");//expires_on,
                return_array[10] = rs.getString("date_created");//date_created,
                return_array[11] = rs.getString("creator_user_id");//creator_user_id                
            }            
            stmt.close();
        }
        catch(SQLException e)
        {
            System.out.println("ERROR SQLException password.get_password_history_by_id_encrypted:=" + e);
            
        }
        return return_array;
    }
    public static ArrayList <String[]> get_all_deleted_password_history(Connection con, HttpSession session)
    {
        ArrayList <String[]> return_arraylist = new ArrayList();
        
        String p_word = "";
        String creator_name = "";
        String change_user_name = "";
        String safe_name = "";
        java.util.Date date_changed = new java.util.Date();
        String system_key = session.getAttribute("system_key").toString();
        String system_salt = session.getAttribute("system_salt").toString();
        
        PreparedStatement stmt;   
        try 
        {
            ArrayList <String[]> users = db.user.all_users(con);
            ArrayList <String[]> safes = db.safe.all_safes(con);
            stmt = con.prepareStatement("SELECT * FROM password_history WHERE action=? ORDER BY date_changed DESC");
            stmt.setString(1, "Delete");
            ResultSet rs = stmt.executeQuery();            
            while(rs.next())
            {                
                String temp[] = new String[15];
                
                temp[0] = rs.getString("id");//id
                
                temp[1] = rs.getString("changed_by_user_id");//changed_by_user_id,
                temp[2] = rs.getString("action");//action,
                temp[3] = rs.getString("date_changed");//date_changed,
                temp[4] = rs.getString("password_id");//password_id,
                temp[5] = rs.getString("safe_id");//password_id,     
                temp[6] = rs.getString("name");//name,
                temp[7] = rs.getString("description");//description,
                try
                {
                    p_word = support.encryption.decrypt_aes256(rs.getString("password"), system_key, system_salt);
                    if(p_word == null)
                    {
                        p_word = "*Encryption Error*";
                    }
                }
                catch(SQLException e)
                {
                    p_word = "";
                }
                temp[8] = p_word;//password,
                temp[9] = rs.getString("expires_on");//expires_on,
                temp[10] = rs.getString("date_created");//date_created,
                temp[11] = rs.getString("changed_by_user_id");//date_created,
                change_user_name = "";
                for(String[] user : users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("changed_by_user_id")))
                    {
                        change_user_name = user[1];
                        break;
                    }
                }
                temp[12] = change_user_name;//change_user_name
                creator_name = "";
                for(String[] user : users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("creator_user_id")))
                    {
                        creator_name = user[1];
                        break;
                    }
                }
                temp[13] = creator_name;//creator_username
                safe_name = "";
                for(String[] safe : safes)
                {
                    if(safe[0].equalsIgnoreCase(rs.getString("safe_id")))
                    {
                        safe_name = safe[2];
                        break;
                    }
                }
                temp[14] = safe_name;//safe name,
                return_arraylist.add(temp);
            }
            
            stmt.close();
        }
        catch(SQLException e)
        {
            System.out.println("ERROR SQLException password.get_all_deleted_password_history:=" + e);
            
        } catch (IOException ex) 
        {
            System.out.println("ERROR IOException password.get_all_deleted_password_history:=" + ex);
        }
        return return_arraylist;
    }
    public static ArrayList <String[]> get_all_deleted_password_history_for_safe_id(Connection con, HttpSession session, String safe_id)
    {
        ArrayList <String[]> return_arraylist = new ArrayList();
        //SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
        //SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
        
        String p_word = "";
        String creator_name = "";
        String change_user_name = "";
        String safe_name = "";
        java.util.Date date_changed = new java.util.Date();
        String system_key = session.getAttribute("system_key").toString();
        String system_salt = session.getAttribute("system_salt").toString();
        
        PreparedStatement stmt;   
        try 
        {
            ArrayList <String[]> users = db.user.all_users(con);
            ArrayList <String[]> safes = db.safe.all_safes(con);
            stmt = con.prepareStatement("SELECT * FROM password_history WHERE action=? AND safe_id=? ORDER BY date_changed DESC");
            stmt.setString(1, "Delete");
            stmt.setString(2, safe_id);
            ResultSet rs = stmt.executeQuery();            
            while(rs.next())
            {                
                String temp[] = new String[15];
                
                temp[0] = rs.getString("id");//id
                
                temp[1] = rs.getString("changed_by_user_id");//changed_by_user_id,
                temp[2] = rs.getString("action");//action,
                temp[3] = rs.getString("date_changed");//date_changed,
                temp[4] = rs.getString("password_id");//password_id,
                temp[5] = rs.getString("safe_id");//password_id,     
                temp[6] = rs.getString("name");//name,
                temp[7] = rs.getString("description");//description,
                try
                {
                    p_word = support.encryption.decrypt_aes256(rs.getString("password"), system_key, system_salt);
                    if(p_word == null)
                    {
                        p_word = "*Encryption Error*";
                    }
                }
                catch(SQLException e)
                {
                    p_word = "";
                }
                temp[8] = p_word;//password,
                temp[9] = rs.getString("expires_on");//expires_on,
                temp[10] = rs.getString("date_created");//date_created,
                temp[11] = rs.getString("changed_by_user_id");//date_created,
                change_user_name = "";
                for(String[] user : users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("changed_by_user_id")))
                    {
                        change_user_name = user[1];
                        break;
                    }
                }
                temp[12] = change_user_name;//change_user_name
                creator_name = "";
                for(String[] user : users)
                {
                    if(user[0].equalsIgnoreCase(rs.getString("creator_user_id")))
                    {
                        creator_name = user[1];
                        break;
                    }
                }
                temp[13] = creator_name;//creator_username
                safe_name = "";
                for(String[] safe : safes)
                {
                    if(safe[0].equalsIgnoreCase(rs.getString("safe_id")))
                    {
                        safe_name = safe[2];
                        break;
                    }
                }
                temp[14] = safe_name;//safe name,
                return_arraylist.add(temp);
            }
            
            stmt.close();
        }
        catch(SQLException e)
        {
            System.out.println("ERROR SQLException password.get_all_deleted_password_history_for_safe_id:=" + e);
            
        } catch (IOException ex) 
        {
            System.out.println("ERROR IOException password.get_all_deleted_password_history_for_safe_id:=" + ex);
        }
        return return_arraylist;
    }
}

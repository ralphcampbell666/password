package db;

import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;


public class user 
{
    public static String[] validate(Connection con, HttpSession session, String useraname, String password) throws IOException, SQLException
    {
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        
        String returnString[] = new String[17];
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM users WHERE username=?");
            stmt.setString(1, useraname);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                returnString[0] = rs.getString("id");
                returnString[1] = rs.getString("username");
                returnString[2] = rs.getString("password");                
                returnString[3] = support.string_utils.check_for_null(rs.getString("first"));
                returnString[4] = support.string_utils.check_for_null(rs.getString("mi"));
                returnString[5] = support.string_utils.check_for_null(rs.getString("last"));
                returnString[6] = support.string_utils.check_for_null(rs.getString("address_1"));
                returnString[7] = support.string_utils.check_for_null(rs.getString("address_2"));
                returnString[8] = support.string_utils.check_for_null(rs.getString("city"));
                returnString[9] = support.string_utils.check_for_null(rs.getString("state"));
                returnString[10] = support.string_utils.check_for_null(rs.getString("zip"));
                returnString[11] = support.string_utils.check_for_null(rs.getString("email"));
                returnString[12] = support.string_utils.check_for_null(rs.getString("phone_office"));
                returnString[13] = support.string_utils.check_for_null(rs.getString("phone_mobile"));
                returnString[14] = support.string_utils.check_for_null(rs.getString("notes"));
                returnString[15] = support.string_utils.check_for_null(rs.getString("is_admin"));
                returnString[16] = support.string_utils.check_for_null(rs.getString("safe_creator"));
                
                String decrypted_password = support.encryption.decrypt_aes256(rs.getString("password"), key, salt);
                if(password.equals(decrypted_password))
                {
                    //System.out.println("passwords do match");
                }
                else
                {
                    //System.out.println("passwords do not match");
                    returnString = new String[17];
                }
            }
            stmt.close();
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException user.validate:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception user.validate:=" + exc);
	}
        return returnString;
    }
    public static ArrayList <String[]> all_users(Connection con) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM users");
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                String temp[] = new String[17];
                temp[0] = rs.getString("id");
                temp[1] = rs.getString("username");
                temp[2] = rs.getString("password");                
                temp[3] = support.string_utils.check_for_null(rs.getString("first"));
                temp[4] = support.string_utils.check_for_null(rs.getString("mi"));
                temp[5] = support.string_utils.check_for_null(rs.getString("last"));
                temp[6] = support.string_utils.check_for_null(rs.getString("address_1"));
                temp[7] = support.string_utils.check_for_null(rs.getString("address_2"));
                temp[8] = support.string_utils.check_for_null(rs.getString("city"));
                temp[9] = support.string_utils.check_for_null(rs.getString("state"));
                temp[10] = support.string_utils.check_for_null(rs.getString("zip"));
                temp[11] = support.string_utils.check_for_null(rs.getString("email"));
                temp[12] = support.string_utils.check_for_null(rs.getString("phone_office"));
                temp[13] = support.string_utils.check_for_null(rs.getString("phone_mobile"));
                temp[14] = support.string_utils.check_for_null(rs.getString("notes"));
                temp[15] = support.string_utils.check_for_null(rs.getString("is_admin"));
                temp[16] = support.string_utils.check_for_null(rs.getString("safe_creator"));
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException user.all_users:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception user.all_users:=" + exc);
	}
        return returnList;
    }
    public static ArrayList <String[]> all_users_in_group(Connection con, String group_id) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM users INNER JOIN user_group on user_group.user_id = users.id WHERE user_group.group_id=?");
            stmt.setString(1, group_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                String temp[] = new String[17];
                temp[0] = rs.getString("id");
                temp[1] = rs.getString("username");
                temp[2] = rs.getString("password");                
                temp[3] = support.string_utils.check_for_null(rs.getString("first"));
                temp[4] = support.string_utils.check_for_null(rs.getString("mi"));
                temp[5] = support.string_utils.check_for_null(rs.getString("last"));
                temp[6] = support.string_utils.check_for_null(rs.getString("address_1"));
                temp[7] = support.string_utils.check_for_null(rs.getString("address_2"));
                temp[8] = support.string_utils.check_for_null(rs.getString("city"));
                temp[9] = support.string_utils.check_for_null(rs.getString("state"));
                temp[10] = support.string_utils.check_for_null(rs.getString("zip"));
                temp[11] = support.string_utils.check_for_null(rs.getString("email"));
                temp[12] = support.string_utils.check_for_null(rs.getString("phone_office"));
                temp[13] = support.string_utils.check_for_null(rs.getString("phone_mobile"));
                temp[14] = support.string_utils.check_for_null(rs.getString("notes"));
                temp[15] = support.string_utils.check_for_null(rs.getString("is_admin"));
                temp[16] = support.string_utils.check_for_null(rs.getString("safe_creator"));
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException user.all_users_in_group:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception user.all_users_in_group:=" + exc);
	}
        return returnList;
    }
    public static String[] info(Connection con, String user_id) throws IOException, SQLException
    {
        String returnString[] = {"","","","","","","","","","","","","","","","",""};
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM users WHERE id=?");
            stmt.setString(1, user_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                returnString[0] = rs.getString("id");
                returnString[1] = rs.getString("username");
                returnString[2] = rs.getString("password");                
                returnString[3] = support.string_utils.check_for_null(rs.getString("first"));
                returnString[4] = support.string_utils.check_for_null(rs.getString("mi"));
                returnString[5] = support.string_utils.check_for_null(rs.getString("last"));
                returnString[6] = support.string_utils.check_for_null(rs.getString("address_1"));
                returnString[7] = support.string_utils.check_for_null(rs.getString("address_2"));
                returnString[8] = support.string_utils.check_for_null(rs.getString("city"));
                returnString[9] = support.string_utils.check_for_null(rs.getString("state"));
                returnString[10] = support.string_utils.check_for_null(rs.getString("zip"));
                returnString[11] = support.string_utils.check_for_null(rs.getString("email"));
                returnString[12] = support.string_utils.check_for_null(rs.getString("phone_office"));
                returnString[13] = support.string_utils.check_for_null(rs.getString("phone_mobile"));
                returnString[14] = support.string_utils.check_for_null(rs.getString("notes"));
                returnString[15] = support.string_utils.check_for_null(rs.getString("is_admin"));
                returnString[16] = support.string_utils.check_for_null(rs.getString("safe_creator"));
            }
            stmt.close();
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException user.info:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception user.info:=" + exc);
	}
        return returnString;
    }
    public static int next_user_id(Connection con) throws IOException, SQLException
    {
        int return_int = 0;  
        String ps_query_string = "SELECT max(id) AS value FROM users";        
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement(ps_query_string);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                return_int = rs.getInt("value");   
            }
            stmt.close();
            //add 1 to max
            return_int++;
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException user.next_user_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception user.next_user_id:=" + exc);
	}
        return return_int;
    }
}

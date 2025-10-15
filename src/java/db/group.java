package db;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;


public class group 
{
    public static int next_id(Connection con) throws IOException, SQLException
    {
        int returnInt = -1;
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT max(id) AS value FROM groups");
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
            System.out.println("ERROR SQLException group.next_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception group.next_id:=" + exc);
	}
        return returnInt;
    }
    public static String[] by_id(Connection con, String id) throws IOException, SQLException
    {
        String returnString[] = new String[3];
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM groups WHERE id=?");
            stmt.setString(1, id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                returnString[0] = rs.getString("id");
                returnString[1] = rs.getString("name");
                returnString[2] = rs.getString("description");                
            }
            stmt.close();
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException group.by_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception group.by_id:=" + exc);
	}
        return returnString;
    }
    public static ArrayList <String[]> all_groups(Connection con) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM groups ORDER BY name");
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                String temp[] = new String[3];
                temp[0] = rs.getString("id");
                temp[1] = rs.getString("name");
                temp[2] = rs.getString("description");   
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException group.all_groups:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception group.all_groups:=" + exc);
	}
        return returnList;
    }
    public static ArrayList <String> groups_assigned_to_user_id(Connection con, String user_id) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT group_id FROM user_group WHERE user_id=?");
            stmt.setString(1, user_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                   
                returnList.add(rs.getString("group_id"));
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException group.groups_assigned_to_user_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception group.groups_assigned_to_user_id:=" + exc);
	}
        return returnList;
    }
}

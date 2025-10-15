package db;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 *
 * @author ralph
 */
public class safe 
{
    public static int next_id(Connection con) throws IOException, SQLException
    {
        int returnInt = -1;
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT max(id) AS value FROM safes");
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {
                returnInt = rs.getInt("value");              
            }
            returnInt++;
            rs.close();
            stmt.close();
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException safe.next_id:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception safe.next_id:=" + exc);
	}
        return returnInt;
    }
    public static ArrayList <String[]> all_safes(Connection con) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM safes ORDER BY name");
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                String temp[] = new String[4];
                temp[0] = rs.getString("id");
                temp[1] = rs.getString("owner_id");
                temp[2] = rs.getString("name");
                temp[3] = rs.getString("description");   
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException safe.all_safes:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception safe.all_safes:=" + exc);
	}
        return returnList;
    }
    public static ArrayList <String[]> safe_group_by_group(Connection con, String group_id) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT id,owner_id,name,description FROM safes INNER JOIN group_safe ON safes.id = group_safe.safe_id WHERE group_safe.group_id=?");
            stmt.setString(1, group_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                String temp[] = new String[4];
                temp[0] = rs.getString("id");
                temp[1] = rs.getString("owner_id");
                temp[2] = rs.getString("name");
                temp[3] = rs.getString("description");   
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException safe.safe_group_by_group:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception safe.safe_group_by_group:=" + exc);
	}
        return returnList;
    }
    public static ArrayList <String[]> safe_name_by_group(Connection con, String group_id) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT `safes`.`id`,`safes`.`owner_id`,`safes`.`name`,`safes`.`description`,`group_safe`.`group_id`, `group_safe`.`safe_id`,`group_safe`.`c`,`group_safe`.`r`,`group_safe`.`u`,`group_safe`.`d` FROM safes INNER JOIN group_safe ON safes.id = group_safe.safe_id WHERE group_safe.group_id=?");
            stmt.setString(1, group_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                String temp[] = new String[10];
                temp[0] = rs.getString("id");
                temp[1] = rs.getString("owner_id");
                temp[2] = rs.getString("name");
                temp[3] = rs.getString("description");   
                temp[4] = rs.getString("group_id");   
                temp[5] = rs.getString("safe_id");   
                temp[6] = rs.getString("c");   
                temp[7] = rs.getString("r");   
                temp[8] = rs.getString("u");   
                temp[9] = rs.getString("d");   
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException safe.safe_name_by_group:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception safe.safe_name_by_group:=" + exc);
	}
        return returnList;
    }
    public static ArrayList<String> my_safes(Connection con, String user_id)
    {
        ArrayList<String> returnList = new ArrayList();
        try
        {
            PreparedStatement stmt;
            String user_info[] = db.user.info(con, user_id);            
            boolean is_admin = false;
            try
            {
                if(user_info[15].equalsIgnoreCase("1"))
                {
                    is_admin = true;
                }
            }
            catch(Exception e)
            {
                is_admin = false;
            }
            if(is_admin)
            {
                //get all safes
                stmt = con.prepareStatement("SELECT id FROM safes");
                ResultSet rs = stmt.executeQuery();
                while(rs.next())
                {                
                    returnList.add(rs.getString("id"));
                }
            }
            else
            {
                //get safes that any of my groups have any permission
                boolean can = false;
                stmt = con.prepareStatement("SELECT * FROM group_safe WHERE group_id IN (SELECT group_id FROM user_group WHERE user_id=?)");
                stmt.setString(1, user_id);
                ResultSet rs = stmt.executeQuery();
                while(rs.next())
                {    
                    String safe_id = rs.getString("safe_id");
                    can = false;
                    if(rs.getString("c").equals("1"))
                    {
                        can = true;
                    }
                    else if(rs.getString("r").equals("1"))
                    {
                        can = true;
                    }
                    else if(rs.getString("u").equals("1"))
                    {
                        can = true;
                    }
                    else if(rs.getString("d").equals("1"))
                    {
                        can = true;
                    }
                    if(can)
                    {
                        if(!returnList.contains(rs.getString("safe_id")))
                        {
                            returnList.add(rs.getString("safe_id"));
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.out.println("Exception in db.safe.my_safes=" + e);
        }        
        return returnList;
    }
    public static ArrayList<String> my_safes_with_create(Connection con, String user_id)
    {
        ArrayList<String> returnList = new ArrayList();
        try
        {
            PreparedStatement stmt;
            String user_info[] = db.user.info(con, user_id);            
            boolean is_admin = false;
            try
            {
                if(user_info[15].equalsIgnoreCase("1"))
                {
                    is_admin = true;
                }
            }
            catch(Exception e)
            {
                is_admin = false;
            }
            if(is_admin)
            {
                //get all safes
                stmt = con.prepareStatement("SELECT id FROM safes");
                ResultSet rs = stmt.executeQuery();
                while(rs.next())
                {                
                    returnList.add(rs.getString("id"));
                }
            }
            else
            {
                //get safes that any of my groups have any permission
                boolean can = false;
                stmt = con.prepareStatement("SELECT * FROM group_safe WHERE group_id IN (SELECT group_id FROM user_group WHERE user_id=?)");
                stmt.setString(1, user_id);
                ResultSet rs = stmt.executeQuery();
                while(rs.next())
                {    
                    String safe_id = rs.getString("safe_id");
                    can = false;
                    if(rs.getString("c").equals("1"))
                    {
                        can = true;
                    }
                    if(can)
                    {
                        if(!returnList.contains(rs.getString("safe_id")))
                        {
                            returnList.add(rs.getString("safe_id"));
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.out.println("Exception in db.safe.my_safes_with_create=" + e);
        }        
        return returnList;
    }
    public static String[] safe_info(Connection con, String safe_id) throws IOException, SQLException
    {
        String returnArray[] = {"","","",""};
        PreparedStatement stmt;
        try 
        {
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM safes WHERE id=?");
            stmt.setString(1, safe_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {                
                returnArray[0] = rs.getString("id");
                returnArray[1] = rs.getString("owner_id");
                returnArray[2] = rs.getString("name");
                returnArray[3] = rs.getString("description");   
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException safe.safe_info:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception safe.safe_info:=" + exc);
	}
        return returnArray;
    }
    public static String[] my_permissions_for_safe(Connection con, String safe_id, String user_id)
    {
        String permissions[] = {"0","0","0","0"}; //CRUD
        try
        {
            PreparedStatement stmt;
            String user_info[] = db.user.info(con, user_id);            
            boolean is_admin = false;
            try
            {
                if(user_info[15].equalsIgnoreCase("1"))
                {
                    is_admin = true;
                }
            }
            catch(Exception e)
            {
                is_admin = false;
            }
            if(is_admin)
            {
                permissions[0] = "1";
                permissions[1] = "1";
                permissions[2] = "1";
                permissions[3] = "1";
            }
            else
            {
                //get groups the user is member and get the highest permission granted for all groups assigned                
                stmt = con.prepareStatement("SELECT * FROM group_safe WHERE safe_id=? AND group_id IN (SELECT group_id FROM user_group WHERE user_id=?)");
                stmt.setString(1, safe_id);
                stmt.setString(2, user_id);
                //System.out.println("safe.jsp q=" + stmt);
                ResultSet rs = stmt.executeQuery();
                while(rs.next())
                {   
                    if(rs.getString("c").equals("1"))
                    {
                        permissions[0] = "1";
                    }
                    if(rs.getString("r").equals("1"))
                    {
                        permissions[1] = "1";
                    }
                    if(rs.getString("u").equals("1"))
                    {
                        permissions[2] = "1";
                    }
                    if(rs.getString("d").equals("1"))
                    {
                        permissions[3] = "1";
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.out.println("Exception in db.safe.my_permissions_for_safe=" + e);
        }      
        //System.out.println("final permissions = " + permissions[0] + "," + permissions[1] + "," + permissions[2] + "," + permissions[3]);
        return permissions;
    }
    public static ArrayList <String[]> permissions_for_safe(Connection con, String safe_id)
    {        
        ArrayList<String[]> returnList = new ArrayList();
        try
        {
            PreparedStatement stmt;
            stmt = con.prepareStatement("SELECT * FROM group_safe WHERE safe_id=?");
            stmt.setString(1, safe_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {   
                String permissions[] = {"0","0","0","0","0","0"}; //CRUD
                permissions[0] = rs.getString("group_id");
                permissions[1] = rs.getString("safe_id");
                
                if(rs.getString("c").equals("1"))
                {
                    permissions[2] = "1";
                }
                if(rs.getString("r").equals("1"))
                {
                    permissions[3] = "1";
                }
                if(rs.getString("u").equals("1"))
                {
                    permissions[4] = "1";
                }
                if(rs.getString("d").equals("1"))
                {
                    permissions[5] = "1";
                }
                returnList.add(permissions);
            }
        }
        catch(Exception e)
        {
            System.out.println("Exception in db.safe.permissions_for_safe=" + e);
        }      
        //System.out.println("final permissions = " + permissions[0] + "," + permissions[1] + "," + permissions[2] + "," + permissions[3]);
        return returnList;
    }
    public static ArrayList<String[]> safe_permissions_for_group_id(Connection con, String safe_id, String group_id)
    {
        ArrayList<String[]> returnList = new ArrayList();
        boolean found = false;
        try
        {
            PreparedStatement stmt;            
            stmt = con.prepareStatement("SELECT group_id,safe_id,c,r,u,d FROM group_safe WHERE group_id=? AND safe_id=?");
            stmt.setString(1, group_id);
            stmt.setString(2, safe_id);
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {    
                found = true;
                String temp[] = new String[6];
                temp[0] = rs.getString("group_id");
                temp[1] = rs.getString("safe_id");
                temp[2] = rs.getString("c");
                temp[3] = rs.getString("r");
                temp[4] = rs.getString("u");
                temp[5] = rs.getString("d");
                returnList.add(temp);
            }
            if(!found)
            {
                String temp[] = new String[6];
                temp[0] = group_id;
                temp[1] = safe_id;
                temp[2] = "0";
                temp[3] = "0";
                temp[4] = "0";
                temp[5] = "0";
            }
        }
        catch(Exception e)
        {
            System.out.println("Exception in db.safe.safe_permissions_for_group_id=" + e);
        }        
        return returnList;
    }
    public static ArrayList <String[]> all_my_safes(Connection con, String user_id) throws IOException, SQLException
    {
        ArrayList returnList = new ArrayList<String>();
        PreparedStatement stmt;
        String where = "";
        try 
        {
            ArrayList<String> my_safes = db.safe.my_safes(con, user_id);
            for(String safe: my_safes)
            {
                if(where.equalsIgnoreCase(""))
                {
                    where = "id='" + safe + "'";
                }
                else
                {
                    where = where + " OR id='" + safe + "'";
                }
            }
            //System.out.println("all_my_safes=SELECT * FROM safes WHERE " + where + " ORDER BY name");
            // Create a Statement Object
            stmt = con.prepareStatement("SELECT * FROM safes WHERE " + where + " ORDER BY name");
            ResultSet rs = stmt.executeQuery();
            while(rs.next())
            {   
                //System.out.println("all_my_safes=" + rs.getString("id") + " name=" + rs.getString("name"));
                String temp[] = new String[4];
                temp[0] = rs.getString("id");
                temp[1] = rs.getString("owner_id");
                temp[2] = rs.getString("name");
                temp[3] = rs.getString("description");   
                returnList.add(temp);
            }
            stmt.close();            
        }
        catch(SQLException ex) 
        {
            System.out.println("ERROR SQLException safe.all_my_safes:=" + ex);
        }
        catch(Exception exc) 
        {
            System.out.println("ERROR Exception safe.all_my_safes:=" + exc);
	}
        return returnList;
    }
    
    
}

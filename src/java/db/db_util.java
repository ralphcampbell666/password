package db;

//import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author ralph
 */
public class db_util {
    public static Connection get_connection(HttpSession session)
    {
        
        Connection con = null;
        String db = session.getAttribute("db").toString();
        //String db = "D:/SQLite/test.db";         
        try {
            // db parameters
            String url = "jdbc:sqlite:" + db;
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
            con = DriverManager.getConnection(url);
        } 
        catch (SQLException e) 
        {
            System.out.println("Exception db_util.get_connection=" + e.getMessage());
        } 
        return con;
    }
    
}

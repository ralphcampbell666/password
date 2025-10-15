package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 *
 * @author ralph
 */
public class admin_group_edit extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        try
        {
            jakarta.servlet.http.HttpSession session = request.getSession();
            Connection con = db.db_util.get_connection(session);
            String id = request.getParameter("group_id");
            //Name
            String name = request.getParameter("name");
            //Description
            String description = request.getParameter("description");
            PreparedStatement stmt = con.prepareStatement("UPDATE groups SET `name`=?, `description`=? WHERE id=?");
            stmt.setString(1, name);
            stmt.setString(2, description);
            stmt.setString(3, id);
            stmt.execute();
            
            //delete current users
            stmt = con.prepareStatement("DELETE FROM user_group WHERE `group_id`=?");
            stmt.setString(1, id);
            stmt.execute();
            //get users assigned to group
            
            String user_ids[] = request.getParameterValues("user_ids");
            stmt = con.prepareStatement("INSERT INTO user_group (user_id,group_id) VALUES (?,?)");
            if(user_ids !=  null)
            {
                for(String user_id: user_ids)
                {
                    stmt.setString(1, user_id);
                    stmt.setString(2, id);                
                    stmt.execute();
                }
            }
            //get safes/permissions
            List safe_list = new ArrayList();
            Map params = request.getParameterMap();
            Iterator i = params.keySet().iterator();
            while (i.hasNext()) 
            {
                String key = (String) i.next();
                String value = ((String[]) params.get(key))[0];
                if (key.startsWith("safe_id-")) 
                {
                    //safe_id-1-create
                    String temp[] = key.split("-");
                    String safe_id = temp[1];
                    if (safe_list.contains(safe_id)) 
                    {
                        //dont add it
                    } 
                    else 
                    {
                        safe_list.add(safe_id);
                    }
                }
            } 
            //Delete first
            stmt = con.prepareStatement("DELETE FROM group_safe WHERE `group_id`=?");
            stmt.setString(1, id);
            stmt.execute();
            for(int a = 0; a < safe_list.size(); a++)
            {
                String safe_id = safe_list.get(a).toString();
                String group_id = id;
                int create = 0;
                int read = 0;
                int update = 0;
                int delete = 0;
                //get create
                try
                {
                    String create_value = request.getParameter("safe_id-" + safe_id + "-create");
                    if(create_value != null)
                    {
                        create = 1;
                    }
                }
                catch(Exception e)
                {
                    create = 0;
                }
                //read
                try
                {
                    String read_value = request.getParameter("safe_id-" + safe_id + "-read");
                    if(read_value != null)
                    {
                        read = 1;
                    }
                }
                catch(Exception e)
                {
                    read = 0;
                }
                //update
                try
                {
                    String update_value = request.getParameter("safe_id-" + safe_id + "-update");
                    if(update_value != null)
                    {
                        update = 1;
                    }
                }
                catch(Exception e)
                {
                    update = 0;
                }
                //delete
                try
                {
                    String delete_value = request.getParameter("safe_id-" + safe_id + "-delete");
                    if(delete_value != null)
                    {
                        delete = 1;
                    }
                }
                catch(Exception e)
                {
                    delete = 0;
                }
                //INSERT INTO group_safe (group_id,safe_id,create,read,update,delete) VALUES (?,?,?,?,?,?);
                stmt = con.prepareStatement("INSERT INTO group_safe (`group_id`,`safe_id`,`c`,`r`,`u`,`d`) VALUES (?,?,?,?,?,?)");
                stmt.setString(1, group_id);
                stmt.setString(2, safe_id);
                stmt.setInt(3, create);
                stmt.setInt(4, read);
                stmt.setInt(5, update);
                stmt.setInt(6, delete);
                stmt.execute();
            }
            con.close();
        }
        catch(Exception e)
        {
            System.out.println("Exception in admin_group_edit servlet=" + e);
        }
        String RedirectURL = "admin_groups.jsp";
        response.sendRedirect(RedirectURL);
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

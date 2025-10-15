package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 *
 * @author ralph
 */
public class safe_edit extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
        SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
        String safe_id = "-1";
        HttpSession session = request.getSession();
        if(session.getAttribute("authenticated")==null)
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else 
        {
            try 
            {
                Connection con = db.db_util.get_connection(session);
                safe_id = request.getParameter("safe_edit_id");
                String name = request.getParameter("safe_edit_name");
                String owner_id = request.getParameter("safe_edit_owner_id");
                String description = request.getParameter("safe_edit_description");
                PreparedStatement stmt = con.prepareStatement("UPDATE safes SET owner_id=?,name=?,description=? WHERE id=?");
                stmt.setString(1, owner_id);
                stmt.setString(2, name);
                stmt.setString(3, description);
                stmt.setString(4, safe_id);
                stmt.executeUpdate();                
                
                //clear existing relationships
                stmt = con.prepareStatement("DELETE FROM group_safe WHERE safe_id=?");
                stmt.setString(1, safe_id);
                stmt.executeUpdate();
                List group_list = new ArrayList();
                Map params = request.getParameterMap();
                Iterator i = params.keySet().iterator();
                while (i.hasNext()) 
                {
                    String param = (String) i.next();
                    if (param.startsWith("safe_edit_group_id-")) 
                    {
                        //group_id-1-create
                        String temp[] = param.split("-");
                        String group_id = temp[1];
                        if (group_list.contains(group_id)) 
                        {
                            //dont add it
                        } 
                        else 
                        {
                            group_list.add(group_id);
                        }
                    }
                } 
                for(int a = 0; a < group_list.size(); a++)
                {
                    String group_id = group_list.get(a).toString();
                    int create = 0;
                    int read = 0;
                    int update = 0;
                    int delete = 0;
                    //get create
                    try
                    {
                        String create_value = request.getParameter("safe_edit_group_id-" + group_id + "-create");
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
                        String read_value = request.getParameter("safe_edit_group_id-" + group_id + "-read");
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
                        String update_value = request.getParameter("safe_edit_group_id-" + group_id + "-update");
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
                        String delete_value = request.getParameter("safe_edit_group_id-" + group_id + "-delete");
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
                    con.close();
                }
            }
            catch(SQLException e)
            {
                System.out.println("Exception in safe_edit=" + e);
            } 
        }
        response.sendRedirect("safes.jsp?");
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

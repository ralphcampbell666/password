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
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 *
 * @author ralph
 */
public class safe_new extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
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
                int new_safe_id = db.safe.next_id(con);
                String name = request.getParameter("name");
                String owner_id = request.getParameter("owner_id");
                //Description
                String description = request.getParameter("description");
                PreparedStatement stmt = con.prepareStatement("INSERT INTO safes (id,owner_id,name,description) VALUES (?,?,?,?)");
                stmt.setInt(1, new_safe_id);
                stmt.setString(2, owner_id);
                stmt.setString(3, name);
                stmt.setString(4, description);
                stmt.execute();
                List group_list = new ArrayList();
                Map params = request.getParameterMap();
                Iterator i = params.keySet().iterator();
                while (i.hasNext()) 
                {
                    String key = (String) i.next();
                    if (key.startsWith("group_id-")) 
                    {
                        //group_id-1-create
                        String temp[] = key.split("-");
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
                        String create_value = request.getParameter("group_id-" + group_id + "-create");
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
                        String read_value = request.getParameter("group_id-" + group_id + "-read");
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
                        String update_value = request.getParameter("group_id-" + group_id + "-update");
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
                        String delete_value = request.getParameter("group_id-" + group_id + "-delete");
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
                    stmt.setInt(2, new_safe_id);
                    stmt.setInt(3, create);
                    stmt.setInt(4, read);
                    stmt.setInt(5, update);
                    stmt.setInt(6, delete);
                    stmt.execute();
                }
                con.close();
            }
            catch(IOException | SQLException e)
            {
                System.out.println("Exception in safe_new=" + e);
            } 
        }
        response.sendRedirect("safes.jsp");
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

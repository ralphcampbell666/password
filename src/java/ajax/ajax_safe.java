package ajax;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 *
 * @author ralph
 */
public class ajax_safe extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        boolean found_record = false;
        HttpSession session = request.getSession();
        PreparedStatement stmt;
        StringBuilder stringBuilder = new StringBuilder();
        StringBuilder table_stringBuilder = new StringBuilder();
        if(session.getAttribute("authenticated")==null)
        {
            String login_url = "index.jsp";
            response.sendRedirect(login_url);
        }
        else 
        {
            try 
            {
                String search = request.getParameter("search");
                response.setContentType("text/html;charset=UTF-8");
                Connection con = db.db_util.get_connection(session);   
                //System.out.println("ajax_safe 40 safe=" + search);
                ArrayList <String[]> groups = db.group.all_groups(con);
                ArrayList <String[]> group_permissions = db.safe.permissions_for_safe(con, search);
                for(String group[]: groups)
                {
                    String create = "";
                    String read = "";
                    String update = "";
                    String delete = "";
                    for(String group_permission[]: group_permissions)
                    {
                        if(group_permission[0].equalsIgnoreCase(group[0]))
                        {
                            if(group_permission[2].equalsIgnoreCase("1"))
                            {
                                create = "CHECKED";
                            }
                            if(group_permission[3].equalsIgnoreCase("1"))
                            {
                                read = "CHECKED";
                            }
                            if(group_permission[4].equalsIgnoreCase("1"))
                            {
                                update = "CHECKED";
                            }
                            if(group_permission[5].equalsIgnoreCase("1"))
                            {
                                delete = "CHECKED";
                            }
                        }
                    }
                    table_stringBuilder.append("<tr> ");
                    table_stringBuilder.append("<td>").append(group[1]).append("</td> ");
                    table_stringBuilder.append("<td>").append(group[2]).append("</td> ");
                    table_stringBuilder.append("<td nowrap>");
                    table_stringBuilder.append("<small>");
                    table_stringBuilder.append("Check&nbsp;");
                    table_stringBuilder.append("<a href='#' onclick='safe_edit_check_all(").append(group[0]).append(")'><smaller>All</smaller></a>&nbsp;|&nbsp;");
                    table_stringBuilder.append("<a href='#' onclick='safe_edit_uncheck_all(").append(group[0]).append(")\'><smaller>None</smaller></a>");
                    table_stringBuilder.append("</small>");
                    table_stringBuilder.append("</td>");
                    table_stringBuilder.append("<td align='center'><input ").append(create).append(" type='checkbox' class='form-check-input' id='safe_edit_group_id-").append(group[0]).append("-create' name='safe_edit_group_id-").append(group[0]).append("-create' value='create'></td>");
                    table_stringBuilder.append("<td align='center'><input ").append(read).append(" type='checkbox' class='form-check-input' id='safe_edit_group_id-").append(group[0]).append("-read' name='safe_edit_group_id-").append(group[0]).append("-read' value='read'></td>");
                    table_stringBuilder.append("<td align='center'><input ").append(update).append(" type='checkbox' class='form-check-input' id='safe_edit_group_id-").append(group[0]).append("-update' name='safe_edit_group_id-").append(group[0]).append("-update' value='update'></td>");
                    table_stringBuilder.append("<td align='center'><input ").append(delete).append(" type='checkbox' class='form-check-input' id='safe_edit_group_id-").append(group[0]).append("-delete' name='safe_edit_group_id-").append(group[0]).append("-delete' value='delete'></td>");
                    table_stringBuilder.append("</tr>");
                }
                stmt = con.prepareStatement("SELECT * FROM safes WHERE id=?");
                stmt.setString(1, search);
                ResultSet rs = stmt.executeQuery();                
                while(rs.next())
                {
                    stringBuilder.setLength(0);                    
                    found_record = true;
                    stringBuilder.append("{");
                    stringBuilder.append("\"id\": \"").append(rs.getString("id")).append("\",");
                    stringBuilder.append("\"owner_id\": \"").append(rs.getString("owner_id")).append("\",");
                    stringBuilder.append("\"name\": \"").append(rs.getString("name")).append("\",");
                    stringBuilder.append("\"description\": \"").append(rs.getString("description")).append("\",");
                    stringBuilder.append("\"group_permission_table\": \"").append(table_stringBuilder.toString()).append("\"");
                    stringBuilder.append("}");
                }                
                if(!found_record)
                {
                    stringBuilder.setLength(0);
                    stringBuilder.append("{");
                    stringBuilder.append("\"id\": \"-1\",");
                    stringBuilder.append("\"owner_id\": \"-1\",");
                    stringBuilder.append("\"name\": \"No Data\",");
                    stringBuilder.append("\"description\": \"No Data\",");
                    stringBuilder.append("\"group_permission_table\": \"N/A\"");
                    stringBuilder.append("}");
                }                
                con.close();
            }
            catch(SQLException e)
            {
                System.out.println("Exception in ajax_safe=" + e);
                stringBuilder.setLength(0);
                stringBuilder.append("{");
                stringBuilder.append("\"id\": \"null\",");
                stringBuilder.append("\"owner_id\": \"null\",");
                stringBuilder.append("\"name\": \"null\",");
                stringBuilder.append("\"description\": \"null\",");
                stringBuilder.append("\"group_permission_table\": \"null\"");
                stringBuilder.append("}");
            }
            PrintWriter out = response.getWriter();
            out.print(stringBuilder.toString());
        }
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

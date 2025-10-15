<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.util.ArrayList"%>

<%
String context_dir = request.getServletContext().getRealPath("");
//LinkedHashMap props = support.config.get_config(context_dir);
SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
//SimpleDateFormat display_format = new SimpleDateFormat("HH:mm / MM/dd/yyyy");//18:31 / 14-Jan-19
SimpleDateFormat date_time_picker_format = new SimpleDateFormat("HH:mm MM/dd/yyyy");//01:00 01/27/2020   
SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
Connection con = null;
boolean is_admin = false;
boolean safe_creator = false;
if(session.getAttribute("authenticated")==null)
{
    String login_url = "index.jsp";
    response.sendRedirect(login_url);
}
else 
{
    String session_username = "";
    String session_user_id = "";
    try
    {
        session_username = session.getAttribute("username").toString();
        session_user_id = session.getAttribute("user_id").toString();
    }
    catch(Exception e)
    {
        session_username = "";
    }  
    try
    {
        if(session.getAttribute("is_admin").toString().equalsIgnoreCase("1"))
        {
            is_admin = true;
        }
    }
    catch(Exception e)
    {
        is_admin = false;
    }
    try
    {
        if(session.getAttribute("safe_creator").toString().equalsIgnoreCase("1"))
        {
            safe_creator = true;
        }
    }
    catch(Exception e)
    {
        safe_creator = false;
    }
    
    if(is_admin)
    {
        try 
        {
            con = db.db_util.get_connection(session);
        }
        catch(Exception e)
        {
            System.out.println("Exception in admin_groups.jsp=" + e);
        }
%>
<!doctype html>
<html lang="en" class="h-100">
    <head>
        <jsp:include page='head.jsp'>
            <jsp:param name="menu" value="admin"/>
        </jsp:include> 
    </head>
    <body class="d-flex flex-column h-100">
        <header>
            <jsp:include page='header.jsp'>
                <jsp:param name="menu" value="admin"/>
            </jsp:include> 
        </header>

        <!-- Begin page content -->
        <main class="flex-shrink-0">
            <div class="container-fluid">
            <div class="row mb-5">
                <div class="col-12">&nbsp;</div>
            </div>
            <div class="row">
                <div class="col-12">
                    <div class="card mx-auto">
                        <div class="card-body">
                            <!-- Start Content-->
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item"><a href="admin.jsp"><i class="bi bi bi-gear-fill"></i>&nbsp;Admin</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-people-fill"></i>&nbsp;Groups</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    <div class="dropdown ms-auto">
                                        <i title="Group Menu" class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>&nbsp;Groups
                                        <ul class="dropdown-menu">
                                            <li>
                                                <%
                                                if(is_admin)
                                                {
                                                    %>
                                                    <span class="dropdown-item">
                                                        <a href="admin_group_new.jsp"><i class="bi bi-plus-square link-primary"></i>&nbsp;Add a Group</a>
                                                    </span>
                                                    <%
                                                }
                                                else
                                                {
                                                    %>
                                                    <span class="dropdown-item disabled">
                                                        <a href="#"><i class="bi bi bi-plus-square unknown"></i>&nbsp;Add a Group</a>
                                                    </span>
                                                    <%
                                                }

                                                %>
                                            </li>
                                        </ul>
                                    </div>  
                                </div>
                                <div class="card-body">
                                    <table id="group_safe" class="table table-striped" style="width:100%">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Description</th>
                                                <th>Users</th>
                                                <th>Safes</th>                                                
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                            ArrayList <String[]> groups = db.group.all_groups(con);
                                            for(String group[]: groups)
                                            {
                                                %>
                                                <tr>
                                                    <td>
                                                        <div class="dropdown ms-auto">
                                                            <i class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>&nbsp;<%=group[1]%>
                                                            <ul class="dropdown-menu">
                                                                <li>
                                                                    <span class="dropdown-item">
                                                                        <%
                                                                        if(is_admin)
                                                                        {
                                                                            %>
                                                                            <a title="Delete this Group" href="admin_group_delete?b=<%=group[0]%>" onclick="return confirm('Are you sure you want to delete this Group?');"><i style="cursor: pointer" onclick="window.location.href='admin_group_delete?group_id=<%=group[0]%>'" class="bi bi-trash3 critical"></i>&nbsp;Delete this Group</a>

                                                                            <%
                                                                        }
                                                                        else
                                                                        {
                                                                            %>
                                                                            <a title="Delete this Group" href="#"><i style="cursor: pointer" class="bi bi-trash3 unknown"></i></a>
                                                                            <%
                                                                        }
                                                                        %>
                                                                    </span>
                                                                </li>
                                                                <li>
                                                                    <span class="dropdown-item">
                                                                        <%
                                                                        if(is_admin)
                                                                        {
                                                                            %>
                                                                            <a title="Edit this Group" href="admin_group_edit.jsp?b=<%=group[0]%>"><i style="cursor: pointer" onclick="window.location.href='admin_group_edit?group_id=<%=group[0]%>'" class="bi bi-pencil-fill link-primary"></i>&nbsp;Edit this Group</a>

                                                                            <%
                                                                        }
                                                                        else
                                                                        {
                                                                            %>
                                                                            <a title="Edit this Group" href="#"><i style="cursor: pointer" class="bi bi-trash3 unknown"></i></a>
                                                                            <%
                                                                        }
                                                                        %>
                                                                    </span>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                        
                                                    </td>
                                                    <td><%=group[2]%></td>
                                                    <%
                                                    //GET USERS IN GROUP
                                                    ArrayList <String[]> u_in_g = db.user.all_users_in_group(con, group[0]);
                                                    String username_list = "";
                                                    String full_username_list = "";
                                                    for(String user[]: u_in_g)
                                                    {
                                                        if(username_list.equalsIgnoreCase(""))
                                                        {
                                                            username_list = username_list + user[1];
                                                        }
                                                        else
                                                        {
                                                            username_list = username_list + ", " + user[1];
                                                        }
                                                    }
                                                    full_username_list = username_list;
                                                    if(username_list.length() > 30)
                                                    {
                                                        username_list = username_list.substring(0, 29) + " ...more";
                                                    }
                                                    %>
                                                    <td title="<%=full_username_list%>"><%=username_list%></td>
                                                    <%
                                                    //Get safes the group has access to
                                                    ArrayList <String[]> safes = db.safe.safe_name_by_group(con, group[0]);
                                                    String safe_list = "";
                                                    String full_safe_list = "";
                                                    for(String safe[]: safes)
                                                    {
                                                        if(safe_list.equalsIgnoreCase(""))
                                                        {
                                                            safe_list = safe_list + safe[2];
                                                        }
                                                        else
                                                        {
                                                            safe_list = safe_list + ", " + safe[2];
                                                        }
                                                    }
                                                    full_safe_list = safe_list;
                                                    if(safe_list.length() > 30)
                                                    {
                                                        safe_list = safe_list.substring(0, 29) + " ...more";
                                                    }
                                                    %>
                                                    <td title="<%=full_safe_list%>"><%=safe_list%></td>                                                    
                                                </tr>
                                                <%
                                            }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <!--End Content-->
                        </div>
                    </div>
                </div>
            </div>
            <div class="row mb-3"><div class="col-md-12">&nbsp;</div></div>
        </div>
        </main>
        <jsp:include page='footer.jsp'>
            <jsp:param name="page_type" value="admin"/>
        </jsp:include>
        <!-- Bootstrap core JS-->
        <script src="js/bootstrap.bundle.min.js"></script>
        <!-- Core theme JS-->
        <script src="js/scripts.js"></script>
        <script src="js/jquery-3.7.1.min.js"></script>      
        <script>
            function open_edit_group(id){
                window.location.href = "group_edit.jsp?id=" + id;
            }            
        </script>
    </body>
</html>
 <%
        con.close();
    }
    else
    {
        response.sendRedirect("not_authorized.jsp");
    }
}
%>

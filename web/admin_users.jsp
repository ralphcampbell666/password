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
            System.out.println("Exception in admin_users.jsp=" + e);
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
                                    <li class="breadcrumb-item" aria-current="page"><a href="safes.jsp"><i class="bi bi-safe-fill"></i>&nbsp;Safes</a></li>
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin.jsp"><i class="bi bi-gear-fill"></i>&nbsp;Admin</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-person-fill"></i>&nbsp;Users</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    <div class="dropdown ms-auto">
                                        <i title="User Menu" class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                        <ul class="dropdown-menu">
                                            <li><a class="dropdown-item" href="admin_user_new.jsp"><i style="cursor: pointer" class="bi bi bi-plus-square link-primary"></i>&nbsp;Add a User</a></li>
                                        </ul>
                                        Users
                                    </div>
                                </div>
                                <div class="card-body">
                                    <table id="user_table" class="table table-striped" style="width:100%">
                                        <thead>
                                            <tr>
                                                <th>Username</th>
                                                <th>First</th>
                                                <th>Last</th>
                                                <th>Email</th>
                                                <th>Is Admin</th>
                                                <th>Safe Creator</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                            ArrayList <String[]> all_users = db.user.all_users(con);
                                            for(String[] user: all_users)
                                            {
                                            %>
                                            <tr>
                                                <td>
                                                    <div class="dropdown ms-auto">
                                                        <i class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <span class="dropdown-item">
                                                                    <%
                                                                    if(user[0].equalsIgnoreCase("0"))
                                                                    {
                                                                        %>
                                                                        <a href="#"><i style="cursor: not-allowed" class="bi bi-x-lg unknown"></i>&nbsp;Delete User</a>
                                                                        <%
                                                                    }
                                                                    else
                                                                    {
                                                                        %>
                                                                        <a href="admin_user_delete?user_id=<%=user[0]%>" onclick="javascript:return confirm('Are you sure you want to delete this User?');"><i style="cursor: pointer" class="bi bi-x-lg critical"></i>&nbsp;Delete User</a>
                                                                        <%
                                                                    }
                                                                    %>
                                                                </span>
                                                            </li>
                                                            <li>
                                                                <span class="dropdown-item">
                                                                    <a href="admin_user_edit.jsp?id=<%=user[0]%>"><i style="cursor: pointer" class="bi bi-pencil-fill link-primary"></i>&nbsp;Edit User</a>
                                                                </span>
                                                            </li>
                                                        </ul>
                                                        &nbsp;<%=user[1]%>
                                                    </div>
                                                    
                                                    </td>
                                                <td><%=user[1]%></td>
                                                <td><%=user[3]%></td>
                                                <td><%=user[5]%></td>
                                                <td><%
                                                    if(user[15].toString().equalsIgnoreCase("1"))
                                                    {
                                                        %><input CHECKED disabled="disabled" type="checkbox" class="form-check-input"><%
                                                    }
                                                    else
                                                    {
                                                        %><input disabled="disabled" type="checkbox" class="form-check-input"><%
                                                    }                                                
                                                    %>
                                                </td>
                                                <td><%
                                                    if(user[16].toString().equalsIgnoreCase("1"))
                                                    {
                                                        %><input CHECKED disabled="disabled" type="checkbox" class="form-check-input"><%
                                                    }
                                                    else
                                                    {
                                                        %><input disabled="disabled" type="checkbox" class="form-check-input"><%
                                                    }                                                
                                                    %>
                                                </td>
                                            </tr>
                                            <%
                                            }
                                            %>
                                            
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <th>Username</th>
                                                <th>First</th>
                                                <th>Last</th>
                                                <th>Email</th>
                                                <th>Is Admin</th>
                                                <th>Safe Creator</th>
                                            </tr>
                                        </tfoot>
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
        <script src="js/datatables.min.js"></script>
        <script>
            new DataTable('#user_table');
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
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
            System.out.println("Exception in admin_safes.jsp=" + e);
        }
    
        String system_key = session.getAttribute("system_key").toString();
        String system_salt = session.getAttribute("system_salt").toString();
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
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-safe-fill"></i>&nbsp;Safe Admin</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    <div class="dropdown ms-auto">
                                        <i title="Main Safe Menu" class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <span class="dropdown-item ">
                                                    <a href="admin_safe_new.jsp"><i style="cursor: pointer" class="bi bi bi-plus-square link-primary"></i>&nbsp;Add a Safe</a>
                                                </span>
                                            </li>
                                        </ul>
                                        Safes
                                    </div>  
                                    
                                </div>
                                <div class="card-body">
                                    <table id="table" class="table table-striped" style="width:100%">
                                        <thead>
                                            <tr>
                                                <th>Name</th>
                                                <th>Description</th>
                                                <th>Owner</th>
                                                <th><center>Number of Passwords</center></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                
                                            ArrayList <String[]> safes = db.safe.all_safes(con);
                                            for(String[] safe: safes)
                                            {
                                                String safe_name = safe[2];
                                                String safe_dscription = safe[3];
                                                String owner_info[] = db.user.info(con, safe[1]);
                                                String owners_username = owner_info[1];
                                                String number_of_passwords_in_safe = db.password.password_count_in_safe_id(con, safe[0]);
                                            %>
                                            <tr>
                                                <td NOWRAP>
                                                    <div class="dropdown ms-auto">
                                                        <i class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <span class="dropdown-item">
                                                                   <a title="Delete this Safe" href="admin_safe_delete.jsp?b=<%=safe[0]%>"><i style="cursor: pointer" class="bi bi-trash3 critical"></i>&nbsp;Delete</a>
                                                                </span>
                                                            </li>
                                                            <li>
                                                                <span class="dropdown-item">
                                                                  <a title="Update this Password" href="admin_safe_edit.jsp?b=<%=safe[0]%>"><i style="cursor: pointer" class="bi bi-pencil-fill link-primary"></i>&nbsp;Edit</a>
                                                                </span>
                                                            </li>
                                                        </ul>
                                                        &nbsp;<%=safe_name%>
                                                    </div>
                                                </td>
                                                <td><%=safe_dscription%></td>
                                                <td><%=owners_username%></td>
                                                <td align="center"><%=number_of_passwords_in_safe%>
                                                
                                            </tr>
                                            <%
                                            }
                                            %>
                                            
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <th>Name</th>
                                                <th>Description</th>
                                                <th>Owner</th>
                                                <th><center>Number of Passwords</center></th>
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
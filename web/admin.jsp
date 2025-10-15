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
            System.out.println("Exception in admin.jsp=" + e);
        }
        ArrayList <String[]> safes = db.safe.all_safes(con);
        ArrayList <String[]> users = db.user.all_users(con);
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
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-gear-fill"></i>&nbsp;Admin</li>
                                </ol>
                            </nav>
                            <div class="row ">
                                <div class="mb-3 col-xl-3 col-lg-6 col-md-6 col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            Users/Groups
                                        </div>
                                        <div class="card-body">
                                            <a href="admin_users.jsp"><i class="bi bi-person-fill"></i>&nbsp;Manage Users</a>
                                            <br>
                                            <a href="admin_groups.jsp"><i class="bi bi-people-fill"></i>&nbsp;Manage Groups</a>
                                        </div>
                                    </div>
                                </div>
                                <div class="mb-3 col-xl-3 col-lg-6 col-md-6 col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            Safes
                                        </div>
                                        <div class="card-body">
                                            <a href="admin_safes.jsp"><i class="bi bi-safe-fill"></i>&nbsp;Manage Safes</a>
                                            <br>&nbsp;
                                        </div>
                                    </div>
                                </div>
                                <div class="mb-3 col-xl-3 col-lg-6 col-md-6 col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            Passwords
                                        </div>
                                        <div class="card-body">
                                            <a href="admin_passwords.jsp"><i class="bi bi-key-fill"></i>&nbsp;Manage Passwords</a>
                                            <br>&nbsp;
                                        </div>
                                    </div>
                                </div>
                                <div class="mb-3 col-xl-3 col-lg-6 col-md-6 col-sm-12">
                                    <div class="card">
                                        <div class="card-header">
                                            Data Management
                                        </div>
                                        <div class="card-body">
                                            <a href="admin_backup_database.jsp"><i class="bi bi-database-down"></i>&nbsp;Backup Database</a>
                                            <br>
                                            <a href="admin_restore_database.jsp"><i class="bi bi-database-up"></i>&nbsp;Restore Database</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!--End Content-->
                        </div>
                    </div>
                </div>
            </div>            
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
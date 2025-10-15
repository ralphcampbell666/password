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
        con = db.db_util.get_connection(session);
    }
    catch(Exception e)
    {
        System.out.println("Exception in admin_password_new.jsp=" + e);
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
    try 
    {
        con = db.db_util.get_connection(session);
    }
    catch(Exception e)
    {
        System.out.println("Exception in home.jsp=" + e);
    }
    if(is_admin || safe_creator)
    {
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
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin.jsp"><i class="bi bi-gear-fill"></i>&nbsp;Admin</a></li>
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin_safes.jsp"><i class="bi bi-key-fill"></i>&nbsp;Password</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-key"></i>&nbsp;Add Password</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    This is the title
                                </div>
                                <form action="admin_safe_password_new" name="in_form" method="POST" onsubmit="return check_form()">
                                    <div class="card-body">                                        
                                        <div class="row mb-3">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="name" class="form-label">Name*</label>
                                                <input type="text" id="name" name="name" class="form-control"/>
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="description" class="form-label">Description*</label>
                                                <input type="text" id="description" name="description" class="form-control"/>
                                            </div>
                                            
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="password" class="form-label">Password*</label>
                                                <div class="input-group">
                                                    <input type="password" name="password" id="password" class="form-control"/>
                                                    <span class="input-group-text"><i onclick="toggle_password('password')" style="cursor: pointer" class="bi bi-eye "></i></span>
                                                </div>
                                            </div>
                                            
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="safe_id" class="form-label">Safe</label>
                                                <select class="form-select" name="safe_id" id="safe_id">
                                                <%
                                                
                                                %>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="expires" class="form-label">Expires</label>
                                                <input type="datetime-local" id="expires" name="expires" class="form-control" value=""/>
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="created" class="form-label">Created</label>
                                                <input type="datetime-local" id="created" name="created" class="form-control" value=""/>
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="password" class="form-label">Creator*</label>
                                                <select class="form-select" name="creator_user_id" id="creator_user_id">
                                                <%
                                                
                                                %>
                                                </select>
                                            </div>
                                        </div>
                                        <button type="submit" class="btn btn-primary">Save changes</button>                                        
                                    </div>
                                </form>
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
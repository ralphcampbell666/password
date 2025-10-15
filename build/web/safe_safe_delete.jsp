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
            System.out.println("Exception in admin_safe_delete.jsp=" + e);
        }
    
        String safe_id = request.getParameter("b");
        String safe_name = "";
        String safe_description = "";
        int number_of_passwords = 0;
        ArrayList <String[]> passwords = db.password.safe_and_passwords_for_safe_id(con, safe_id, session);
        for(String[] password: passwords)
        {
            safe_name = password[2];
            safe_description = password[3];
            number_of_passwords = passwords.size();
            break;
        }
        ArrayList <String[]> all_safes = db .safe.all_safes(con);
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
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-safe"></i>&nbsp;Delete Safe</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    Deleting Safe <%=safe_name%> 
                                </div>
                                <div class="card-body">
                                    <form action="safe_safe_delete" method="post">
                                        <input type="hidden" name="safe_id" id="safe_id" value="<%=safe_id%>"/>
                                    <%
                                    if(passwords.size() != 0)
                                    {
                                        %>
                                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                            <h5>This Safe contains Passwords!</h5>
                                            <!--<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>-->
                                            <div class="row">
                                                <div class="col-12">
                                                    What to do with these Passwords?
                                                    <br>&nbsp;
                                                    <input class="form-check-input" type="radio" id="password_action_orphan" name="password_action" value="password_action_orphan" checked/>
                                                    <label for="password_action_orphan">Orphan these Passwords and Assign them to another Safe later.</label>
                                                    <br>&nbsp;
                                                    <input class="form-check-input" type="radio" id="password_action_delete" name="password_action" value="password_action_delete" />
                                                    <label for="password_action_orphan">Delete these Password</label>
                                                    <br>&nbsp;
                                                    <input class="form-check-input" type="radio" id="password_action_move" name="password_action" value="password_action_move" />
                                                    <label for="password_action_orphan">Move these Passwords to another Safe.</label>
                                                    <select name="move_to_safe" id="move_to_safe" aria-label="move_to_safe">
                                                        <%
                                                        for(String[] safe: all_safes)
                                                        {
                                                            if(!safe[0].equalsIgnoreCase(safe_id))
                                                            {
                                                            %>
                                                            <option value="<%=safe[0]%>"><%=safe[2]%></option>
                                                            <%
                                                            }
                                                        }
                                                        %>
                                                    </select>
                                                    <br>&nbsp;
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div style="background-color: whitesmoke;" class="col-12 ">
                                                    <table id="password_table" class="table table-striped" style="width:100%">
                                                        <thead>
                                                            <tr>
                                                                <th>Name</th>
                                                                <th>Description</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <%
                                                            for(String[] password: passwords)
                                                            {
                                                                String password_name = password[6];
                                                                String password_dscription = password[7];
                                                            %>
                                                            <tr>
                                                                <td><%=password_name%></td>
                                                                <td><%=password_dscription%></td>                                               
                                                            </tr>
                                                            <%
                                                            }
                                                            %>

                                                        </tbody>
                                                        <tfoot>
                                                            <tr>
                                                                <th>Name</th>
                                                                <th>Description</th>
                                                            </tr>
                                                        </tfoot>
                                                    </table>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="d-grid gap-2 d-md-block">
                                                    <br>&nbsp;
                                                    <button class="btn btn-primary" type="submit">Delete Safe</button>
                                                    <button class="btn btn-secondary" onclick="location.href='admin_safes.jsp';" type="button">Cancel</button>
                                                </div>
                                            </div>
                                                            
                                        </div>
                                    </form>
                                        <%
                                    }
                                    else
                                    {
                                        %>
                                        <form action="admin_safe_delete" method="post">
                                            <input type="hidden" name="safe_id" id="safe_id" value="<%=safe_id%>"/>
                                            <div class="row">
                                                <div class="col-12">
                                                    Safe is empty.
                                                    <br>&nbsp;
                                                </div>
                                            </div>
                                            <button class="btn btn-primary" type="submit">Delete Safe</button>
                                            <button class="btn btn-secondary" onclick="location.href='admin_safes.jsp';" type="button">Cancel</button>
                                        </form>
                                        <%
                                    }
                                    %>
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
            new DataTable('#password_table');
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

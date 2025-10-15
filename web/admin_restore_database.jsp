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
    try 
    {
        con = db.db_util.get_connection(session);
    }
    catch(Exception e)
    {
        System.out.println("Exception in home.jsp=" + e);
    }
    if(is_admin)
    {
        try 
        {
            con = db.db_util.get_connection(session);
        }
        catch(Exception e)
        {
            System.out.println("Exception in admin_restore_database.jsp=" + e);
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
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-database-up"></i>&nbsp;Database Restore</li>
                                </ol>
                            </nav>
                            <div class="row ">
                                <div class="mb-3 col-12">
                                    <div class="card">
                                        <div class="card-header">
                                            Restore Options
                                        </div>
                                        <div class="card-body">
                                            <%
                                            
                                            try
                                            {
                                                String results = session.getAttribute("admin_restore_database").toString();
                                                if(results == null)
                                                {
                                                    //do nothing 
                                                }
                                                else
                                                {
                                                    //"~EnDoFlInE~FAIL,Number of User records in backup file=" + number_of_records + "<br> Number of User records restored=" + records_restored;
                                                    boolean success = false;
                                                    String success_text = "";
                                                    boolean fail = false;
                                                    String fail_text = "";
                                                    String result_array[] = results.split("~EnDoFlInE~");
                                                    for(int a = 0; a < result_array.length; a++)
                                                    {
                                                        String split_line[] = result_array[a].split(",");
                                                        if(split_line[0].equalsIgnoreCase("FAIL"))
                                                        {
                                                            fail = true;
                                                            if(fail_text.equalsIgnoreCase(""))
                                                            {
                                                                fail_text = split_line[1]; 
                                                            }
                                                            else
                                                            {
                                                                fail_text = fail_text + "<br>" + split_line[1]; 
                                                            }
                                                        }
                                                        else if(split_line[0].equalsIgnoreCase("SUCCESS"))
                                                        {
                                                            success = true;
                                                            if(success_text.equalsIgnoreCase(""))
                                                            {
                                                                success_text = split_line[1]; 
                                                            }
                                                            else
                                                            {
                                                                success_text = success_text + "<br>" + split_line[1]; 
                                                            }
                                                        }                                                        
                                                    }
                                                    //show alerts
                                                    if(success)
                                                    {
                                                        %>
                                                        <div class="alert alert-success alert-dismissible" role="alert">
                                                            <h4>Restore Status</h4><br><%=success_text%>
                                                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                                        </div>
                                                        
                                                        <%
                                                    }
                                                    if(fail)
                                                    {
                                                        %>
                                                        <div class="alert alert-danger alert-dismissible" role="alert">
                                                            <h4>Restore Status</h4><br><%=fail_text%>
                                                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                                        </div>                                                        
                                                        <%
                                                    }
                                                }
                                            }
                                            catch(Exception e)
                                            {
                                                
                                            }
                                            //clear the results
                                            session.removeAttribute("admin_restore_database");
                                            %>
                                            <form action="admin_restore_database" name="backup" enctype="multipart/form-data" method="POST"">
                                                <div class="row mb-3">
                                                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                        
                                                    </div>
                                                </div>
                                                
                                                <div class="row mb-3">
                                                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                        <label class="form-label" for="customFile">File to Restore</label>
                                                        <input type="file" class="form-control" name="restore_file" id="restore_file"/>
                                                    </div>
                                                </div>
                                                <!--<div class="row mb-3">
                                                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                        Is this backup file "Encrypted"
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="backup_encrypt" id="backup_encrypt" value="encrypted" checked="true">
                                                            <label class="form-check-label" for="backup_encrypt">
                                                                Encrypted
                                                            </label>
                                                        </div>
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="backup_encrypt" id="backup_encrypt" value="unencrypted">
                                                            <label class="form-check-label" for="backup_encrypt">
                                                                Unencrypted
                                                            </label>
                                                        </div>
                                                    </div>   
                                                </div>-->
                                                <div class="row mb-3">
                                                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                        Restore Options
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-12">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="restore_option" id="restore_option" value="delete" checked="true">
                                                            <label class="form-check-label" for="restore_option">
                                                                Delete all existing data and restore everything including the Users. Do you know the old "admin" password? If not, make sure to set the "admin" password immediately after the restore.
                                                            </label>
                                                        </div>
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="restore_option" id="restore_option" value="keep">
                                                            <label class="form-check-label" for="backup_encrypt">
                                                                Keep all existing data and restore only password. All restored Passwords will be "Orphaned" and need to be assigned to a Safe.
                                                            </label>
                                                        </div>
                                                    </div>   
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-12">
                                                        <button type="submit" class="btn btn-primary">Restore</button>  
                                                    </div>
                                                </div> 
                                            </form>
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
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.util.ArrayList"%>

<%
String context_dir = request.getServletContext().getRealPath("");
//LinkedHashMap props = support.config.get_config(context_dir);
SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
SimpleDateFormat jquery_datetime_picker_format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");//MM-dd-YYYY hh:mm a
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
            System.out.println("Exception in admin_password_history.jsp=" + e);
        }  
    
        String system_key = session.getAttribute("system_key").toString();
        String system_salt = session.getAttribute("system_salt").toString();   
        ArrayList <String[]> users = db.user.all_users(con);
        ArrayList <String[]> safes = db.safe.all_safes(con);
        String password_id = request.getParameter("b");
        String password_info[] = db.password.password_info_decrypted(con, password_id, session);
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
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin_passwords.jsp"><i class="bi bi-key-fill"></i>&nbsp;Password Admin</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-clock-history"></i>&nbsp;Password History</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    <div class="dropdown">
                                        Password history for Password named: <b><em><%=password_info[2]%></em></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        <button class="btn btn-sm btn-primary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            Password actions
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a class="dropdown-item" href="#" onclick="open_add_modal();">Add a Password</a></li>
                                        </ul>
                                    </div> 
                                </div>
                                <div class="card-body">
                                    <table id="table" class="table table-striped" style="width:100%">
                                        <thead>
                                            <tr>
                                                <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date Changed</th>
                                                <th>Action</th>
                                                <th>Changed By</th>
                                                <th>Name</th>
                                                <th>Description</th>
                                                <th>Password</th>
                                                <th>Expires</th>
                                                <th>Created</th>                                               
                                                <th>Safe</th>
                                                <th>Creator</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%                                                
                                            ArrayList <String[]> past_passwords = db.password.get_password_history(con, session, password_id);
                                            for(String[] password: past_passwords)
                                            {
                                                String this_id = password[0];
                                                String this_changed_by_user_id = password[1];
                                                String this_action = password[2];
                                                String this_date_changed = password[3];
                                                String this_password_id = password[4];
                                                String this_safe_id = password[5];
                                                String this_name = password[6];
                                                String this_description = password[7];
                                                String this_password = password[8];
                                                String this_expires_on = password[9];
                                                String this_date_created = password[10];
                                                String this_creator_user_id = password[11];
                                                String this_changed_by_username = password[12];
                                                String this_creator_useruser = password[13];
                                                String this_safe_name = password[14];
                                                
                                                this_date_changed = "";
                                                try
                                                {
                                                    java.util.Date date = timestamp_format.parse(password[3]);
                                                    this_date_changed = jquery_datetime_picker_format.format(date);
                                                }
                                                catch(Exception e)
                                                {
                                                    this_date_changed = "";
                                                }
                                                this_expires_on = "";
                                                try
                                                {
                                                    java.util.Date date = timestamp_format.parse(password[9]);
                                                    this_expires_on = jquery_datetime_picker_format.format(date);
                                                }
                                                catch(Exception e)
                                                {
                                                    this_expires_on = "";
                                                }
                                                this_date_created = "";
                                                try
                                                {
                                                    java.util.Date date = timestamp_format.parse(password[10]);
                                                    this_date_created = jquery_datetime_picker_format.format(date);
                                                }
                                                catch(Exception e)
                                                {
                                                    this_date_created = "";
                                                }
                                                
                                                
                                            %>
                                            <tr>
                                                <td NOWRAP>
                                                    <a title="Replace the existing Password with this version?" href="admin_password_restore?b=<%=this_id%>" onclick="return confirm('Are you sure you want to Restore this item?');"><i style="cursor: pointer" class="bi bi-arrow-counterclockwise link-primary"></i></a>
                                                    &nbsp;<%=this_date_changed%>
                                                </td>
                                                <td><%=this_action%></td>
                                                <td><%=this_changed_by_username%></td>
                                                <td><%=this_name%></td>
                                                <td><%=this_description%></td>
                                                <td><%=this_password%></td>
                                                <td><%=this_expires_on%></td>
                                                <td><%=this_date_created%></td>
                                                <td><%=this_safe_name%></td>
                                                <td><%=this_creator_useruser%></td>
                                            </tr>
                                            <%
                                            }
                                            %>
                                            
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <th>&nbsp;&nbsp;&nbsp;&nbsp;Date Changed</th>
                                                <th>Action</th>
                                                <th>Changed By</th>
                                                <th>Name</th>
                                                <th>Description</th>
                                                <th>Password</th>
                                                <th>Expires</th>
                                                <th>Created</th>                                               
                                                <th>Safe</th>
                                                <th>Creator</th>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>
                            </div>
                            <!-- Modal -->
                            <div class="modal fade" id="add_modal" tabindex="-1" aria-labelledby="add_modal_label" aria-hidden="true">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="edit_modal_label">Add Password</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form action="admin_new_password" name="add_form" method="POST" onsubmit="return add_check_form()">
                                                <div class="card-body">                                        
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_name" class="form-label">Name*</label>
                                                            <input type="text" id="add_name" name="add_name" class="form-control"/>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_description" class="form-label">Description*</label>
                                                            <input type="text" id="add_description" name="add_description" class="form-control"/>
                                                        </div>

                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_password" class="form-label">Password*</label>
                                                            <div class="input-group">
                                                                <input type="password" name="add_password" id="add_password" class="form-control"/>
                                                                <span class="input-group-text"><i onclick="toggle_password('add_password')" style="cursor: pointer" class="bi bi-eye "></i></span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_expires" class="form-label">Expires</label>
                                                            <input type="datetime-local" id="add_expires" name="add_expires" class="form-control" value=""/>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_created" class="form-label">Created</label>
                                                            <input type="datetime-local" id="add_created" name="add_created" class="form-control" value=""/>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_creator_user_id" class="form-label">Creator*</label>
                                                            <select class="form-select" name="add_creator_user_id" id="add_creator_user_id">
                                                            <%
                                                            for(String[] user: users)
                                                            {
                                                                String selected = "";
                                                                if(user[0].equalsIgnoreCase(session_user_id))
                                                                {
                                                                    selected = "SELECTED";
                                                                }
                                                                %>
                                                                <option <%=selected%> value="<%=user[0]%>"><%=user[1]%></option>
                                                                <%
                                                            }
                                                            %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_safe_id" class="form-label">Creator*</label>
                                                            <select class="form-select" name="add_safe_id" id="add_safe_id">
                                                            <%
                                                            for(String[] safe: safes)
                                                            {
                                                                String selected = "";
                                                                %>
                                                                <option <%=selected%> value="<%=safe[0]%>"><%=safe[2]%></option>
                                                                <%
                                                            }
                                                            %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <button type="submit" class="btn btn-primary">Save changes</button>  
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                
                                                <script>
                                                    function add_check_form()
                                                    {
                                                        var caller_id = document.forms["edit_in_form"]["edit-caller_id"].value;
                                                        var description = document.forms["edit_in_form"]["edit-description"].value;
                                                        if (caller_id === "" || description === "" )
                                                        {
                                                            $('#edit_incident_warning-alert-modal').modal('show');//;
                                                            return false;
                                                        } 
                                                        else
                                                        {
                                                            return true;
                                                        }
                                                    }
                                                </script>
                                            </form>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>    
                                    </div>
                                </div>
                            </div>
                            <!-- Modal -->
                            <div class="modal fade" id="edit_modal" tabindex="-1" aria-labelledby="edit_modal_label" aria-hidden="true">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="edit_modal_label">Edit Password</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form action="admin_edit_password" name="edit_form" method="POST" onsubmit="return check_form()">
                                                <input type="hidden" id="edit_id" name="edit_id" value=""/>  
                                                <div class="card-body">                                        
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_name" class="form-label">Name*</label>
                                                            <input type="text" id="edit_name" name="edit_name" class="form-control"/>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_description" class="form-label">Description*</label>
                                                            <input type="text" id="edit_description" name="edit_description" class="form-control"/>
                                                        </div>

                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_password" class="form-label">Password*</label>
                                                            <div class="input-group">
                                                                <input type="password" name="edit_password" id="edit_password" class="form-control"/>
                                                                <span class="input-group-text"><i onclick="toggle_password('edit_password')" style="cursor: pointer" class="bi bi-eye "></i></span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_expires" class="form-label">Expires</label>
                                                            <input type="datetime-local" id="edit_expires" name="edit_expires" class="form-control" value=""/>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_created" class="form-label">Created</label>
                                                            <input type="datetime-local" id="edit_created" name="edit_created" class="form-control" value=""/>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_creator_user_id" class="form-label">Creator*</label>
                                                            <select class="form-select" name="edit_creator_user_id" id="edit_creator_user_id">
                                                            <%
                                                            for(String[] user: users)
                                                            {
                                                                String selected = "";
                                                                if(user[0].equalsIgnoreCase(session_user_id))
                                                                {
                                                                    selected = "SELECTED";
                                                                }
                                                                %>
                                                                <option <%=selected%> value="<%=user[0]%>"><%=user[1]%></option>
                                                                <%
                                                            }
                                                            %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_safe_id" class="form-label">Creator*</label>
                                                            <select class="form-select" name="edit_safe_id" id="edit_safe_id">
                                                            <%
                                                            for(String[] safe: safes)
                                                            {
                                                                %>
                                                                <option value="<%=safe[0]%>"><%=safe[2]%></option>
                                                                <%
                                                            }
                                                            %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <button type="submit" class="btn btn-primary">Save changes</button>  
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                
                                                <script>
                                                    function validateEditForm()
                                                    {
                                                        var caller_id = document.forms["edit_in_form"]["edit-caller_id"].value;
                                                        var description = document.forms["edit_in_form"]["edit-description"].value;
                                                        if (caller_id === "" || description === "" )
                                                        {
                                                            $('#edit_incident_warning-alert-modal').modal('show');//;
                                                            return false;
                                                        } 
                                                        else
                                                        {
                                                            return true;
                                                        }
                                                    }
                                                </script>
                                            </form>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>    
                                    </div>
                                        
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
            function open_add_modal(id)
            {
                //alert("start open_edit_modal id=" + id);
                //var user_tz_name = document.getElementById('user_tz_name').value;                
                //alert("start");
               
                $('#add_modal').modal('show');
            }                
        </script>
        <script>  
            function open_edit_modal(id)
            {
                // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
                $.ajax({
                    url: 'ajax_password?search=' + id,
                    method: 'GET',
                    dataType: 'json',
                    data: {
                        search: id
                    },
                    success: function (responseText)
                    {
                        $('#edit_id').val(id); //edit_id
                        $('#edit_name').val(responseText.name); //edit_name
                        $('#edit_description').val(responseText.description); //edit_description
                        $('#edit_password').val(responseText.password); //edit_password
                        $('#edit_expires').val(responseText.expires_on); //edit_expires
                        $('#edit_created').val(responseText.date_created); //edit_created
                        $('#edit_creator_user_id').val(responseText.creator_user_id); //edit_creator_user_id    
                        $('#edit_safe_id').val(responseText.safe_id); //edit_safe_id    
                    }
                });                
                $('#edit_modal').modal('show');
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
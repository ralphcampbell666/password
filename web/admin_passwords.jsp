<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.time.LocalTime"%>
<%@ page import="java.util.GregorianCalendar"%>

<%
String context_dir = request.getServletContext().getRealPath("");
//LinkedHashMap props = support.config.get_config(context_dir);
SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
//SimpleDateFormat display_format = new SimpleDateFormat("HH:mm / MM/dd/yyyy");//18:31 / 14-Jan-19
//SimpleDateFormat date_time_picker_format = new SimpleDateFormat("HH:mm MM/dd/yyyy");//01:00 01/27/2020   
//SimpleDateFormat default_picker_format = new SimpleDateFormat("yyyy-MM-dd HH:mm");//MM-dd-YYYY hh:mm a
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
            System.out.println("Exception in admin_passwords.jsp=" + e);
        }
    
        String system_key = session.getAttribute("system_key").toString();
        String system_salt = session.getAttribute("system_salt").toString();   
        ArrayList <String[]> users = db.user.all_users(con);
        ArrayList <String[]> safes = db.safe.all_safes(con);
        String password_list_filter = request.getParameter("q");
        if(password_list_filter == null )
        {
            password_list_filter = "All";
        }
        else if(password_list_filter == "All" || password_list_filter.equalsIgnoreCase("all"))
        {
            password_list_filter = "All";
        }
        else if(password_list_filter == "Orphaned" || password_list_filter.equalsIgnoreCase("orphaned"))
        {
            password_list_filter = "Orphaned";
        }
        else if(password_list_filter == "Expired" || password_list_filter.equalsIgnoreCase("expired"))
        {
            password_list_filter = "Expired";
        }
        ArrayList <String[]> passwords = db.password.all_passwords_with_safe_name_filtered(con, session, password_list_filter);
%>
<!doctype html>
<html lang="en" class="h-100">
    <head>
        <jsp:include page='head.jsp'>
            <jsp:param name="menu" value="admin"/>
        </jsp:include> 
        <link href="css/jquery.datetimepicker.2.5.20.css" rel="stylesheet" />
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
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-key-fill"></i>&nbsp;Password Admin</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    <div class="dropdown ms-auto">
                                        <i class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <span class="dropdown-item">
                                                    <a title="Add Password" href="#" onclick="open_add_modal();"><i style="cursor: pointer" class="bi bi-plus-square link-primary"></i>&nbsp;Add a Password</a>
                                                </span>
                                            </li>
                                            <li>
                                                <span class="dropdown-item">
                                                    <a title="Update this Password" href="admin_password_undelete.jsp"><i style="cursor: pointer" class="bi bi-heart-pulse link-primary"></i>&nbsp;Undelete a Password</a>
                                                </span>
                                            </li>
                                        </ul>
                                        &nbsp;All Passwords
                                    </div>                                   
                                </div>
                                <div class="card-body">
                                    <div class="dropdown">    
                                        <button class="btn btn-sm btn-primary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            Filters: <small> Current Filter: "<%=password_list_filter%>" </small>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <li><a class="dropdown-item" href="admin_passwords.jsp?q=all">All</a></li>
                                            <li><a class="dropdown-item" href="admin_passwords.jsp?q=orphaned">Orphaned <em><small>(Passwords not assigned to a Safe)</small></em></a></li>
                                            <li><a class="dropdown-item" href="admin_passwords.jsp?q=expired">Expired Passwords</a></li>
                                        </ul>
                                    </div>
                                    <table id="password_table" class="table table-striped" style="width:100%">
                                        <thead>
                                            <tr>
                                                <th>&nbsp;&nbsp;&nbsp;&nbsp;Name</th>
                                                <th>Description</th>
                                                <th>Expires</th>
                                                <th>Created</th>
                                                <th>Owner</th>
                                                <th>Safe</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% 
                                            //LocalTime myObj = LocalTime.now();
                                            
                                            //System.out.println(myObj); // Display the current date
                                            
                                            
                                            //myObj = LocalTime.now();
                                            //System.out.println(myObj); // Display the current date
                                            if(passwords != null)
                                            {
                                                String expired = "";
                                                for(String[] password: passwords)
                                                {
                                                    String name = password[2];
                                                    String description = password[3];
                                                    String password_expires = "";
                                                    try
                                                    {
                                                        java.util.Date date = timestamp_format.parse(password[5]);
                                                        password_expires = jquery_datetime_picker_format.format(date);
                                                        //do expire
                                                        GregorianCalendar cal = new GregorianCalendar();
                                                        cal.add(cal.DATE, 30);
                                                        long days_future = cal.getTimeInMillis();                                    
                                                        expired = "";
                                                        if(date.getTime() < days_future)
                                                        {
                                                            expired = "<i title='About to expire or expired password' class=\"bi bi-exclamation-triangle-fill high\"></i>"; //<i class="bi bi-exclamation-triangle-fill"></i>
                                                        }     
                                                    }
                                                    catch(Exception e)
                                                    {
                                                        password_expires = "";
                                                    }
                                                    String password_created = "";
                                                    try
                                                    {
                                                        java.util.Date date = timestamp_format.parse(password[6]);
                                                        password_created = jquery_datetime_picker_format.format(date);
                                                    }
                                                    catch(Exception e)
                                                    {
                                                        password_created = "";
                                                    }
                                                    String owners_username = password[9];
                                                    String safe_name = password[8];
                                                %>
                                                <tr>
                                                    <td NOWRAP>
                                                        <div class="dropdown ms-auto">
                                                            <i class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                                            <ul class="dropdown-menu">
                                                                <li>
                                                                    <span class="dropdown-item">
                                                                        <!--<a title="Delete Password" href="admin_password_delete?b=<%=password[0]%>" onclick="return confirm('Are you sure you want to delete this item?');"><i style="cursor: pointer" class="bi bi-trash3 critical"></i>&nbsp;Delete</a>-->
                                                                        <a title="Delete this Password" href="#" onclick="open_delete_modal(<%=password[0]%>);">   <i style="cursor: pointer" class="bi bi-trash3 critical"></i>&nbsp;Delete</a>
                                                                    </span>
                                                                </li>
                                                                <li>
                                                                    <span class="dropdown-item">
                                                                        <a title="Update this Password" href="#" onclick="open_edit_modal(<%=password[0]%>);"><i style="cursor: pointer" class="bi bi-pencil-fill link-primary"></i>&nbsp;Edit</a>
                                                                    </span>
                                                                </li>
                                                                <li>
                                                                    <span class="dropdown-item">
                                                                        <a title="Password History" href="admin_password_history.jsp?b=<%=password[0]%>"><i style="cursor: pointer" class="bi bi-clock-history link-primary"></i>&nbsp;History</a>
                                                                    </span>
                                                                </li>
                                                            </ul>
                                                            &nbsp;<%=name%>
                                                        </div>  
                                                    </td>
                                                    <td><%=description%></td>
                                                    <td><%=expired%>&nbsp;<%=password_expires%></td>
                                                    <td><%=password_created%></td>
                                                    <td><%=owners_username%></td>
                                                    <td><%=safe_name%></td>
                                                </tr>
                                                <%
                                                }
                                            }
                                            %>
                                            
                                        </tbody>
                                        <tfoot>
                                            <tr>
                                                <th>&nbsp;&nbsp;&nbsp;&nbsp;Name</th>
                                                <th>Description</th>
                                                <th>Expires</th>
                                                <th>Created</th>
                                                <th>Owner</th>
                                                <th>Safe</th>
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
                                            <h5 class="modal-title" id="edit_modal_label">Add Passwords</h5>
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
                                                            <label for="add_expires" class="form-label">Expires <small>(MM/dd/yyyy hh:mm:ss)</small></label>
                                                            <div class="input-group">
                                                                <input id="add_expires" name="add_expires" class="form-control" type="text" value="">
                                                                <span class="input-group-text"><i class="bi bi-calendar-date "></i></span>
                                                            </div>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="add_created" class="form-label">Created <small>(MM/dd/yyyy hh:mm:ss)</small></label>
                                                            <div class="input-group">
                                                                <input id="add_created" name="add_created" class="form-control" type="text" value="">
                                                                <span class="input-group-text"><i class="bi bi-calendar-date "></i></span>
                                                            </div>
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
                                                            <label for="add_safe_id" class="form-label">Safe*</label>
                                                            <select class="form-select" name="add_safe_id" id="add_safe_id">
                                                                <option SELECTED value="-1"></option>
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
                                            <form action="admin_edit_password" name="edit_form" method="POST" onsubmit="return validateEditForm()">
                                                <input type="hidden" id="edit_id" name="edit_id" value=""/>  
                                                <div class="card-body">                                        
                                                    <div class="row mb-3">
                                                        <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12">
                                                            <label for="edit_name" class="form-label">Name*</label>
                                                            <input type="text" id="edit_name" name="edit_name" class="form-control"/>
                                                        </div>
                                                        <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12">
                                                            <label for="edit_description" class="form-label">Description*</label>
                                                            <input type="text" id="edit_description" name="edit_description" class="form-control"/>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-8 col-lg-8 col-md-8 col-sm-12">
                                                            <label for="edit_password" class="form-label"> Password*</label>
                                                            <div class="input-group">
                                                                <input type="password" name="edit_password" id="edit_password" class="form-control"/>
                                                                <span class="input-group-text"><i onclick="toggle_password('edit_password')" style="cursor: pointer" class="bi bi-eye "></i></span>
                                                            </div>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-4 col-sm-12">
                                                            <label for="edit_password_auto" class="form-label">Generate Password</label>
                                                                <select length="3" onchange="edit_modal_get_password()" class="form-select" name="edit_password_modal_size" id="edit_password_modal_size">
                                                                    <option value="0">Choose Password Length</option>
                                                                    <%
                                                                    for(int a = 4; a < 128; a++)
                                                                    {
                                                                        out.println("<option value=\"" + a + "\">" + a + "</option>");
                                                                    }
                                                                    %>
                                                                </select>
                                                        </div>
                                                    </div>
                                                    <div class="row mb-3">
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_expires" class="form-label">Expires <small>(MM/dd/yyyy hh:mm:ss)</small></label>
                                                            <div class="input-group">
                                                                <input id="edit_expires" name="edit_expires" class="form-control" type="text" value="">
                                                                <span class="input-group-text"><i class="bi bi-calendar-date "></i></span>
                                                            </div>
                                                        </div>
                                                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                                            <label for="edit_created" class="form-label">Created <small>(MM/dd/yyyy hh:mm:ss)</small></label>
                                                            <div class="input-group">
                                                                <input id="edit_created" name="edit_created" class="form-control" type="text" value="">
                                                                <span class="input-group-text"><i class="bi bi-calendar-date "></i></span>
                                                            </div>
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
                                                            <label for="edit_safe_id" class="form-label">Safe</label>
                                                            
                                                            <select class="form-select" name="edit_safe_id" id="edit_safe_id">
                                                                <option value="">None</option>
                                                                <%
                                                                for(String[] safe : safes)
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
                                                        const UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                                                        const LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
                                                        const NUMBERS = "0123456789";
                                                        const SPECIAL_CHARACTERS = " !@#$%^&*()-_=+[]{}|;:,.<>?";
                                                        
                                                        const edit_name = document.getElementById("edit_name").value;
                                                        const edit_description = document.getElementById("edit_description").value;
                                                        const edit_password = document.getElementById("edit_password").value;
                                                        const edit_expires = document.getElementById("edit_expires").value;
                                                        const edit_created = document.getElementById("edit_created").value;
                                                        let isValid = true;
                                                        
                                                        if(add_name === "")
                                                        {
                                                            isValid = false;
                                                            alert("Name is blank and is invalid. ");                                                                
                                                        }
                                                        else
                                                        {
                                                            for (let i = 0; i < edit_name.length; i++) 
                                                            {
                                                                if(UPPER_CASE.indexOf(edit_name[i]) === -1 &&
                                                                   LOWER_CASE.indexOf(edit_name[i]) === -1 &&
                                                                   NUMBERS.indexOf(edit_name[i]) === -1 &&
                                                                   SPECIAL_CHARACTERS.indexOf(edit_name[i]) === -1)
                                                                {
                                                                    isValid = false;
                                                                    alert("Name is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                    break;
                                                                }                                                            
                                                            }
                                                        } 
                                                        if(edit_description === "")
                                                        {
                                                            isValid = false;
                                                            alert("Description is blank and is invalid. ");                                                                
                                                        }
                                                        else
                                                        {
                                                            for (let i = 0; i < edit_description.length; i++) 
                                                            {
                                                                if(UPPER_CASE.indexOf(edit_description[i]) === -1 &&
                                                                   LOWER_CASE.indexOf(edit_description[i]) === -1 &&
                                                                   NUMBERS.indexOf(edit_description[i]) === -1 &&
                                                                   SPECIAL_CHARACTERS.indexOf(edit_description[i]) === -1)
                                                                {
                                                                    isValid = false;
                                                                    alert("Description is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                    break;
                                                                }                                                            
                                                            }
                                                        }
                                                        if(edit_password === "")
                                                        {
                                                            isValid = false;
                                                            alert("Password is blank and is invalid. ");                                                                
                                                        }
                                                        else
                                                        {
                                                            for (let i = 0; i < edit_password.length; i++) 
                                                            {
                                                                if(UPPER_CASE.indexOf(edit_password[i]) === -1 &&
                                                                   LOWER_CASE.indexOf(edit_password[i]) === -1 &&
                                                                   NUMBERS.indexOf(edit_password[i]) === -1 &&
                                                                   SPECIAL_CHARACTERS.indexOf(edit_password[i]) === -1)
                                                                {
                                                                    isValid = false;
                                                                    alert("Password is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                    break;
                                                                }                                                            
                                                            }
                                                        }
                                                        //check dateformats 08/04/2028 18:08:27
                                                        var edit_expires_matches = edit_expires.match(/^(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}):(\d{2})$/);
                                                        if (edit_expires_matches === null) 
                                                        {
                                                            // invalid
                                                            isValid = false;
                                                            alert("Expired date is invalid.");
                                                        }                                                          
                                                        var edit_created_matches = edit_created.match(/^(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}):(\d{2})$/);
                                                        if (edit_created_matches === null) 
                                                        {
                                                            // invalid
                                                            isValid = false;
                                                            alert("Created date is invalid.");
                                                        }  
                                                        return isValid;
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
                            <div class="modal fade modal-xl" id="delete_modal" tabindex="-1" aria-labelledby="delete_modal_label" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="edit_modal_label">Delete Password</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form action="admin_passwords_delete" name="delete_form" method="POST">
                                                <input type="hidden" id="delete_password_id" name="delete_password_id" value=""/>  
                                                <div class="row mb-3">
                                                    <div class="col-12">
                                                          <div class="form-check">
                                                            <input class="form-check-input" type="checkbox" value="password_nuke" name="password_nuke" id="password_nuke">
                                                            <label class="form-check-label" for="flexCheckDefault">
                                                              "Nuke" option. This deletes the Password and its history. This Password can not be recovered after this operation.
                                                            </label>
                                                          </div>
                                                    </div>
                                                </div>
                                                       
                                                <div class="row mb-3">
                                                    <div class="col-12">
                                                        <button type="submit" class="btn btn-primary">Delete Password</button>  
                                                    </div>
                                                </div>
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
        <script src="js/jquery.datetimepicker.full.minj.2.5.20.js"></script>    
        <script src="js/datatables.min.js"></script>
        <script>
            jQuery('#edit_expires').datetimepicker({
                showSecond: true,
                format:'m/d/Y H:m:s'
              }
            );
            jQuery('#edit_created').datetimepicker({
                showSecond: true,
                format:'m/d/Y H:m:s'
              }
            );
        </script>
        <script>
            new DataTable('#password_table');
        </script>
        <script>  
            function edit_modal_get_password()
            {
                var password_length = document.getElementById("edit_password_modal_size").value;
                $.ajax({
                    url: 'ajax_password_create',
                    method: 'GET',
                    dataType: 'json',
                    data: {
                        size: password_length
                    },
                    success: function (responseText)
                    {
                        $('#edit_password').val(responseText.password);    
                    }
                });    
            }                
        </script>
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
        <script>  
            function open_delete_modal(id)
            {
                //alert("start open_edit_modal id=" + id);
                //var user_tz_name = document.getElementById('user_tz_name').value;                
                //alert("start");
                $('#delete_password_id').val(id);
                $('#delete_modal').modal('show');
            }                
        </script>
        <script>
            function toggle_password(id) 
            {
                var x = document.getElementById(id);
                if (x.type === "password") 
                {
                    x.type = "text";
                } 
                else 
                {
                    x.type = "password";
                }
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
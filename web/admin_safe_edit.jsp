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
            System.out.println("Exception in admin_safe_edit.jsp=" + e);
        }
    
        String system_key = session.getAttribute("system_key").toString();
        String system_salt = session.getAttribute("system_salt").toString();
        String safe_id = request.getParameter("b");
        String safe_info[] = db.safe.safe_info(con, safe_id);
        String owner_info[] = db.user.info(con, safe_info[1]);
        ArrayList <String[]> groups = db.group.all_groups(con);
        ArrayList <String[]> group_permissions = db.safe.permissions_for_safe(con, safe_id);
        ArrayList <String[]> users = db.user.all_users(con);
        ArrayList<String[]> passwords = db.password.safe_and_passwords_for_safe_id(con, safe_id, session);
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
            <link href="css/jquery.datetimepicker.2.5.20.css" rel="stylesheet" />
        </header>
        <input type="hidden" name="safe_has_been_changed" id="safe_has_been_changed" value="false"/>
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
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin_safes.jsp"><i class="bi bi-safe-fill"></i>&nbsp;Safes</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-safe"></i>&nbsp;Edit Safe</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    <div class="dropdown ms-auto">
                                        <i class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                        <ul class="dropdown-menu">
                                            <li>
                                                <span class="dropdown-item">
                                                    <a title="Add a Password" href="admin_safe_password_new.jsp?safe_id=<%=safe_id%>"><i style="cursor: pointer" class="bi bi-plus-square link-primary"></i>&nbsp;Add Password</a>
                                                </span>
                                            </li>
                                        </ul>
                                        &nbsp;Edit Safe
                                    </div> 
                                </div>
                                <form action="admin_safe_edit" name="in_form" method="POST" onsubmit="return check_form()">
                                    <input type="hidden" name="safe_id" id="safe_id" value="<%=safe_id%>"/>
                                    <div class="card-body">
                                        <div class="row mb-3">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="name" class="form-label">Name*</label>
                                                <input type="name" id="name" name="name" class="form-control" value="<%=safe_info[2]%>"/>
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="owner_id" class="form-label">Owner*</label>
                                                <select onchange="set_has_changed()" class="form-control form-select" name="owner_id" id="owner_id">
                                                    <%
                                                    for(String[] user: users)
                                                    {
                                                        String selected = "";
                                                        if(user[0].equalsIgnoreCase(safe_info[1]))
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
                                            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12">
                                                <label for="description" class="form-label">Description*</label>
                                                <input type="text" id="description" name="description" class="form-control" value="<%=safe_info[3]%>"/>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <nav>
                                                <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                                    <button class="nav-link active" id="password-tab" data-bs-toggle="tab" data-bs-target="#password" type="button" role="tab" aria-controls="nav-profile" aria-selected="false">Passwords</button>
                                                    <button class="nav-link" id="permissions-tab" data-bs-toggle="tab" data-bs-target="#permission" type="button" role="tab" aria-controls="nav-home" aria-selected="true">Group Permissions</button>
                                                </div>
                                            </nav>
                                            <div class="tab-content" id="nav-tabContent">
                                                <div class="tab-pane fade " id="permission" role="tabpanel" aria-labelledby="nav-home-tab">
                                                    <div class="row mb-3">
                                                        <div class="col-md-12">
                                                            <br>
                                                            <h6>
                                                                Give User Group(s) access to this Safe. <em><small></small></em>                                                    
                                                            </h6>
                                                            <table id="group_safe_table" class="table table-striped" style="width:100%">
                                                                <thead>
                                                                    <tr>
                                                                        <th>Name</th>
                                                                        <th>Description</th>
                                                                        <th width="10%"><button type="button" class="btn btn-sm btn-link btn-info" data-bs-toggle="modal" data-bs-target="#permissions_modal">Permission Info</button></th>
                                                                        <th width="6%"><u>C</u>reate</th>
                                                                        <th width="6%"><u>R</u>ead</th>
                                                                        <th width="6%"><u>U</u>pdate</th>
                                                                        <th width="6%"><u>D</u>elete</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <%

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
                                                                        %>
                                                                        <tr>
                                                                        <td><%=group[1]%></td>
                                                                        <td><%=group[2]%></td>
                                                                        <td nowrap>
                                                                            Check&nbsp;
                                                                            <a href="#" onclick="check_all(<%=group[0]%>)"><smaller>All</smaller></a>&nbsp;/&nbsp;
                                                                            <a href="#" onclick="uncheck_all(<%=group[0]%>)"><smaller>None</smaller></a>
                                                                        </td>
                                                                        <td><input <%=create%> type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-create" name="group_id-<%=group[0]%>-create" value="create"></td>
                                                                        <td><input <%=read%> type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-read" name="group_id-<%=group[0]%>-read" value="read"></td>
                                                                        <td><input <%=update%> type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-update" name="group_id-<%=group[0]%>-update" value="update"></td>
                                                                        <td><input <%=delete%> type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-delete" name="group_id-<%=group[0]%>-delete" value="delete"></td>
                                                                    </tr>
                                                                        <%
                                                                    }
                                                                    %>
                                                                </tbody>
                                                                <%
                                                                if(groups.size() > 10)
                                                                {
                                                                    %>
                                                                <tfoot>
                                                                    <tr>
                                                                        <th>Name</th>
                                                                        <th>Description</th>
                                                                        <th></th>
                                                                        <th><u>C</u>reate</th>
                                                                        <th><u>R</u>ead</th>
                                                                        <th><u>U</u>pdate</th>
                                                                        <th><u>D</u>elete</th>
                                                                    </tr>
                                                                </tfoot>
                                                                <%
                                                                    }
                                                                %>
                                                            </table>                                                            
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="tab-pane fade show active" id="password" role="tabpanel" aria-labelledby="nav-profile-tab">
                                                    <div class="row mb-3">
                                                        <div class="col-md-12">
                                                            <br>
                                                            <h6>
                                                                Passwords in this Safe.                                                    
                                                            </h6>
                                                            <table id="password_table" class="table table-striped" style="width:100%">
                                                                <thead>
                                                                    <tr>
                                                                        <th>Name</th>
                                                                        <th>Description</th>
                                                                        <th>Password</th>
                                                                        <th>Expires&nbsp;<small>(MM/dd/yyyy hh:mm:ss)</small></th>
                                                                        <th>Created&nbsp;<small>(MM/dd/yyyy hh:mm:ss)</small></th>
                                                                        <th>Owner</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <%
                                                                        for (String[] password : passwords) 
                                                                        {
                                                                            String password_name = password[6];
                                                                            String password_dscription = password[7];
                                                                            String password_password = password[8];
                                                                            String password_expires = "";
                                                                            try
                                                                            {
                                                                                java.util.Date date = timestamp_format.parse(password[9]);
                                                                                password_expires = jquery_datetime_picker_format.format(date);
                                                                            }
                                                                            catch(Exception e)
                                                                            {
                                                                                password_expires = "";
                                                                            }
                                                                            String password_created = "";
                                                                            try
                                                                            {
                                                                                java.util.Date date = timestamp_format.parse(password[10]);
                                                                                password_created = jquery_datetime_picker_format.format(date);
                                                                            }
                                                                            catch(Exception e)
                                                                            {
                                                                                password_created = "";
                                                                            }
                                                                            String password_owner = password[12];
                                                                    %>
                                                                    <tr>
                                                                        <td>
                                                                            <div class="dropdown ms-auto">
                                                                                <i class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                                                                <ul class="dropdown-menu">
                                                                                    <li>
                                                                                        <span class="dropdown-item">
                                                                                            <a title="Edit Password" href="#" onclick="open_edit_password_modal(<%=password[0]%>);"><i style="cursor: pointer" class="bi bi-pencil-fill link-primary"></i>&nbsp;Edit Password</a>
                                                                                        </span>
                                                                                    </li>
                                                                                </ul>
                                                                                &nbsp;<%=password[6]%>
                                                                            </div> 
                                                                            
                                                                        </td>
                                                                        <td>&nbsp;<%=password_dscription%></td>
                                                                        <td nowrap><%=password_password%></td>
                                                                        <td><%=password_expires%></td>
                                                                        <td><%=password_created%></td>
                                                                        <td>
                                                                            <%
                                                                            for(String[] user: users)
                                                                            {
                                                                                String selected = "";
                                                                                if(user[0].equalsIgnoreCase(password[11]))
                                                                                {
                                                                                    out.println(user[1]);
                                                                                }
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
                                                                        <th>Name</th>
                                                                        <th>Description</th>
                                                                        <th>Password</th>
                                                                        <th>Expires</th>
                                                                        <th>Created</th>
                                                                        <th>Owner</th>
                                                                    </tr>
                                                                </tfoot>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>                                            
                                        </div>
                                        <button type="submit" class="btn btn-primary">Save changes</button>                                        
                                    </div>
                                </form>
                            </div>
                            <!-- Modal -->
                            <div class="modal fade" id="permissions_modal" tabindex="-1" aria-labelledby="permissions_modal_label" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="permissions_modal_label">Safe Permissions</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            Review the list below to understand permission and inheritance. 
                                            <ul>
                                                <li><u>C</u>reate - Members of the Group can Create new Passwords in this Safe. The "Create" permission inherits Read, Update, and Delete Safe permissions.</li>
                                                <li><u>R</u>ead - Members of the Group can Read all the passwords in this Safe.</li>
                                                <li><u>U</u>pdate - Members of the Group can Update all the passwords in this Safe. The "Update" permission inherits "Read" permission.</li>
                                                <li><u>D</u>elete - Members of the Group can Delete all the passwords in this Safe. The "Delete" permission inherits "Read" permission.</li>
                                            </ul>
                                            A user with minimal access should have "Read" permission only. The average user should have "Read" and "Update" so they can maintain the system. The most senior users should have all permissions. Grant the minimum permissions for the user to do their jobs. 
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Modal -->
                            <div class="modal fade" id="edit_password_modal" tabindex="-1" aria-labelledby="edit_modal_label" aria-hidden="true">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="edit_modal_label">Edit Password</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form action="admin_safe_password_edit" name="edit_form" method="POST" onsubmit="return check_edit_form()">
                                                <input type="hidden" id="edit_id" name="edit_id" value=""/>  
                                                <input type="hidden" id="edit_old_safe_id" name="edit_old_safe_id" value="<%=safe_id%>"/>   
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
                                                                for(int a = 1; a < 128; a++)
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
                                                            <button type="submit" class="btn btn-primary">Save changes</button>  
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <script>
                                                    function check_edit_form()
                                                    {
                                                        const UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                                                        const LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
                                                        const NUMBERS = "0123456789";
                                                        const SPECIAL_CHARACTERS = " !@#$%^&*()-_=+[]{}|;:,.<>?";
                                                        
                                                        const add_name = document.getElementById("edit_name").value;
                                                        const add_description = document.getElementById("edit_description").value;
                                                        const add_password = document.getElementById("edit_password").value;
                                                        const add_expires = document.getElementById("edit_expires").value;
                                                        const add_created = document.getElementById("edit_created").value;
                                                        let isValid = true;
                                                        
                                                        if(add_name === "")
                                                        {
                                                            isValid = false;
                                                            alert("Name is blank and is invalid. ");                                                                
                                                        }
                                                        else
                                                        {
                                                            for (let i = 0; i < add_name.length; i++) 
                                                            {
                                                                if(UPPER_CASE.indexOf(add_name[i]) === -1 &&
                                                                   LOWER_CASE.indexOf(add_name[i]) === -1 &&
                                                                   NUMBERS.indexOf(add_name[i]) === -1 &&
                                                                   SPECIAL_CHARACTERS.indexOf(add_name[i]) === -1)
                                                                {
                                                                    isValid = false;
                                                                    alert("Name is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                    break;
                                                                }                                                            
                                                            }
                                                        } 
                                                        if(add_description === "")
                                                        {
                                                            isValid = false;
                                                            alert("Description is blank and is invalid. ");                                                                
                                                        }
                                                        else
                                                        {
                                                            for (let i = 0; i < add_description.length; i++) 
                                                            {
                                                                if(UPPER_CASE.indexOf(add_description[i]) === -1 &&
                                                                   LOWER_CASE.indexOf(add_description[i]) === -1 &&
                                                                   NUMBERS.indexOf(add_description[i]) === -1 &&
                                                                   SPECIAL_CHARACTERS.indexOf(add_description[i]) === -1)
                                                                {
                                                                    isValid = false;
                                                                    alert("Description is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                    break;
                                                                }                                                            
                                                            }
                                                        }
                                                        if(add_password === "")
                                                        {
                                                            isValid = false;
                                                            alert("Password is blank and is invalid. ");                                                                
                                                        }
                                                        else
                                                        {
                                                            for (let i = 0; i < add_password.length; i++) 
                                                            {
                                                                if(UPPER_CASE.indexOf(add_password[i]) === -1 &&
                                                                   LOWER_CASE.indexOf(add_password[i]) === -1 &&
                                                                   NUMBERS.indexOf(add_password[i]) === -1 &&
                                                                   SPECIAL_CHARACTERS.indexOf(add_password[i]) === -1)
                                                                {
                                                                    isValid = false;
                                                                    alert("Password is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                    break;
                                                                }                                                            
                                                            }
                                                        }
                                                        //check dateformats 08/04/2028 18:08:27
                                                        var add_expires_matches = add_expires.match(/^(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}):(\d{2})$/);
                                                        if (add_expires_matches === null) 
                                                        {
                                                            // invalid
                                                            isValid = false;
                                                            alert("Expired date is invalid.");
                                                        }                                                          
                                                        var add_created_matches = add_created.match(/^(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}):(\d{2})$/);
                                                        if (add_created_matches === null) 
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
            function open_edit_password_modal(id)
            {
                //alert("open edit model");
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
                $('#edit_password_modal').modal('show');
            }                
        </script>
        
        <script>
            function check_all(group_id)
            {
                //const name_split = element.name.split("-");
                //const safe_id = name_split[1];
                document.getElementById("group_id-" + group_id + "-create").checked = true;
                document.getElementById("group_id-" + group_id + "-read").checked = true;
                document.getElementById("group_id-" + group_id + "-update").checked = true;
                document.getElementById("group_id-" + group_id + "-delete").checked = true;          
            }
            function uncheck_all(group_id)
            {
                //const name_split = element.name.split("-");
                //const safe_id = name_split[1];
                document.getElementById("group_id-" + group_id + "-create").checked = false;
                document.getElementById("group_id-" + group_id + "-read").checked = false;
                document.getElementById("group_id-" + group_id + "-update").checked = false;
                document.getElementById("group_id-" + group_id + "-delete").checked = false;          
            }
            function check_form()
            {
                const UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                const LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
                const NUMBERS = "0123456789";
                const SPECIAL_CHARACTERS = " !@#$%^&*()-_=+[]{}|;:,.<>?";

                const name = document.getElementById("name").value;
                const description = document.getElementById("description").value;
                let isValid = true;

                if(name === "")
                {
                    isValid = false;
                    alert("Name is blank and is invalid. ");                                                                
                }
                else
                {
                    for (let i = 0; i < name.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(name[i]) === -1 &&
                           LOWER_CASE.indexOf(name[i]) === -1 &&
                           NUMBERS.indexOf(name[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(name[i]) === -1)
                        {
                            isValid = false;
                            alert("Name is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                } 
                if(description === "")
                {
                    isValid = false;
                    alert("Description is blank and is invalid. ");                                                                
                }
                else
                {
                    for (let i = 0; i < description.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(description[i]) === -1 &&
                           LOWER_CASE.indexOf(description[i]) === -1 &&
                           NUMBERS.indexOf(description[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(description[i]) === -1)
                        {
                            isValid = false;
                            alert("Description is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                return isValid;
            }
        </script>
        <script>
        function toggle_password(id) 
        {
            alert("start toogle for" + id + " value=" + document.getElementById(id).value);
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
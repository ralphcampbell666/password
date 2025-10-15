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
            System.out.println("Exception in admin_safe_new.jsp=" + e);
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
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin_safes.jsp"><i class="bi bi-safe-fill"></i>&nbsp;Admin Safe</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-safe"></i>&nbsp;New Safe</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    New Safe
                                </div>
                                <form action="admin_safe_new" name="in_form" method="POST" onsubmit="return check_form()">
                                    <div class="card-body">
                                        <div class="row mb-3">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="name" class="form-label">Name*</label>
                                                <input type="name" id="name" name="name" class="form-control">
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="name" class="form-label">Owner*</label>
                                                <select class="form-control form-select" name="owner_id" id="owner_id">
                                                    <%
                                                    ArrayList <String[]> users = db.user.all_users(con);
                                                    for(String[] user: users)
                                                    {
                                                       %>
                                                       <option value="<%=user[0]%>"><%=user[1]%></option>
                                                       <%
                                                    }
                                                    %>
                                                </select>
                                            </div>
                                            <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12">
                                                <label for="description" class="form-label">Description*</label>
                                                <input type="text" id="description" name="description" class="form-control">
                                            </div>
                                        </div>
                                        <div class="row"><hr></div>
                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <h6>
                                                    Give User Group(s) access to this Safe. <em><small></small></em>                                                    
                                                </h6>
                                                <table id="group_safe" class="table table-striped" style="width:100%">
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
                                                        ArrayList <String[]> groups = db.group.all_groups(con);
                                                        for(String group[]: groups)
                                                        {
                                                            %>
                                                            <tr>
                                                            <td><%=group[1]%></td>
                                                            <td><%=group[2]%></td>
                                                            <td nowrap>
                                                                Check&nbsp;
                                                                <a href="#" onclick="check_all(<%=group[0]%>)"><smaller>All</smaller></a>&nbsp;/&nbsp;
                                                                <a href="#" onclick="uncheck_all(<%=group[0]%>)"><smaller>None</smaller></a>
                                                            </td>
                                                            <td><input type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-create" name="group_id-<%=group[0]%>-create" value="create"></td>
                                                            <td><input type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-read" name="group_id-<%=group[0]%>-read" value="read"></td>
                                                            <td><input type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-update" name="group_id-<%=group[0]%>-update" value="update"></td>
                                                            <td><input type="checkbox" class="form-check-input" id="group_id-<%=group[0]%>-delete" name="group_id-<%=group[0]%>-delete" value="delete"></td>
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
                                                <button type="submit" class="btn btn-primary">Save changes</button>
                                            </div>
                                        </div>
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
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
    
    if(is_admin)
    {
        try 
        {
            //con = db.db_util.get_contract_connection(context_dir, session);
        }
        catch(Exception e)
        {
            System.out.println("Exception in group_edit.jsp=" + e);
        }
        String id = "0";
        try
        {
            id = request.getParameter("id");
            if(id == null)
            {
                id = "0";
            }
        }
        catch(Exception e)
        {
            id = "0";
        }
        String group_info[] = db.group.by_id(con, id);
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="description" content="" />
        <meta name="author" content="" />
        <title>Passwords</title>
        <!-- Favicon-->
        <link rel="icon" type="image/x-icon" href="assets/images/lock_icon_24.png" />
        <!-- Bootstrap icons-->
        <link href="css/bootstrap5/bootstrap-icons.css" rel="stylesheet" />
        <!-- Core theme CSS (includes Bootstrap)-->
        <link href="css/styles.css" rel="stylesheet" />
        <!-- Bootstrap fancy select-->
        <link href="css/bootstrap-select.min.css" rel="stylesheet" />
    </head>
    <body class="d-flex flex-column">
        <!-- Responsive navbar-->
        <jsp:include page='nav_bar.jsp'>
            <jsp:param name="menu" value="home"/>
        </jsp:include>    
        <!-- Page Content-->
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">&nbsp;</div>
            </div>
            <div class="row">
                <div class="col-12">
                    <div class="card mx-auto">
                        <div class="card-body">
                            <!-- Start Content-->
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item"><a href="admin.jsp"><i class="bi bi bi-gear-fill"></i>&nbsp;Admin</a></li>
                                    <li class="breadcrumb-item"><a href="admin_groups.jsp"><i class="bi bi-people-fill"></i>&nbsp;Groups</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-people-fill"></i>&nbsp;Edit Group</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    Edit Group
                                </div>
                                <form action="group_edit" method="POST">
                                    <input type="hidden" name="id" id="id" value="<%=id%>"/>
                                    <div class="card-body">
                                        <div class="row mb-3">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="name" class="form-label">Name</label>
                                                <input type="name" id="name" name="name" class="form-control" value="<%=group_info[1]%>">
                                            </div>
                                            <div class="col-xl-9 col-lg-8 col-md-6 col-sm-12">
                                                <label for="description" class="form-label">Description</label>
                                                <input type="text" id="description" name="description" class="form-control" value="<%=group_info[2]%>">
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="group_ids">Assign User(s) to Group. <em><small>Select any number of Users to join this Group.</small></em></label>
                                                <select class="selectpicker form-control" id="user_ids" name="user_ids" multiple="multiple" data-actions-box="true">                                                    
                                                    <%
                                                    ArrayList <String[]> users_in_group = db.user.all_users_in_group(con,id);
                                                    ArrayList <String[]> users = db.user.all_users(con);
                                                    String selected = "";
                                                    for(String[] user: users)
                                                    {
                                                        selected = "";
                                                        for(String[] user_in_group: users_in_group)
                                                        {
                                                            if(user_in_group[0].equals(user[0]))
                                                            {
                                                                selected = "selected";
                                                            }
                                                        }
                                                        %>
                                                        <option <%=selected%> value="<%=user[0]%>"><%=user[1]%></option>
                                                        <%
                                                    }
                                                    %>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row"><hr></div>
                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <h6>
                                                    Assign Safe Permissions to this Group. <em><small></small></em>                                                    
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
                                                        ArrayList <String[]> safes = db.safe.all_safes(con);
                                                        ArrayList <String[]> this_groups_safes = db.safe.safe_name_by_group(con, id);  
                                                        String C = "";
                                                        String R = "";
                                                        String U = "";
                                                        String D = "";
                                                        
                                                        for(String safe[]: safes)
                                                        {
                                                            C = "";
                                                            R = "";
                                                            U = "";
                                                            D = "";
                                                            %>
                                                            <tr>
                                                            <td><%=safe[2]%></td>
                                                            <td><%=safe[3]%></td>
                                                            <td nowrap>
                                                                Select&nbsp;
                                                                <a href="#" onclick="check_all(<%=safe[0]%>)"><smaller>All</smaller></a>&nbsp;/&nbsp;
                                                                <a href="#" onclick="uncheck_all(<%=safe[0]%>)"><smaller>None</smaller></a>
                                                            </td>
                                                            <%
                                                            //System.out.println("this_groups_safes.size=" + this_groups_safes.size());
                                                            for(String this_groups_safe[]: this_groups_safes)
                                                            {
                                                                if(this_groups_safe[0].equals(safe[0]))
                                                                {
                                                                    if(this_groups_safe[6].equals("1")) //CREATE
                                                                    {
                                                                        C = "checked=\"checked\"";
                                                                    }
                                                                    if(this_groups_safe[7].equals("1")) //READ
                                                                    {
                                                                        R = "checked=\"checked\"";
                                                                    }
                                                                    if(this_groups_safe[8].equals("1")) //UPDATE
                                                                    {
                                                                        U = "checked=\"checked\"";
                                                                    }
                                                                    if(this_groups_safe[9].equals("1")) //DELETE
                                                                    {
                                                                        D = "checked=\"checked\"";
                                                                    }
                                                                }
                                                            }
                                                            %>
                                                            <td><input type="checkbox" <%=C%> class="form-check-input" id="safe_id-<%=safe[0]%>-create" name="safe_id-<%=safe[0]%>-create" value="create"></td>
                                                            <td><input type="checkbox" <%=R%> class="form-check-input" id="safe_id-<%=safe[0]%>-read" name="safe_id-<%=safe[0]%>-read" value="read"></td>
                                                            <td><input type="checkbox" <%=U%> class="form-check-input" id="safe_id-<%=safe[0]%>-update" name="safe_id-<%=safe[0]%>-update" value="update"></td>
                                                            <td><input type="checkbox" <%=D%> class="form-check-input" id="safe_id-<%=safe[0]%>-delete" name="safe_id-<%=safe[0]%>-delete" value="delete"></td>
                                                        </tr>
                                                            <%
                                                        }
                                                        %>
                                                    </tbody>
                                                    <%
                                                    if(safes.size() > 10)
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
        </div>
        <div class="row">
            <div class="mb-3">&nbsp;</div>
        </div>
        <!-- Footer-->
        <footer class="mt-auto py-2 bg-dark">
            <div class="container"><p class="text-center text-white">Copyright &copy; 2024</p></div>
        </footer>
        <!-- Bootstrap core JS-->
        <script src="js/bootstrap.bundle.min.js"></script>
        <!-- Core theme JS-->
        <script src="js/scripts.js"></script>
        <!-- Bootstrap fancy select-->
        <script src="js/jquery-3.7.1.min.js"></script>
        <script src="js/bootstrap-select.min.js"></script>
        
        <script>
            $('#user_ids').selectpicker();
        </script>
        <script>
            function check_all(safe_id)
            {
                //const name_split = element.name.split("-");
                //const safe_id = name_split[1];
                document.getElementById("safe_id-" + safe_id + "-create").checked = true;
                document.getElementById("safe_id-" + safe_id + "-read").checked = true;
                document.getElementById("safe_id-" + safe_id + "-update").checked = true;
                document.getElementById("safe_id-" + safe_id + "-delete").checked = true;          
            }
            function uncheck_all(safe_id)
            {
                //const name_split = element.name.split("-");
                //const safe_id = name_split[1];
                document.getElementById("safe_id-" + safe_id + "-create").checked = false;
                document.getElementById("safe_id-" + safe_id + "-read").checked = false;
                document.getElementById("safe_id-" + safe_id + "-update").checked = false;
                document.getElementById("safe_id-" + safe_id + "-delete").checked = false;          
            }
            function clear_user_select()
            {
                alert("start");
                //$('.user_ids').selectpicker('deselectAll');
                $('.user_ids').selectpicker('deselectAll');
                //$("#user_ids").selectpicker('clearSelection');
                //$('#user_ids option').attr("selected",false);
                //$('#user_ids').selectpicker('refresh');
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
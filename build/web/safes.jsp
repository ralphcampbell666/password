<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.GregorianCalendar"%>

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
        System.out.println("Exception in safes.jsp=" + e);
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
                <jsp:param name="menu" value="safes"/>
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
                            <nav style="--bs-breadcrumb-divider: ' ';" aria-label="breadcrumb">
                            <!--<nav aria-label="breadcrumb">-->
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item "  aria-current="page">
                                        <div class="dropdown ms-auto">
                                            <i title="Main Safe Menu" class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                            <ul class="dropdown-menu">
                                                <li>                                                    
                                                    <%
                                                    if(safe_creator || is_admin)
                                                    {
                                                        %>
                                                        <span class="dropdown-item ">
                                                            <a href="safe_new.jsp"><i style="cursor: pointer" class="bi bi bi-plus-square link-primary"></i>&nbsp;Add a Safe</a>
                                                        </span>
                                                        <%
                                                    }
                                                    else
                                                    {
                                                        %>
                                                        <span class="dropdown-item disabled">
                                                            <a href="#"><i style="cursor: pointer" class="bi bi bi-plus-square unknown"></i>&nbsp;Add a Safe</a>
                                                        </span>
                                                        <%
                                                    }
                                                    %>
                                                </li>
                                            </ul>
                                        </div>                                        
                                    </li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-safe-fill"></i>
                                        &nbsp;Safes&nbsp;&nbsp;&nbsp;&nbsp;
                                    </li>                                    
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-body">                                        
                                    <!--cards of safes that this user can see-->
                                    <div class="row">
                                        <%
                                        GregorianCalendar cal = new GregorianCalendar();
                                        cal.add(cal.DATE, 30);
                                        long days_future = cal.getTimeInMillis();                                    

                                        ArrayList <String> my_safes = db.safe.my_safes(con, session_user_id);
                                        String expired = "";
                                        String safe_id = "";
                                        String safe_name = "";
                                        String safe_description = "";
                                        int number_of_passwords = 0;

                                        for(String my_safe: my_safes)
                                        {
                                            expired = "";
                                            String safe_info[] = db.safe.safe_info(con, my_safe);
                                            safe_id = safe_info[0];
                                            safe_name = safe_info[2];
                                            safe_description = safe_info[3];
                                            ArrayList <String[]> passwords = db.password.safe_and_passwords_for_safe_id(con, my_safe, session);
                                            number_of_passwords = passwords.size();
                                            int number_of_expired_passwords = 0;
                                            for(String[] password: passwords)
                                            {
                                                try
                                                {
                                                    java.util.Date this_expire = timestamp_format.parse(password[9]);                                                    
                                                    if(this_expire.getTime() < days_future)
                                                    {
                                                        number_of_expired_passwords++;
                                                    }
                                                }
                                                catch(Exception e)
                                                {
                                                    //System.out.println("exception expire date='" + password[9] + "' in safes.jsp=" + e);
                                                }
                                            }
                                            if(number_of_expired_passwords > 0)
                                            {
                                                expired = "<i title='Password(s) are about to expire or have expired' class=\"bi bi-exclamation-triangle-fill high\"></i>";
                                            }
                                            %>
                                                <div class="col-xl-auto col-lg-6 col-md-6 col-sm-12 mb-4 ">                                                    
                                                    <div class="card h-100">
                                                        <div class="card-header">                                                            
                                                            <div class="dropdown ms-auto">
                                                                <i title="<%=safe_name%> Menu" class="bi bi-list" data-bs-toggle="dropdown" aria-expanded="false"></i>
                                                                <ul class="dropdown-menu">
                                                                    
                                                                    <li>
                                                                        <%
                                                                        if(safe_creator || is_admin)
                                                                        {
                                                                            %>
                                                                            <span class="dropdown-item">
                                                                                <a href="#" onclick="open_edit_modal(<%=safe_id%>);"><i class="bi bi-pencil-fill link-primary"></i>&nbsp;Edit this Safe</a>
                                                                            </span>
                                                                            <%
                                                                        }
                                                                        else
                                                                        {
                                                                            %>
                                                                            <span class="dropdown-item disabled">
                                                                                <a href="#"><i class="bi bi-pencil-fill unknown"></i>&nbsp;Edit this Safe</a>
                                                                            </span>
                                                                            <%
                                                                        }

                                                                        %>
                                                                    </li>
                                                                    <li>
                                                                        
                                                                            <%
                                                                            if(safe_creator || is_admin)
                                                                            {
                                                                                %>
                                                                                <span class="dropdown-item">
                                                                                    <a href="safe_safe_delete.jsp?b=<%=safe_id%>"><i class="bi bi-trash3 critical"></i>&nbsp;Delete this Safe</a>
                                                                                </span>
                                                                                <%
                                                                            }
                                                                            else
                                                                            {
                                                                                %>
                                                                                <span class="dropdown-item disabled">
                                                                                    <a href="#"><i class="bi bi-trash3 unknown"></i>&nbsp;Delete this Safe</a>
                                                                                </span>
                                                                                <%
                                                                            }
                                                                            %>
                                                                    </li>
                                                                </ul>
                                                                <%=safe_name%>&nbsp;&nbsp;&nbsp;&nbsp;<%=expired%>
                                                            </div>                                                             
                                                        </div>
                                                        <a href="safe.jsp?b=<%=my_safe%>">
                                                            <div class="card-body">
                                                                <p class="card-text">
                                                                    <em><b>Description:</b></em>&nbsp;&nbsp;<%=safe_description%>
                                                                    <br>
                                                                    <em><b>Passwords#:</b></em>&nbsp;&nbsp;<%=number_of_passwords%>                                                   
                                                                </p>
                                                            </div> <!-- end card-->
                                                        </a>
                                                    </div>
                                                </div>                                        
                                            <%
                                        }
                                        if(my_safes.size() == 0)
                                        {
                                            %>
                                            <div class="col-xl-auto col-lg-6 col-md-6 col-sm-12 box mb-4 d-flex align-items-stretch">
                                                    <a href="#">
                                                    <div class="card">
                                                        <div class="card-header">
                                                            No Safes created or Not Authorized to view any Safes 
                                                        </div>
                                                        <div class="card-body">
                                                            <p class="card-text">
                                                                &nbsp;
                                                                <br>
                                                                                                                
                                                            </p>
                                                        </div> <!-- end card-->
                                                    </div>
                                                    </a>
                                                </div> 
                                            <%
                                        }
                                        %>
                                    </div>                                        
                                </div>
                            </div>
                            <!--End Content-->
                            <!-- Modal -->
                            <div class="modal fade modal-xl" id="edit_safe_modal" tabindex="-1" aria-labelledby="edit_safe_modal" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="edit_safe_modal_label">Edit Safe</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="card">
                                                <div class="card-header">
                                                    Edit Safe
                                                </div>
                                                <form action="safe_edit" name="safe_edit_form" method="POST" onsubmit="return check_edit_safe_form()">
                                                    <input type="hidden" name="safe_edit_id" id="safe_edit_id" value=""/>
                                                    <div class="card-body">
                                                        <div class="row mb-3">
                                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                                <label for="safe_edit_name" class="form-label">Name*</label>
                                                                <input type="name" id="safe_edit_name" name="safe_edit_name" class="form-control">
                                                            </div>
                                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                                <label for="name" class="form-label">Owner*</label>
                                                                <select class="form-control form-select" name="safe_edit_owner_id" id="safe_edit_owner_id">
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
                                                                <label for="safe_edit_description" class="form-label">Description*</label>
                                                                <input type="text" id="safe_edit_description" name="safe_edit_description" class="form-control">
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
                                                                            <th>Group Name</th>
                                                                            <th>Group Description</th>
                                                                            <th width="10%"></th>
                                                                            <th width="6%"><u>C</u>reate</th>
                                                                            <th width="6%"><u>R</u>ead</th>
                                                                            <th width="6%"><u>U</u>pdate</th>
                                                                            <th width="6%"><u>D</u>elete</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody name="permission_table_body" id="permission_table_body">
                                                                        <tr>
                                                                            <td>&nbsp;</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>&nbsp;</td>
                                                                            <td>&nbsp;</td>
                                                                        </tr>
                                                                    </tbody>
                                                                    
                                                                    <tfoot>
                                                                        <tr>
                                                                            <th>Group Name</th>
                                                                            <th>Group Description</th>
                                                                            <th></th>
                                                                            <th><u>C</u>reate</th>
                                                                            <th><u>R</u>ead</th>
                                                                            <th><u>U</u>pdate</th>
                                                                            <th><u>D</u>elete</th>
                                                                        </tr>
                                                                    </tfoot>
                                                                </table>
                                                                <button id="safe_edit_save_button" name="safe_edit_save_button" type="submit" class="btn btn-primary">&nbsp;&nbsp;Save&nbsp;&nbsp;</button>
                                                                <hr>
                                                                <div class="accordion accordion-flush" id="accordionFlushExample">
                                                                    <div class="accordion-item">
                                                                        <h2 class="accordion-header">
                                                                            <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseOne" aria-expanded="false" aria-controls="flush-collapseOne">
                                                                                Help: Understanding User Group(s) access to this Safe
                                                                            </button>
                                                                        </h2>
                                                                        <div id="flush-collapseOne" class="accordion-collapse collapse" data-bs-parent="#accordionFlushExample">
                                                                            <div class="accordion-body">
                                                                                Review the list below to understand permission and inheritance. 
                                                                                <ul>
                                                                                    <li><u>C</u>reate - Members of the Group can Create new Passwords in this Safe. The "Create" permission inherits Read, Update, and Delete Safe permissions.</li>
                                                                                    <li><u>R</u>ead - Members of the Group can Read all the passwords in this Safe.</li>
                                                                                    <li><u>U</u>pdate - Members of the Group can Update all the passwords in this Safe. The "Update" permission inherits "Read" permission.</li>
                                                                                    <li><u>D</u>elete - Members of the Group can Delete all the passwords in this Safe. The "Delete" permission inherits "Read" permission.</li>
                                                                                </ul>
                                                                                A user with minimal access should have "Read" permission only. The average user should have "Read" and "Update" so they can maintain the system. The most senior users should have all permissions. Grant the minimum permissions for the user to do their jobs. 
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <script>
                                                        function check_edit_safe_form()
                                                        {
                                                            const UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                                                            const LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
                                                            const NUMBERS = "0123456789";
                                                            const SPECIAL_CHARACTERS = " !@#$%^&*()-_=+[]{}|;:,.<>?";

                                                            const safe_edit_name = document.getElementById("safe_edit_name").value;
                                                            const safe_edit_description = document.getElementById("safe_edit_description").value;
                                                            let isValid = true;
                                                            if(safe_edit_name === "")
                                                            {
                                                                isValid = false;
                                                                alert("Name is blank and is invalid. ");                                                                
                                                            }
                                                            else
                                                            {
                                                                for (let i = 0; i < safe_edit_name.length; i++) 
                                                                {
                                                                    if(UPPER_CASE.indexOf(safe_edit_name[i]) === -1 &&
                                                                       LOWER_CASE.indexOf(safe_edit_name[i]) === -1 &&
                                                                       NUMBERS.indexOf(safe_edit_name[i]) === -1 &&
                                                                       SPECIAL_CHARACTERS.indexOf(safe_edit_name[i]) === -1)
                                                                    {
                                                                        isValid = false;
                                                                        alert("Name is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                        break;
                                                                    }                                                            
                                                                }
                                                            } 
                                                            if(safe_edit_description === "")
                                                            {
                                                                isValid = false;
                                                                alert("Description is blank and is invalid. ");                                                                
                                                            }
                                                            else
                                                            {
                                                                for (let i = 0; i < safe_edit_description.length; i++) 
                                                                {
                                                                    if(UPPER_CASE.indexOf(safe_edit_description[i]) === -1 &&
                                                                       LOWER_CASE.indexOf(safe_edit_description[i]) === -1 &&
                                                                       NUMBERS.indexOf(safe_edit_description[i]) === -1 &&
                                                                       SPECIAL_CHARACTERS.indexOf(safe_edit_description[i]) === -1)
                                                                    {
                                                                        isValid = false;
                                                                        alert("Description is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                                                                        break;
                                                                    }                                                            
                                                                }
                                                            }
                                                            return isValid;
                                                        }                                                        
                                                        function safe_edit_check_all(group_id)
                                                        {
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-create").checked = true;
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-read").checked = true;
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-update").checked = true;
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-delete").checked = true;          
                                                        }
                                                        function safe_edit_uncheck_all(group_id)
                                                        {
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-create").checked = false;
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-read").checked = false;
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-update").checked = false;
                                                            document.getElementById("safe_edit_group_id-" + group_id + "-delete").checked = false;          
                                                        }
                                                    </script>
                                                </form>
                                            </div>
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
            function open_edit_modal(id)
            {
                //alert("start open_edit_modal id=" + id);
                //var user_tz_name = document.getElementById('user_tz_name').value;                
                //alert("start");
                // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
                $.ajax({
                    url: 'ajax_safe?search=' + id,
                    method: 'GET',
                    dataType: 'json',
                    data: {
                        search: id
                    },
                    success: function (responseText)
                    {
                        $('#safe_edit_id').val(id); //id
                        $('#safe_edit_name').val(responseText.name); //name
                        $('#safe_edit_description').val(responseText.description); //description
                        $('#safe_edit_owner_id').val(responseText.owner_id); //owner_id
                        //alert("success");
                        document.getElementById('permission_table_body').innerHTML = responseText.group_permission_table;
                        //alert(responseText.group_permission_table);
                        if(responseText.id === "-1")
                        {
                            document.getElementById("safe_edit_save_button").disabled = true;
                        }
                    }
                });                
                 $('#edit_safe_modal').modal('show');
            }                
        </script>
    </body>
</html>
 <%
     con.close();
 }
 %>
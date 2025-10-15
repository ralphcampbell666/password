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
            System.out.println("Exception in admin_user_edit.jsp=" + e);
        }
        String key = session.getAttribute("system_key").toString();
        String salt = session.getAttribute("system_salt").toString();
        String user_id = request.getParameter("id");
        String user_info[] = db.user.info(con, user_id);
        String checked = "";
        String selected = "";
        String disabled = "";
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
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin_users.jsp"><i class="bi bi-people-fill"></i>&nbsp;Users</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-person-fill-gear"></i>&nbsp;Edit User</li>
                                </ol>
                            </nav>
                            <div class="card">
                                <div class="card-header">
                                    Edit User
                                </div>
                                <div class="card-body">
                                    <form name="this_form" action="admin_user_edit" onsubmit="return validateForm()">
                                        <input type="hidden" name="user_id" id="user_id" value="<%=user_id%>"/>
                                        <div class="row mb-3">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="username" class="form-label">User Name</label>
                                                <input type="text" id="username" name="username" value="<%=user_info[1]%>" class="form-control">
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="password" class="form-label">Password   <i onclick="showPassword('password')" class="bi bi-eye"></i></label>
                                                <%
                                                String decrypted_password = support.encryption.decrypt_aes256(user_info[2], key, salt);
                                                %>
                                                <input type="password" id="password" name="password" value="<%=decrypted_password%>" class="form-control">
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="is_admin" class="form-label">Administrator</label>
                                                <br>
                                                <%
                                                
                                                if(user_info[15].toString().equalsIgnoreCase("1"))
                                                {
                                                    checked = "CHECKED";
                                                }
                                                else
                                                {
                                                    checked = "";
                                                }
                                                //override everything if user id = 0 THE ADMIN
                                                if(user_info[0].equalsIgnoreCase("0"))
                                                {
                                                    checked = "CHECKED";
                                                    disabled = "DISABLED";
                                                }
                                                %>
                                                <input <%=checked%> <%=disabled%> type="checkbox" class="form-check-input" id="is_admin" name="is_admin">
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="safe_creator" class="form-label">Safe Creator</label>
                                                <br>
                                                <%
                                                if(user_info[16].toString().equalsIgnoreCase("1"))
                                                {
                                                    checked = "CHECKED";
                                                }
                                                else
                                                {
                                                    checked = "";
                                                }
                                                //override everything if user id = 0 THE ADMIN
                                                if(user_info[0].equalsIgnoreCase("0"))
                                                {
                                                    checked = "CHECKED";
                                                    disabled = "DISABLED";
                                                }
                                                %>
                                                <input <%=checked%> <%=disabled%>  type="checkbox" class="form-check-input" id="safe_creator" name="safe_creator">
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="first" class="form-label">First Name</label>
                                                <input type="text" id="first" name="first" class="form-control" value="<%=user_info[3]%>">
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="mi" class="form-label">MI</label>
                                                <input type="text" id="mi" name="mi" class="form-control" value="<%=user_info[4]%>">
                                            </div>
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                <label for="last" class="form-label">Last Name</label>
                                                <input type="text" id="last" name="last" class="form-control" value="<%=user_info[5]%>">
                                            </div>                                            
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="address_1" class="form-label">Address <em>(1st Line)</em></label>
                                                    <input type="text" id="address_1" name="address_1" class="form-control" value="<%=user_info[6]%>">
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-group">
                                                    <label for="address_2" class="form-label">Address <em>(2nd Line)</em></label>
                                                    <input type="text" id="address_2" name="address_2" class="form-control" value="<%=user_info[7]%>">
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label for="city" class="form-label">City</label>
                                                    <input type="text" id="city" name="city" class="form-control" value="<%=user_info[8]%>">
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label for="state" class="form-label">State</label>
                                                    <input type="text" id="state" name="state" class="form-control" value="<%=user_info[9]%>">
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label for="zip" class="form-label">Zip</label>
                                                    <input type="text" id="zip" name="zip" class="form-control" value="<%=user_info[10]%>">
                                                </div>
                                            </div>
                                        </div><!--end row-->
                                        <div class="row mb-3">
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label for="phone_office">Office Phone</label>
                                                    <input type="text" id="phone_office" name="phone_office" class="form-control" value="<%=user_info[12]%>">
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="form-group">
                                                    <label for="phone_mobile">Mobile Phone</label>
                                                    <input type="text" id="phone_mobile" name="phone_mobile" class="form-control" value="<%=user_info[13]%>">
                                                </div>
                                            </div>
                                            <div class="col-md-5">
                                                <div class="form-group">
                                                    <label for="email">Email</label>
                                                    <input type="text" id="email" name="email" class="form-control" value="<%=user_info[11]%>">
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label for="notes">Notes</label>
                                                    <input type="text" id="notes" name="notes" class="form-control" value="<%=user_info[14]%>">
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <label for="group_ids">Assign User to Group(s).&nbsp;&nbsp;<a href="#" onclick="clearSelected();"><font color="blue">Clear All Selections</font></a>&nbsp;&nbsp;<em><small>Select any number of Groups for this user to join. Hold the "Ctrl" button down while clicking to select multiple Groups.</small></em></label>
                                                <select class="select2 form-control" id="group_ids" name="group_ids" multiple="multiple" placeholder="Select Group membership">
                                                    <%
                                                    ArrayList <String[]> all_groups = db.group.all_groups(con);
                                                    ArrayList <String> assigned_groups = db.group.groups_assigned_to_user_id(con, user_id);
                                                    for(String[] group: all_groups)
                                                    {
                                                        selected = "";
                                                        String this_group_id = group[0];
                                                        for(String assigned_group: assigned_groups)
                                                        {
                                                            if(assigned_group.equalsIgnoreCase(group[0]))
                                                            {
                                                                selected = "selected";
                                                            }
                                                        }
                                                        %>
                                                        <option <%=selected%> value="<%=group[0]%>"><%=group[1]%></option>
                                                        <%
                                                    }
                                                    %>
                                                </select>
                                            </div>
                                        </div>
                                        <button type="submit" class="btn btn-primary">&nbsp;&nbsp;&nbsp;Save&nbsp;&nbsp;&nbsp;</button>
                                    </form>  
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
            function showPassword(targetID) 
            {
                var x = document.getElementById(targetID);
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
        <script>
            function validateForm() 
            {
                let isValid = true;
                const UPPER_CASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                const LOWER_CASE = "abcdefghijklmnopqrstuvwxyz";
                const NUMBERS = "0123456789";
                const SPECIAL_CHARACTERS = " !@#$%^&*()-_=+[]{}|;:,.<>?";
                
                let username = document.forms["this_form"]["username"].value;
                let password = document.forms["this_form"]["password"].value;
                let first = document.forms["this_form"]["first"].value;
                let mi = document.forms["this_form"]["mi"].value;
                let last = document.forms["this_form"]["last"].value;
                let address_1 = document.forms["this_form"]["address_1"].value;
                let address_2 = document.forms["this_form"]["address_2"].value;
                let city = document.forms["this_form"]["city"].value;
                let state = document.forms["this_form"]["state"].value;
                let zip = document.forms["this_form"]["zip"].value;
                let phone_office = document.forms["this_form"]["phone_office"].value;
                let phone_mobile = document.forms["this_form"]["phone_mobile"].value;
                let email = document.forms["this_form"]["email"].value;
                let notes = document.forms["this_form"]["notes"].value;
                                
                if (username === "") 
                {
                  alert("Username and Password are required");
                  isValid = false;
                }
                else
                {
                    for (let i = 0; i < username.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(username[i]) === -1 &&
                           LOWER_CASE.indexOf(username[i]) === -1 &&
                           NUMBERS.indexOf(username[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(username[i]) === -1)
                        {
                            isValid = false;
                            alert("User Name is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                } 
                if (password === "") 
                {
                  alert("Password is required");
                  isValid = false;
                }
                else
                {
                    for (let i = 0; i < password.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(password[i]) === -1 &&
                           LOWER_CASE.indexOf(password[i]) === -1 &&
                           NUMBERS.indexOf(password[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(password[i]) === -1)
                        {
                            isValid = false;
                            alert("Password is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                } 
                if(first === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < first.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(first[i]) === -1 &&
                           LOWER_CASE.indexOf(first[i]) === -1 &&
                           NUMBERS.indexOf(first[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(first[i]) === -1)
                        {
                            isValid = false;
                            alert("First is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(mi === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < mi.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(mi[i]) === -1 &&
                           LOWER_CASE.indexOf(mi[i]) === -1 &&
                           NUMBERS.indexOf(mi[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(mi[i]) === -1)
                        {
                            isValid = false;
                            alert("MI is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(last === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < last.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(last[i]) === -1 &&
                           LOWER_CASE.indexOf(last[i]) === -1 &&
                           NUMBERS.indexOf(last[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(last[i]) === -1)
                        {
                            isValid = false;
                            alert("Last is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(address_1 === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < address_1.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(address_1[i]) === -1 &&
                           LOWER_CASE.indexOf(address_1[i]) === -1 &&
                           NUMBERS.indexOf(address_1[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(address_1[i]) === -1)
                        {
                            isValid = false;
                            alert("Address 1 is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(address_2 === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < address_2.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(address_2[i]) === -1 &&
                           LOWER_CASE.indexOf(address_2[i]) === -1 &&
                           NUMBERS.indexOf(address_2[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(address_2[i]) === -1)
                        {
                            isValid = false;
                            alert("Address 2 is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(city === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < city.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(city[i]) === -1 &&
                           LOWER_CASE.indexOf(city[i]) === -1 &&
                           NUMBERS.indexOf(city[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(city[i]) === -1)
                        {
                            isValid = false;
                            alert("City is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(state === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < state.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(state[i]) === -1 &&
                           LOWER_CASE.indexOf(state[i]) === -1 &&
                           NUMBERS.indexOf(state[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(state[i]) === -1)
                        {
                            isValid = false;
                            alert("State is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(zip === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < zip.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(zip[i]) === -1 &&
                           LOWER_CASE.indexOf(zip[i]) === -1 &&
                           NUMBERS.indexOf(zip[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(zip[i]) === -1)
                        {
                            isValid = false;
                            alert("Zip is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(phone_office === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < phone_office.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(phone_office[i]) === -1 &&
                           LOWER_CASE.indexOf(phone_office[i]) === -1 &&
                           NUMBERS.indexOf(phone_office[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(phone_office[i]) === -1)
                        {
                            isValid = false;
                            alert("Office Phone is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(phone_mobile === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < phone_mobile.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(phone_mobile[i]) === -1 &&
                           LOWER_CASE.indexOf(phone_mobile[i]) === -1 &&
                           NUMBERS.indexOf(phone_mobile[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(phone_mobile[i]) === -1)
                        {
                            isValid = false;
                            alert("Office Mobile is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(email === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < email.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(email[i]) === -1 &&
                           LOWER_CASE.indexOf(email[i]) === -1 &&
                           NUMBERS.indexOf(email[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(email[i]) === -1)
                        {
                            isValid = false;
                            alert("Email is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                if(notes === "")
                {
                    //ok
                }
                else
                {
                    for (let i = 0; i < notes.length; i++) 
                    {
                        if(UPPER_CASE.indexOf(notes[i]) === -1 &&
                           LOWER_CASE.indexOf(notes[i]) === -1 &&
                           NUMBERS.indexOf(notes[i]) === -1 &&
                           SPECIAL_CHARACTERS.indexOf(notes[i]) === -1)
                        {
                            isValid = false;
                            alert("Notes is invalid. Allowed chaacters are letter, numbers, and !@#$%^&*()-_=+[]{}|;:,.<>?");
                            break;
                        }                                                            
                    }
                }
                return isValid;
            } 
            function clearSelected()
            {
                var elements = document.getElementById("group_ids").options;

                for(var i = 0; i < elements.length; i++)
                {
                    elements[i].selected = false;
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
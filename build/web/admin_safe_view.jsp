<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="java.util.ArrayList"%>

<%
    String context_dir = request.getServletContext().getRealPath("");
//LinkedHashMap props = support.config.get_config(context_dir);
    SimpleDateFormat timestamp_format = new SimpleDateFormat("yyyyMMddHHmmss");
//SimpleDateFormat display_format = new SimpleDateFormat("HH:mm / MM/dd/yyyy");//18:31 / 14-Jan-19
    SimpleDateFormat date_time_picker_format = new SimpleDateFormat("HH:mm MM/dd/yyyy");//01:00 01/27/2020    
    Connection con = null;
    boolean is_admin = false;
    if (session.getAttribute("authenticated") == null) {
        String login_url = "index.jsp";
        response.sendRedirect(login_url + "?result=fail&message=Session Timed Out?");
    } else {
        try {
            if (session.getAttribute("is_admin").toString().equalsIgnoreCase("1")) {
                is_admin = true;
            }
        } catch (Exception e) {
            is_admin = false;
        }
        
        if (is_admin) {
            try {
                con = db.db_util.get_connection(session);
            } catch (Exception e) {
                System.out.println("Exception in admin_safe_view.jsp=" + e);
            }
            String safe_id = request.getParameter("safe_id");
            String safe_info[] = db.safe.safe_info(con, safe_id);
            ArrayList<String[]> passwords = db.password.safe_and_passwords_for_safe_id(con, safe_id, session);
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <jsp:include page='header.jsp'>
            <jsp:param name="menu" value="admin"/>
        </jsp:include> 
    </head>
    <body class="d-flex flex-column">
        <!-- Responsive navbar-->
        <jsp:include page='nav_bar.jsp'>
            <jsp:param name="menu" value="admin"/>
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
                                    <li class="breadcrumb-item" aria-current="page"><a href="safes.jsp"><i class="bi bi-safe-fill"></i>&nbsp;Safes</a></li>
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin.jsp"><i class="bi bi-gear-fill"></i>&nbsp;Admin</a></li>
                                    <li class="breadcrumb-item" aria-current="page"><a href="admin_safes.jsp"><i class="bi bi-safe-fill"></i>&nbsp;Safe Admin</a></li>
                                    <li class="breadcrumb-item active" aria-current="page"><i class="bi bi-safe"></i>&nbsp;Safe View</li>
                                </ol>
                            </nav>
                            <div class="card">

                                <div class="dropdown">
                                    <div class="card-header ">
                                        <div class="row">
                                            <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                                View Safe&nbsp;
                                                <b><%=safe_info[2]%></b>
                                            </div>
                                            <div class="col-xl-9 col-lg-4 col-md-6 col-sm-12 d-flex justify-content-end">
                                                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false">
                                                    Actions
                                                </button>
                                                <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
                                                    <li><a class="dropdown-item" href="admin_safe_new.jsp">Create new Safe</a></li>
                                                    <li><a class="dropdown-item" href="admin_password_new.jsp?safe_id=<%=safe_id%>">Add a Password to this Safe</a></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="row mb-3">
                                        <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                            <label for="name" class="form-label">Name*</label>
                                            <input readonly type="text" id="name" name="name" class="form-control" value="<%=safe_info[2]%>"/>
                                        </div>
                                        <div class="col-xl-3 col-lg-4 col-md-6 col-sm-12">
                                            <label for="owner" class="form-label">Owner*</label>
                                            <input readonly type="text" id="owner" name="owner" class="form-control" value="<%=safe_info[2]%>"/>
                                        </div>
                                        <div class="col-xl-6 col-lg-6 col-md-6 col-sm-12">
                                            <label for="description" class="form-label">Description*</label>
                                            <input readonly type="text" id="description" name="description" class="form-control" value="<%=safe_info[3]%>"/>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <hr>
                                    </div>
                                    <div class="row">
                                        <div class="col-12">
                                            <h6>Passwords in Safe <b><%=safe_info[2]%></b></h6>
                                            <table id="table" class="table table-striped" style="width:100%">
                                                <thead>
                                                    <tr>
                                                        <th>Name</th>
                                                        <th>Description</th>
                                                        <th>Password</th>
                                                        <th>Expires</th>
                                                        <th>Created</th>
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
                                                                password_expires = date_time_picker_format.format(date);
                                                            }
                                                            catch(Exception e)
                                                            {
                                                                password_expires = "";
                                                            }
                                                            String password_created = "";
                                                            try
                                                            {
                                                                java.util.Date date = timestamp_format.parse(password[10]);
                                                                password_created = date_time_picker_format.format(date);
                                                            }
                                                            catch(Exception e)
                                                            {
                                                                password_created = "";
                                                            }
                                                            String password_owner = password[12];
                                                    %>
                                                    <tr>
                                                        <td NOWRAP>
                                                            <a href="admin_password_delete.jsp?id=<%=password[4]%>"><i style="cursor: pointer" class="bi bi-x-lg critical"></i></a>
                                                            &nbsp;<i style="cursor: pointer" onclick="window.location.href = 'admin_password_edit.jsp?id=<%=password[4]%>'" class="bi bi-pencil-fill link-primary"></i>
                                                            &nbsp;<%=password_name%>
                                                        </td>
                                                        <td><%=password_dscription%></td>
                                                        <td>
                                                            <input type="password" name="password_password_<%=password[4]%>" id="password_password_<%=password[4]%>" value="<%=password_password%>"/>
                                                            <i onclick="toggle_password('password_password_<%=password[4]%>')" style="cursor: pointer" class="bi bi-eye "></i>
                                                        </td>
                                                        <td><%=password_expires%>
                                                        <td><%=password_created%>
                                                        <td><%=password_owner%></td>
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
    <jsp:include page='footer.jsp'>
        <jsp:param name="name" value="value"/>
    </jsp:include>  

    <!-- Bootstrap core JS-->
    <script src="js/jquery-3.7.1.min.js"></script>
    <script src="js/bootstrap.bundle.min.js"></script>
    <!-- Core theme JS-->
    <script src="js/scripts.js"></script>
    <script src="js/datatables.min.js"></script>
    <script>
        new DataTable('#table');
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
        } else {
            response.sendRedirect("safes.jsp");
        }
    }
%>
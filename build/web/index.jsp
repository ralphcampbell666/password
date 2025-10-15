<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.LinkedHashMap"%>
<%
boolean config_file_set = true;
String result = request.getParameter("result"); //fail or success
String message = request.getParameter("message");
//check config file
try
{
    String context_dir = request.getServletContext().getRealPath("");
    LinkedHashMap config_file = support.config.get_config(context_dir);
    String db = config_file.get("db").toString();
    String system_key = config_file.get("system_key").toString();
    String system_salt = config_file.get("system_salt").toString();
    String debug = config_file.get("debug").toString();
        
    if(db == null || system_key == null || system_salt == null)
    {
        config_file_set = false;
    }
}
catch(Exception e)
{
    config_file_set = false;
    //System.out.println("config_file_set=" + config_file_set );
}
if(config_file_set)
{
%>
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
    </head>
    <body class="d-flex flex-column min-vh-100">
        <!-- Responsive navbar-->
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
            <div class="container px-lg-5">
                <div class="navbar-brand" href="#"><img src="assets/images/lock_icon_16.png"/></image>&nbsp;Password Safe</div>                
            </div>
        </nav>
        <!-- Page Content-->
        <div class="container">
            <div class="row">
                <div class="mb-3">&nbsp;</div>
            </div>
            <div class="row justify-content-center">
                <div class="col-xxl-4 col-lg-5">
                    <div class="card">
                        <!-- Logo -->
                        <div class="card-header py-1 text-center bg-light-lighten">
                            <a href="template.html">
                                <span><img src="assets/images/lock_icon_32.png" alt="logo" height="32"></span>
                            </a>
                        </div>
                        <div class="card-body p-4">
                            <div class="text-center w-75 m-auto">
                                <h4 class="text-dark-50 text-center pb-0 fw-bold">Sign In</h4>
                                <p class="text-muted mb-4">Enter your Username and password to access Passwords.</p>
                            </div>
                            <form action="login" method="post">
                                
                                <%
                                String show_message = "none";
                                
                                if(result == null || result.equalsIgnoreCase("success"))
                                {
                                    show_message = "none";
                                }
                                else
                                {
                                    show_message = "inline";
                                }
                                %>
                                <div class="row" id="result_alert" style="display: <%=show_message%>;">
                                    <div class="col-12"> 
                                        <%
                                        if(show_message.equalsIgnoreCase("inline") && result.equalsIgnoreCase("success"))
                                        {
                                            %>
                                            <div class="alert alert-success" alert-dismissible role="alert">
                                                <button type="button" class="btn-close " data-bs-dismiss="alert" aria-label="Close"></button>
                                                <strong>Success </strong>
                                            </div>
                                            <%
                                        }
                                        else
                                        {
                                            %>
                                            <div class="alert alert-danger" alert-dismissible role="alert">
                                                <button type="button" class="btn-close " data-bs-dismiss="alert" aria-label="Close"></button>
                                                <strong>Login Failed: <%=message%></strong>
                                            </div>
                                            <%
                                        }
                                        %>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="email" class="form-label">Username</label>
                                    <input class="form-control" type="text" id="username" name="username" required="" placeholder="Enter your username">
                                </div>

                                <div class="mb-3">
                                    <!--<a href="pages-recoverpw.html" class="text-muted float-end"><small>Forgot your password?</small></a>-->
                                    <label for="password" class="form-label">Password</label>
                                    <div class="input-group input-group-merge">
                                        <input type="password" id="password" name="password" class="form-control" placeholder="Enter your password">
                                    </div>
                                </div>
                                <div class="mb-3 mb-0 text-center">
                                    <button class="btn btn-primary" type="submit"> Log In </button>
                                </div>

                            </form>
                        </div> <!-- end card-body -->
                    </div>
                    <!-- end card -->
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
    </body>
</html>
<%
}
else
{
    %>
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
        </head>
        <body class="d-flex flex-column min-vh-100">
            <!-- Responsive navbar-->
            <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
                <div class="container px-lg-5">
                    <div class="navbar-brand" href="#!"><image src="assets/images/lock_icon_16.png"/>&nbsp;Password Safe</div>                
                </div>
            </nav>
            <!-- Page Content-->
            <div class="container">
                <div class="row">
                    <div class="mb-3">&nbsp;</div>
                </div>
                <div class="row justify-content-center">
                    <div class="col-xxl-6 col-lg-7">
                        <div class="card">
                            <!-- Logo -->
                            <div class="card-header py-1 text-center bg-light-lighten">
                                <a href="template.html">
                                    <span><img src="assets/images/lock_icon_32.png" alt="logo" height="32"></span>
                                </a>
                            </div>
                            
                            <div class="card-body p-4">
                                <div class="text-center w-75 m-auto">
                                    <h4 class="text-dark-50 text-center pb-0 fw-bold">Initial Setup</h4>
                                    <p class="text-muted mb-4">Set the following values.</p>
                                </div>
                                <form name="this_form" action="setup" method="post">

                                    <%
                                    String show_message = "none";
                                    if(result == null || result.equalsIgnoreCase("success"))
                                    {
                                        show_message = "none";
                                    }
                                    else
                                    {
                                        show_message = "inline";
                                    }
                                    %>
                                    <div class="row" id="result_alert" style="display: <%=show_message%>;">
                                        <div class="col-12"> 
                                            <%
                                            if(show_message.equalsIgnoreCase("inline") && result.equalsIgnoreCase("success"))
                                            {
                                                %>
                                                <div class="alert alert-success" alert-dismissible role="alert">
                                                    <button type="button" class="btn-close " data-bs-dismiss="alert" aria-label="Close"></button>
                                                    <strong>Success </strong>
                                                </div>
                                                <%
                                            }
                                            else
                                            {
                                                %>
                                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                    <br><strong>Set up Failed: <%=message%></strong>
                                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                                </div>
                                                <%
                                            }
                                            %>
                                        </div>
                                    </div>                                    
                                    <div class="mb-3">
                                        <label for="password" class="form-label">Admin's Password&nbsp;&nbsp;&nbsp;<em><small>(*Required)</small></em></label>
                                        <div class="input-group input-group-merge">
                                            <input type="password" id="admins_password" name="admins_password" class="form-control" required="" placeholder="Set Admin's password">
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label for="db" class="form-label">Database directory <em><small>(*Required--  Apache Tomcat needs read/write access to this directory)</small></em></label>
                                        <input class="form-control" type="text" id="db" name="db" required="" placeholder="Example c:/apps/password/database or /opt/password/database">
                                    </div>

                                    <div class="mb-3 mb-0 text-center">
                                        <button class="btn btn-primary" type="submit"> Run set up </button>
                                    </div>

                                </form>
                            </div>
                            <!-- end card-body -->
                        </div>
                        <!-- end card -->
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="mb-3">&nbsp;</div>
            </div>
            <!-- Footer-->
            <footer class="mt-auto py-2 bg-dark">
                <div class="container"><p class="text-center text-white">Copyright &copy; 2025</p></div>
            </footer>
            <!-- Bootstrap core JS-->
            <script src="js/bootstrap.bundle.min.js"></script>
            <!-- Core theme JS-->
            <script src="js/scripts.js"></script>
        </body>
    </html>
    
    
    
    
    <%
}
%>

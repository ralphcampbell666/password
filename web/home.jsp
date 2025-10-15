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

/*if(session.getAttribute("authenticated")==null)
{
    String login_url = "index.jsp";
    //response.sendRedirect(login_url + "?result=fail&message=Session Timed Out?");
}
else 
{
    String session_username = "";
    String session_user_email = "";
    try
    {
        //session_username = session.getAttribute("username").toString();
        //session_user_email = session.getAttribute("user_email").toString();
    }
    catch(Exception e)
    {
        session_username = "";
        session_user_email = "";
    }  
    try 
    {
        //con = db.db_util.get_contract_connection(context_dir, session);
    }
    catch(Exception e)
    {
        System.out.println("Exception in home.jsp=" + e);
    }
        
    */    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <jsp:include page='header.jsp'>
            <jsp:param name="page_type" value="normal"/>
        </jsp:include> 
    </head>
    <body class="d-flex flex-column">
        <!-- Responsive navbar-->
        <jsp:include page='nav_bar.jsp'>
            <jsp:param name="menu" value="home"/>
        </jsp:include>    
        <!-- Page Content-->
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    &nbsp;
                </div>
            </div>
            <div class="row">
                <div class="col-12">
                    <div class="card mx-auto">
                        <div class="card-body">
                            <!-- Start Content-->
                            <div class="row mb-2">
                                <div class="col-12">
                                    <a href="home.jsp"><i class="bi bi-house-fill"></i>&nbsp;Home</a>
                                </div>
                            </div>
                            <div class="card">
                                <div class="card-header">
                                    Safes
                                </div>
                                <div class="card-body">
                                    List of safes
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
    </body>
</html>
    <%
    //}
    %>
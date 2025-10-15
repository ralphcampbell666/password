<%
    String menu = "safes";
    try
    {
        menu = request.getParameter("menu");
        
        if(menu == null)
        {
            menu = "safes";
        }
    }
    catch (Exception e)
    {
        menu = "safes";
    }
    String home_active = "";
    String safes_active = "";
    String admin_active = "";
    String help_active = "";
    String logout_active = "";
    if (menu.equalsIgnoreCase("home")) {
        home_active = "active";
    } else if (menu.equalsIgnoreCase("safes")) {
        safes_active = "active";
    } else if (menu.equalsIgnoreCase("admin")) {
        admin_active = "active";
    } else if (menu.equalsIgnoreCase("help")) {
        help_active = "active";
    } else if (menu.equalsIgnoreCase("logout")) {
        logout_active = "active";
    }
    String session_username = "";
    try
    {
        session_username = session.getAttribute("username").toString();
    }
    catch(Exception e)
    {
    
    }   
%>
<!-- Fixed navbar -->
<nav class="navbar navbar-expand navbar-dark fixed-top bg-dark">
    <div class="container-fluid">
        <a href="safes.jsp" class="navbar-brand"><img src="assets/images/lock_icon_16.png"/>Password Safe</a>
        <div class="collapse navbar-collapse" id="navbarCollapse">
            <ul class="navbar-nav me-auto mb-2 mb-md-0">
                <li class="nav-item"><a class="nav-link <%=safes_active%>" href="safes.jsp">Safes</a></li>
                <li class="nav-item"><a class="nav-link <%=admin_active%>" href="admin.jsp">Admin</a></li>
                <li class="nav-item"><a class="nav-link <%=help_active%>" href="help.jsp">Help</a></li>
                <li class="nav-item"><a class="nav-link <%=logout_active%>" href="logout">Logout&nbsp;&nbsp;</a></li>
            </ul>
        </div>
        <%=session_username%>
    </div>
</nav>




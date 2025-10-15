
<%
if(session.getAttribute("authenticated")==null)
{
    String login_url = "index.jsp";
    response.sendRedirect(login_url);
}
else 
{
        
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
                <jsp:param name="menu" value="help"/>
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
                                    <li class="breadcrumb-item active" aria-current="page"><a href="help.jsp"><i class="bi bi-question-lg"></i>&nbsp;Help</a></li>
                                </ol>
                            </nav>
                            
                            <div class="row mb-3">
                                <div class="col-12">
                                    <h3>Help Topics</h3>
                                    <ul>
                                        <li><a href="#getting_started">Getting started</a></li>
                                        <li><a href="#manage_users">Managing Users and Groups</a></li>
                                        <li><a href="#managing_safes">Managing Safes</a></li>
                                        <li><a href="#backup_restore">Backup and Restore</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-12">
                                    <a id="getting_started"></a>
                                    <hr>                                    
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-12">
                                    <h5>Getting started</h5>
                                    Things to know about the Password app. All Passwords are stored encrypted. AES 256 is used to encrypt the Passwords
                                    The "Password" app has the following objects
                                    <ul>
                                        <li>Users</li>
                                        <li>Groups</li>
                                        <li>Safes</li>
                                        <li>Passwords</li>
                                    </ul>
                                    How the object work together:
                                    <ul>
                                        <li>Users are assigned to one or more Groups. Groups define access permissions to the Safes, Safes contain the Passwords</li>
                                        <li>Groups define access permissions to the Safes. Permissions are Create, Read, Update, Delete</li>
                                        <li>Permissions
                                            <ul>
                                                <li>Create - Members of the Group can Create new Passwords in this Safe. The "Create" permission inherits Read, Update, and Delete Safe permissions.</li>
                                                <li>Read - Members of the Group can Read all the passwords in this Safe.</li>
                                                <li>Update - Members of the Group can Update all the passwords in this Safe. The "Update" permission inherits "Read" permission.</li>
                                                <li>Delete - Members of the Group can Delete all the passwords in this Safe. The "Delete" permission inherits "Read" permission.</li>
                                            </ul>
                                        </li>
                                        <li>Passwords are assigned to zero or one Safe. If the Password is not assigned to a Safe, then the Password can not be seen. Unassigned (or orphaned) Passwords can be managed from the Admin menus</li>
                                        <li></li>
                                    </ul>
                                    Steps to follow after the initial installation
                                    <ul>
                                        <li>Create your user with admin permissions for daily admin functions  <em>(In addition to the one created during installation)</em></li>
                                        <li>Create create the other users</li>
                                        <li>Create the User Groups an assign the users to these Groups</li>
                                        <li>Create the Safe(s)</li>
                                        <li>Assign Groups to Safe(s)</li>
                                        <li>Add Passwords to the Safe(s)</li>
                                    </ul>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <a id="manage_users"></a>
                                <div class="col-12"><hr></div>
                            </div>                            
                            
                            <div class="row mb-3">
                                <div class="col-12">
                                    <h5>Managing Users and Groups</h5>   
                                    When adding/editing users, Username and Password are required. The "admin" user can not be deleted. 
                                    <br>
                                    Permissions to access a Safe is set within the Group definition. 
                                    <li>Permissions are:
                                        <ul>
                                            <li>Create - Members of the Group can Create new Passwords in this Safe. The "Create" permission inherits Read, Update, and Delete Safe permissions.</li>
                                            <li>Read - Members of the Group can Read all the Passwords in this Safe.</li>
                                            <li>Update - Members of the Group can Update all the Passwords in this Safe. The "Update" permission inherits "Read" permission.</li>
                                            <li>Delete - Members of the Group can Delete all the Passwords in this Safe. The "Delete" permission inherits "Read" permission.</li>
                                        </ul>
                                    </li>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <a id="managing_safes"></a>
                                <div class="col-12"><hr></div>
                            </div>
                                    
                            <div class="row mb-3">
                                <div class="col-12">
                                    <h5>Managing Safes</h5>  
                                    A Safe is the center of the Password application. Access is controlled by which Group(s) have CRUD permissions to access the Safe.  All Safes must have a Name, Owner, and Description. These fields are required to save a Safe.
                                </div>
                            </div>
                            <div class="row mb-3">
                                <a id="backup_restore"></a>
                                <div class="col-12"><hr></div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-12">
                                    <h5>Backup and Restore</h5>    
                                    Backup files are created by the Password app and are specific to Password. The backup file contains all the Passwords and are encrypted.  
                                    After clicking on the "Backup then Automatically Download" button, the backup file will be created and automatically downloaded to your browsers "Download" directory.
                                    <br>
                                    There are two options on Restoring the data.
                                    <ul>
                                        <li>The first option is to erase all existing data and restore everything from the backup file. Ensure you change the "admin" password immediately after using the restore all data option.</li>
                                        <li>The second option is to restore just Passwords. All the restored Passwords will be orphaned and need to be assigned to a Safe. To see and assign the orphaned Password, use the Password link on the Admin page.</li>
                                    </ul>
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
    </body>
</html>
    <%    
}
%>
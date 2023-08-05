<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage<CarPool.Models.AccountModel>" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>CarPool Administration Login</title>
    <link rel="Stylesheet" type="text/css" href="<%=ViewData["rootUri"] %>Content/Login.min.css" media="screen" title="default" />
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/jquery-1.9.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Common.min.js"></script>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Login.min.js"></script>
    <script language="javascript" type="text/javascript">
        var rootUri = "<%=ViewData["rootUri"] %>";
    </script>
</head>
<body id="login_bg">
    <% using (Html.BeginForm()) { %>
        <div class="login_box">
            <div class="error_msg">&nbsp;
                <%= Html.ValidationMessageFor(m => m.UserName) %>
                <%= Html.ValidationMessageFor(m => m.Password) %>
            </div>
            <ul>
                <li class="left_col"><b><%= Html.LabelFor(m => m.UserName) %></b></li>
                <li class="right_col">
                    <%= Html.TextBoxFor(m => m.UserName, new { @class="input" })%>
                </li>
            </ul>
            <ul>
                <li class="left_col"><b><%= Html.LabelFor(m => m.Password) %></b></li>
                <li class="right_col">
                    <%= Html.PasswordFor(m => m.Password, new { @class="input"})%>
                </li>
            </ul>
            <div class="check_remember">
                <%= Html.CheckBoxFor(m => m.RememberMe) %>
                <b><%= Html.LabelFor(m => m.RememberMe) %></b>
                <p>
                    <input type="submit" class="btn_submit" value="Log On"/>
                </p>
            </div>
            
            
        </div>
    <% } %>
</body>
</html>

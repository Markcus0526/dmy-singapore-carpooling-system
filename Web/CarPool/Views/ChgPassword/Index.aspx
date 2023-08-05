<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<CarPool.Models.ChgPasswordModel.ChangeModel>" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="Stylesheet" type="text/css" href="<%=ViewData["rootUri"] %>Content/ChgPassword.min.css" />
    <script language="javascript" type="text/javascript">
        var rootUri = "<%=ViewData["rootUri"] %>";
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<% using (Html.BeginForm())
    { %>
    <div class="content-sub-header">
        Change Manager Password / Change Password
    </div>
    <div class="error_msg">
        <%= Html.ValidationMessageFor(m => m.OldPassword) %>
        <%= Html.ValidationMessageFor(m => m.NewPassword) %>
        <%= Html.ValidationMessageFor(m => m.ConfirmPassword) %>
    </div>
    <ul style="margin-top:50px;">
        <li class="label"><b><%= Html.LabelFor(m => m.OldPassword) %></b></li>
        <li><%= Html.PasswordFor(m => m.OldPassword)%></li>
    </ul>
    <ul>
        <li class="label"><b><%= Html.LabelFor(m => m.NewPassword) %></b></li>
        <li><%= Html.PasswordFor(m => m.NewPassword) %></li>
    </ul>
    <ul>
        <li class="label"><b><%= Html.LabelFor(m => m.ConfirmPassword) %></b></li>
        <li><%= Html.PasswordFor(m => m.ConfirmPassword)%></li>
    </ul>
    <div class="btn_div">
        <button type="submit" id="btn_Change">&nbsp;</button>
    </div>
<% } %>
</asp:Content>
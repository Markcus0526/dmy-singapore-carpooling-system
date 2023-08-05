<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="CarPool.Models" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Xml" %>

<%
    IList<XmlNode> navList = CommonModel.GetNavigation((string)ViewData["selectedNav"]);
    if (ViewData["emptyLeftMenu"] == null)
    {
%>
<ul class="nav_main">
    <li class="nav_title"><%=navList[0].Attributes["menuName"].Value%>
        <ul class="nav_sub">
<%
foreach (XmlNode node in navList)
{
    if (node.Attributes["status"].Value == "sub")
    {
            %>
            <li class="nav_menu">
            <% if (node.Attributes["menuName"].Value == (string)ViewData["selectedMenu"])
               { %>
                <a class="nav_link link_selected" href="<%=ViewData["rootUri"] + node.Attributes["url"].Value %>"><%= node.Attributes["menuName"].Value%></a>
            <% }
               else
               { %>
                <a class="nav_link" href="<%=ViewData["rootUri"] + node.Attributes["url"].Value %>"><%= node.Attributes["menuName"].Value%></a>
            <% } %>        
            </li>
        <%
}
}
%>      </ul>
    </li>
</ul>
<% } %>
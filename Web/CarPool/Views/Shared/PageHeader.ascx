<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="CarPool.Models" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Xml" %>
<%
    List<string> menuNames = new List<string>();
    Dictionary<string, object> attr_menu = new Dictionary<string, object>();
    string style_attr = "background:url(" + ViewData["rootUri"] + "Content/Images/Site/head_banner.png) repeat-x; color:White;height:41px;font-size:1.2em";
    attr_menu.Add("style", (object)style_attr);
    menuNames.Add("User"); menuNames.Add("TSL"); menuNames.Add("Queue"); menuNames.Add("Admin");
    Html.Telerik().Menu()
	.Name("Menu")
    //.HtmlAttributes(new { style = "width: 300px; float: left;" })
    .OpenOnClick(true)
    .HtmlAttributes(attr_menu)
    /*.Effects(fx =>
    {
        fx.Slide();
        fx.OpenDuration(300)
            .CloseDuration(200);
    })*/
    .Items(menu =>
    {
        int j = 0;
        foreach (string menuName in menuNames)
        {
            IList<XmlNode> navList = CommonModel.GetNavigation(menuName);
            j++;
            if (navList.Count > 0)
            {
                menu.Add().Text(navList[0].Attributes["menuName"].Value)
                    .Items(item =>
                    {
                        for (int i = 1; i < navList.Count; i++)
                        {
                            Dictionary<string, object> attr = new Dictionary<string, object>();
                            attr.Add("title", (object)navList[i].Attributes["title"].Value);
                            attr.Add("style", (object)"text-align:left;");
                            item.Add().Text(navList[i].Attributes["menuName"].Value)
                                .Url(ViewData["rootUri"] + navList[i].Attributes["url"].Value)
                                .HtmlAttributes(attr)
                                .ImageUrl(ViewData["rootUri"] + "Content/Images/Site/menu-icon-"+j.ToString()+"-"+i.ToString()+".png");
                        }
                    });
            }
        }
    })
    .Render();
%>
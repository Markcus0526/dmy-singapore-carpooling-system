<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<IEnumerable<StructUserInfo>>" %>
<%@ Import Namespace="CarPool.Models" %>
<%@ Import Namespace="CarPool.Models.Users" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <title>CarPool Administration/User Management/User Information</title>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-sub-header">
        User Management / User Information
    </div>
    <div id="result" class="action-result"></div>
    <div class="search_condition">
        <% using (Html.BeginForm())
           { %>
        <div class='content-tool-bar'>
            <label>User Name : </label><input type="text" id="user_name" name="user_name" value="<%=ViewData["user_name"] %>" />
            &nbsp;&nbsp;
            <label>Phone Number : </label><input type="text" id="phone_number" name="phone_number" value="<%=ViewData["phone_number"] %>" />
            &nbsp;&nbsp;
            <label>Email Address : </label><input type="text" id="email_address" name="email_address" value="<%=ViewData["email_address"] %>" />
            &nbsp;&nbsp;
            <button id="btn_Search" type="submit">&nbsp;</button>
        </div>
        <% } %>
    </div>
    <div id="tbl_cnt">
    <%
        GridPagerStyles pagerStyles = GridPagerStyles.NextPreviousAndNumeric | GridPagerStyles.PageInput
                                    | GridPagerStyles.PageSizeDropDown | GridPagerStyles.NextPrevious
                                    | GridPagerStyles.Numeric;
        Html.Telerik().Grid(Model)
            .Name("usertable")
            .HtmlAttributes( new { style="font-size:9pt;" } )
            .DataKeys(keys =>
            {
                keys.Add(o => o.uid);
            })
             .ToolBar(commands => commands
                .Custom()
                    .HtmlAttributes(new { id = "export" })
                    .Text("Export to Excel File")
                    .Action("ExportExcel", "UserMng")
            )

            .Columns(columns =>
            {
                columns.Bound(o => o.show_uid)
                        .ClientTemplate("<input type='checkbox' name='checkedRecords' value='<#= uid #>' />")
                        .HeaderTemplate(() =>
                        {%><input type="checkbox" id="checkAllRecords" /><%})
                        .Title("")
                        .Width(30)
                        .HtmlAttributes(new { style = "text-align:center" })
                        .HeaderHtmlAttributes(new { style = "text-align:center" })
                        .Filterable(false)
                        .ReadOnly()
                        .Sortable(false);                
                columns.Bound(o => o.name).Template(c =>{%><a href='<% = ViewData["rootUri"]+"UserMng/UserInfoDetail/" + c.uid %>'><% = c.name%></a><% })
                    .Title("User Name")
                    .ReadOnly()
                    .Width(100);
                columns.Bound(o => o.show_gender)
                    .Title("Gender")
                    .Width(90)
                    .ReadOnly();
                columns.Bound(o => o.birthyear).Title("BirthYear").ReadOnly().Width(80);
                columns.Bound(o => o.phone_number).Title("Phone number").ReadOnly().Width(100);
                columns.Bound(o => o.email_address).Title("Email address").ReadOnly().Width(160);
                columns.Bound(o => o.credits).Title("Credits").Width(90);
                columns.Bound(o => o.total_savings).Title("Total Savings").ReadOnly();
                columns.Bound(o => o.last_login_date).Format("{0:yyyy/M/d HH:mm:ss}").Title("Last Login Time").Width(120).ReadOnly();
                columns.Command(commands =>
                {
                    commands.Edit().ButtonType(GridButtonType.Image);
                    commands.Delete().ButtonType(GridButtonType.Image);

                }).Width(100).Title("Action");

            })
            .DataBinding(dataBinding =>
            {
                //dataBinding.Ajax()
                dataBinding.Server()
                    //.Select("UserInfoView", "UserMng")
                    .Delete("_DeleteUser", "UserMng")
                    .Update("_UpdateCredit", "UserMng");
            })
            .Sortable()
            .Pageable(paging => paging.Style(pagerStyles))
            .Filterable()
            .Render();
    %>
    </div>

    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/UserInfoView.js"></script>
</asp:Content>

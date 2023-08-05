<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<IEnumerable<StructUserInfo>>" %>
<%@ Import Namespace="CarPool.Models.Users" %>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-sub-header">
        User Management / Deleted User
    </div>
    <div id="result" class="action-result">
        
    </div>
    <% using (Html.BeginForm())
        { %>
    <div class='content-tool-bar'>
        <label>User Name : </label><input type="text" id="user_name" name="user_name" value="<%=ViewData["user_name"] %>" />
        &nbsp;&nbsp;
        <label>Phone Number : </label><input type="text" id="phone_number" name="phone_number" value="<%=ViewData["phone_number"] %>" />
        &nbsp;&nbsp;
        <label>Email Address : </label><input type="text" id="Text1" name="email_address" value="<%=ViewData["email_address"] %>" />
        &nbsp;&nbsp;
        <button id="btn_Search" type="submit">&nbsp;</button>
    </div>
    <% } %>
    <div id="tbl_cnt">
        
        <% 
        GridPagerStyles pagerStyles = GridPagerStyles.NextPreviousAndNumeric | GridPagerStyles.PageInput
                                        | GridPagerStyles.PageSizeDropDown | GridPagerStyles.NextPrevious
                                        | GridPagerStyles.Numeric;
    
        %>
         <% Html.Telerik().Grid(Model)
                        .Name("UserGrid")
                        .HtmlAttributes(new { style = "font-size:9pt;" })
                        .DataKeys(keys =>
                        {
                            keys.Add(o => o.uid);
                        })
                        .Columns(columns =>
                        {
                            columns.Bound(o => o.uid)
                                   .ClientTemplate("<input type = 'checkbox' name= 'checkedRecords' value='<#= uid #>' />")
                                   .Title("")
                                   .HeaderTemplate(() =>
                                   {%><input type="checkbox" id="checkAllRecords"/> <%})
                                   .Width(30)
                                   .HtmlAttributes(new { style = "text-align:center" })
                                   .HeaderHtmlAttributes(new { style = "text-align:center" })
                                   .Filterable(false)
                                   .Sortable(false);
                            columns.Bound(o => o.name).ClientTemplate("<a href='"+ViewData["rootUri"]+"UserMng/UserInfoDetail/<#= uid #>'><#= name #></a>").Title("User name").Width(100);
                            columns.Bound(o => o.show_gender).Title("Gender");
                            columns.Bound(o => o.birthyear).Title("BirthYear");
                            columns.Bound(o => o.phone_number).Title("Phone number");
                            columns.Bound(o => o.email_address).Title("Email");
                            columns.Bound(o => o.credits).Title("Credits");
                            columns.Bound(o => o.total_savings).Title("Total Savings");
                            columns.Bound(o => o.last_login_date).Format("{0:yyyy/M/d HH:mm:ss}").Title("Last Login time");
                            /*
                            columns.Command(commands =>
                            {
                                commands.Custom("Delete").HtmlAttributes(new { onclick = "return confirm('Are you sure you want to delete this item?')" })
                                                    .Text("Delete").Ajax(true)
                                                    .ButtonType(GridButtonType.Image).ImageHtmlAttributes(new { @class = "t-icon t-delete t-test" })
                                                    .DataRouteValues(x => x.Add(y => y.uid).RouteKey("id"))
                                                    .SendState(false)
                                                    .Action("_RestoreUser", "UserMng", new { id = "<#= uid #>" });
                            }).Title("Restore");
                            */
                            /*columns.Command( commands =>
                                {
                                    commands.Delete().ButtonType(GridBu
                                    ttonType.ImageAndText);
                                }).Title( "Apply" ).Width(80);*/
                        })
                        .DataBinding(dataBinding =>
                        {
                            dataBinding.Ajax()
                                .Select("_RetrieveDeletedUser", "UserMng", new { userName = ViewData["user_name"], phoneNumber = ViewData["phone_number"], email_address = ViewData["email_address"] });
                                //.Delete("_RestoreUser", "UserMng");
                        })
                        .Sortable()
                        .Filterable(filtering => filtering.Enabled(true))
                        .Pageable()
                        .Render();

                %>
                <% Html.Telerik().ScriptRegistrar().OnDocumentReady(() => {%>
                    /* attach event handler to "check all" checkbox */
                    $('#checkAllRecords').click(function checkAll() {
                        $("#TaxiLocations tbody input:checkbox").attr("checked", this.checked);            
                    });
                <%}); %>
    </div>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script language="javascript" type="text/javascript">
        var rootUri = "<%=ViewData["rootUri"] %>";
    </script>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Common.min.js"></script>
</asp:Content>
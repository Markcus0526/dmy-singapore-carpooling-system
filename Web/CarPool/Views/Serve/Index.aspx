<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<IEnumerable<ServeInfo>>" %>
<%@ Import Namespace="CarPool.Models" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script language="javascript" type="text/javascript">
        var rootUri = "<%=ViewData["rootUri"] %>";
    </script>
    <link rel="Stylesheet" type="text/css" href="<%=ViewData["rootUri"] %>Content/Serve.min.css" />
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Common.min.js"></script>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Serve.min.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class='content-sub-header'>
        Taxi Stand Queue Stand / Serve Information
    </div>
    <div id="result" class="action-result">
    </div>
    <div class="search_condition">
        <% using (Html.BeginForm())
           { %>
        <div class='content-tool-bar'>
            <label>User Name : </label><input type="text" id="user_name" name="user_name" value="<%=ViewData["user_name"] %>"/>
            &nbsp;&nbsp;
            <label>Start Address : </label><input type="text" id="start_point" name="start_point" value="<%=ViewData["start_pos"] %>"/>
            &nbsp;&nbsp;
            <label>Dest Address : </label><input type="text" id="end_point" name="end_point" value="<%=ViewData["end_pos"] %>"/>
            &nbsp;&nbsp;
            <label>From Date : </label><% Html.Telerik().DateTimePicker().Name("from_date").Render(); %>
            &nbsp;&nbsp;
            <label>To Date : </label><% Html.Telerik().DateTimePicker().Name("to_date").Render(); %>
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
                        .Name("ServeList")
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
                                   .HtmlAttributes(new { style = "text-align:center" })
                                   .HeaderHtmlAttributes(new { style = "text-align:center"});
                            columns.Bound(o => o.serve_date).Title("Serve Date");
                            columns.Bound(o => o.user_name1)
                                .Title("Username")
                                .Width(140)
                                .ClientTemplate("<div><b>Username 1 : </b><#= user_name1 #></div>" + 
                                                "<div><b>Username 2 : </b><#= user_name2 #></div>");
                            //columns.Bound(o => o.user_name2).Title("User Name2");
                            columns.Bound(o => o.start_point).Title("Start Address");
                            columns.Bound(o => o.end_point1)
                                .Title("Dest Address")
                                .ClientTemplate("<div><b>Address 1 : </b><#= end_point1 #></div>" +
                                                "<div><b>Address 2 : </b><#= end_point2 #></div>");
                            
                            columns.Bound(o => o.saved_money1)
                                .Title("Saved Money")
                                .ClientTemplate("<div><b>Money 1 : </b><#= saved_money1 #></div>" +
                                                "<div><b>Money 2 : </b><#= saved_money2 #></div>");

                            columns.Bound(o => o.waste1)
                                .Title("Lost Time")
                                .ClientTemplate("<div><b>Time 1 : </b><#= waste1 #></div>" +
                                                "<div><b>Time 2 : </b><#= waste2 #></div>");
                            columns.Bound(o => o.score1)
                                .Title("Rating")
                                .ClientTemplate("<div><b>Rating 1 : </b><#= score1 #></div>" +
                                                "<div><b>Rating 2 : </b><#= score2 #></div>");
                                
//                            columns.Bound(o => o.end_point2).Title("Dest Address2");
                            //columns.Bound(o => o.saved_money2).Title("Saved Money2");
//                            columns.Bound(o => o.waste2).Title("Lost Time2");
                            //columns.Bound(o => o.score2).Title("Rating2");
                        })
                        .DataBinding(dataBinding =>
                        {
                            dataBinding.Ajax()
                                .Select("_RetrieveServeList", "Serve", new { userName = ViewData["user_name"], start_pos = ViewData["start_pos"], end_pos = ViewData["end_pos"], fromDate = ViewData["from_date"], toDate = ViewData["to_date"] });
                            
                        })
                        .ClientEvents(events => { events.OnComplete("onComplete"); })
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
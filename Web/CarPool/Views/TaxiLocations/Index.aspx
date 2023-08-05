<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<IEnumerable<TaxiStand>>" %>
<%@ Import Namespace="CarPool.Models.TaxiLocationsModel" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-sub-header">
        Taxi Stand Management / Taxi Stand Information
    </div>
    <div id="result" class="action-result">
        
    </div>
    <div class="search_condition">
        <% using (Html.BeginForm())
           { %>

        <div class='content-tool-bar'>
            <label>Taxi Stand name : </label><input type="text" id="stand_name" name="stand_name" value="<%=ViewData["standname"] %>" style='width:120px' />
            &nbsp;&nbsp;
            <label>GPS Adress : </label><input type="text" id="gps_address" name="gps_address" value="<%=ViewData["gps_addr"] %>" style='width:120px' />
            &nbsp;&nbsp;
            <button id="btn_Search" type="submit">&nbsp;</button>
            &nbsp;&nbsp;
            <button id="btn_Add" onclick="btn_add_click()" type="button">&nbsp;</button>
            &nbsp;&nbsp;
            <button id="btn_Delete" onclick="return DeleteSelectedItems()" type="button">&nbsp;</button>
        </div>
        <% } %>
    </div>
    <div id="tbl_cnt">
        
        <% 
        GridPagerStyles pagerStyles = GridPagerStyles.NextPreviousAndNumeric | GridPagerStyles.PageInput
                                        | GridPagerStyles.PageSizeDropDown | GridPagerStyles.NextPrevious
                                        | GridPagerStyles.Numeric;
    
        %>
         <% Html.Telerik().Grid(Model)
                        .Name("TaxiLocations")
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
                                   .HeaderHtmlAttributes(new { style = "text-align:center"});
                            columns.Bound(o => o.stand_no).Title("Stand No");
                            columns.Bound(o => o.stand_name).Title("Stand Name");
                            columns.Bound(o => o.gps_address).Title("GPS Address");
                            columns.Bound(o => o.post_code).Title("Post Code");
                            columns.Bound(o => o.longitude).Title("Longitude");
                            columns.Bound(o => o.latitude).Title("Latitude");
                            columns.Bound(o => o.taxi_stand_type).Title("Stand Type");
                        })
                        .DataBinding(dataBinding =>
                        {
                            dataBinding.Ajax()
                                .Select("_RetrieveTaxiList", "TaxiLocations", new { standname= ViewData["standname"], gps_addr= ViewData["gps_addr"] });
                        })
                        //.Editable(editing => editing.Mode(GridEditMode.PopUp))                        
                        .Pageable(paging => paging.Style(pagerStyles))
                        .Filterable()
                        .Sortable()
                        .Render();                                                                                        
                %>
                <% Html.Telerik().ScriptRegistrar().OnDocumentReady(() => {%>
                    /* attach event handler to "check all" checkbox */
                    $('#checkAllRecords').click(function checkAll() {
                        $("#TaxiLocations tbody input:checkbox").attr("checked", this.checked);            
                    });
                <%}); %>
                <% Html.Telerik().Window()
                .Name("ViewGoogleMap")
                .Visible(false)
                .Draggable(true)
                .Title("回答")
                .Modal(true)
                .Width(800)
                .Height(600)
                .Content(() =>
                {
                %>

                <div id='google_search' style='display:none;'>
                    <div id='google_map'>
            
                    </div> 
                </div>
                <%
                }).Render(); 
                    %>
                
           
    </div>

	<script>

    <% var serializer = new System.Web.Script.Serialization.JavaScriptSerializer(); %>
    var taxipoints = <%= serializer.Serialize(ViewData["taxipoints"]) %>;
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <script language="javascript" type="text/javascript">
        var rootUri = "<%=ViewData["rootUri"] %>";
        var points_data = '<%=ViewData["points-data"] %>';
    </script>
    <link rel="Stylesheet" type="text/css" href="<%=ViewData["rootUri"] %>Content/TaxiLocations.min.css" />
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Common.min.js"></script>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/TaxiLocations.js"></script>

</asp:Content>
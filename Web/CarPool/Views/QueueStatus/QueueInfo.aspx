<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<IEnumerable<TLQueueType>>"%>
<%@ Import Namespace="CarPool.Models" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="Stylesheet" type="text/css" href="<%=ViewData["rootUri"] %>Content/QueueInfo.min.css" />
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/QueueInfo.min.js"></script>
    <script language="javascript" type="text/javascript">
        var rootUri = "<%= ViewData["rootUri"] %>";
    </script>
</asp:Content>
<asp:Content ID="Content7" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-sub-header">
        Taxi Stand Queue Status/Queue Status Information
    </div>

    <div class="search_Box">

       <% using (Html.BeginForm())
           { %>

       <div class="Search-tool-bar">
            <label>User Name :</label>
            <input type= "text" id="UserName" name="UserName" value="<%=ViewData["UserName"] %>" style = "width:80px;"/>
            &nbsp;&nbsp;
            <label>Taxi Stand Name :</label>
            <input type= "text" id="TLName" name="TLName" value="<%=ViewData["TLName"] %>" style="width:90px"/>
            &nbsp;&nbsp;
            <label>Destination :</label>
            <input type= "text" id="Destination" name="Destination" value="<%=ViewData["Destination"] %>" style="width:90px;"/>
            &nbsp;&nbsp;
            <label>People_Num :</label>
            <input type= "text" id="PeoPleNum"  name="People_Num" value="<%=ViewData["PeoPleNum"] %>" style="width:90px;"/>
            &nbsp;&nbsp;
             <label>Gender :</label>
            
                <%
                    var str = "<select id = 'Same_Gender' name = 'GenderType' style='width:100px;'>";
                    if (ViewData["Same_Gender"].Equals("Male"))
                    {
                        str += "<option selected='selected'>Male</option>";
                        str += "<option>Female</option>";
                        str += "<option>Mixed</option>";
                    }
                    else if (ViewData["Same_Gender"].Equals("Female"))
                    {
                        str += "<option>Male</option>";
                        str += "<option selected='selected'>Female</option>";
                        str += "<option>Mixed</option>";
                    }
                    else                        
                    {
                        str += "<option>Male</option>";
                        str += "<option>Female</option>";
                        str += "<option selected='selected'>Mixed</option>";
                    }                    
                    str += "</select>";
                    
                    %>
                <%= str %>      
            <br/>
            <br/>
            <label>Enter Time :</label>
            <% Html.Telerik().DateTimePicker().Name("EnterTime").HtmlAttributes(new { style = "width:180px;" }).Render(); %>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label>To :</label>
            <% Html.Telerik().DateTimePicker().Name("EnterTimeto").HtmlAttributes(new { style = "width:180px;" }).Render(); %>
           &nbsp;&nbsp;&nbsp;&nbsp;
            <button id="btn_Search" type="submit">&nbsp;</button>
            <!-- <button id="btn_Delete" onclick="return DeleteSelectedItems()">&nbsp;</button>  -->  <!-- FixMe 2013/11/06  -->
            <% } %>
       </div>
       </div>
       <div id="tbl_cnt">       
       <script type="text/javascript">
           function getLocalTime(rd) {
               if (rd != null) {
                   //var rd2 = new Date(rd.getUTCFullYear(), rd.getUTCMonth(), rd.getUTCDate(), rd.getUTCHours(), rd.getUTCMinutes(), rd.getUTCSeconds());
                   var serverOffset = -(8 * 3600000); //UTC(GMT) - ServerTime: (Beijing Time)
                   var clientOffset = rd.getTimezoneOffset() * 60000;   //UTC(GMT) - LocalTime

                   var curtimes = rd.getTime();

                   curtimes = curtimes + clientOffset - serverOffset;
                   return new Date(curtimes);
               }
               return "";
           }       
       </script>
            <% 
                GridPagerStyles pagerStyles = GridPagerStyles.NextPreviousAndNumeric | GridPagerStyles.PageInput
                                            | GridPagerStyles.PageSizeDropDown | GridPagerStyles.NextPrevious
                                            | GridPagerStyles.Numeric;
    
                Html.Telerik().Grid(Model)
                        .Name("tlqueue")
                        .DataKeys(keys =>
                        {
                            keys.Add(o => o.u_id);
                        })
                        .DataBinding(dataBinding =>
                        {
                            dataBinding.Ajax()
                                .Select("_RetrieveQueueList", "QueueStatus", new { UserName = ViewData["UserName"], TLName = ViewData["TLName"], Destination = ViewData["Destination"], PeoPleNum = ViewData["PeoPleNum"], GenderType = ViewData["Same_Gender"], EnterTime = ViewData["EnterTime"], EnterTimeto = ViewData["EnterTimeTo"] });
                        })
                        .Columns(columns =>
                        {
                            columns.Bound(o => o.u_id)
                                   .ClientTemplate("<input type='checkbox' name='checkedRecords' value='<#= u_id #>' />")
                                   .HeaderTemplate(() =>
                                   {%><input type="checkbox" id="checkAllRecords" /><%})
                                   .Title("")
                                   .Width(30)
                                   .HtmlAttributes(new { style = "text-align:center" })
                                   .HeaderHtmlAttributes(new { style = "text-align:center" })
                                   .Filterable(false)
                                   .Sortable(false);
                            columns.Bound(o => o.TLName).Title("Taxi Stand");
                            columns.Bound(o => o.GroupMode).Title("Group No");
                            columns.Bound(o => o.EnterTime)
                                .Title("Times")
                                .ClientTemplate("<div><b>Login Time:</b><#= $.telerik.formatString('{0:yyyy-MM-dd HH:mm:ss}', EnterTime) #></div><div><b>CheckoutTime:</b> <#= checkoutTime != null ? $.telerik.formatString('{0:yyyy-MM-dd HH:mm:ss}', checkoutTime) : '' #></div>");
                            columns.Bound(o => o.UserName).Title("User Name");
                            columns.Bound(o => o.People_Num).Title("PeopleNum");
                            columns.Bound(o => o.Destination).Title("Destination");
                            columns.Bound(o => o.GenderType).Title("Gender");
                            columns.Bound(o => o.TopColor).Title("Top Color");
                            columns.Bound(o => o.Otherfeatrue).Title("Other feature");
                            //columns.Bound(o => o.checkoutTime).Format("{0:" + CommonModel.getDisplayDateTimeFormat() + "}").Title("CheckOut Time");
                        })
                        .Pageable()
                        .Render();
                %>
                <% Html.Telerik().ScriptRegistrar().OnDocumentReady(() => {%>
                    $('#checkAllRecords').click(function checkAll() {
                        $("#gifttable tbody input:checkbox").attr("checked", this.checked);            
                    });
                <%}); %>
       </div>
</asp:Content>

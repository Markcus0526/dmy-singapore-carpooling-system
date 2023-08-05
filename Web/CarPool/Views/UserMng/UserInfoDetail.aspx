<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="CarPool.Models" %>
<%@ Import Namespace="CarPool.Models.Users" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <title>CarPool Administration/User Management/User Information Detail</title>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/UserInfoDetail.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-sub-header">
        User Management / User Information Detail
    </div>
    <div id="result" class="action-result"></div>
    <div class="detail_content">
        <!-- <div class="label_detail" style="text-align:center"><img class="input_detail"  style= "width:120px; height:120px" src="<%= ViewData["rootUri"] %><%= ViewData["photo"] %>"/></div> -->
        <div class="label_detail" style="text-align:center"><img class="input_detail"  style= "width:120px; height:120px" src="data:image/jpeg;base64, <%= ViewData["photo"] %>"/></div>
        <div class="label_detail">User name : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["name"] %>" /></div>
        <div class="label_detail">Sex : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["gender"] %>" /></div>
        <div class="label_detail">Year of Birthday : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["age"] %>" /></div>
        <div class="label_detail">Phone number : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["phone_number"] %>" /></div>
        <div class="label_detail">Email : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["email_address"] %>" /></div>
        <div class="label_detail">Credits : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["credits"] %>" /></div>
        <div class="label_detail">Total savings : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["total_savings"] %>" /></div>
        <div class="label_detail">Registed Date : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["regist_date"] %>" /></div>
        <div class="label_detail">Delay time : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["delay_time"] %>" /></div>
        <div class="label_detail">Last Login Date : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["last_login_date"] %>" /></div>
        <div class="label_detail">Password : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["password"] %>" /></div>
        <div class="label_detail">Is grouping : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["is_grouping"] %>" /></div>
        <div class="label_detail">Individal gender : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["ind_gender"] %>" /></div>
        <div class="label_detail">Group gender : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["grp_gender"] %>" /></div>
        <div class="label_detail">Rating : <input type="text" readonly="readonly" class="input_detail" value="<%= ViewData["rating"] %>" /></div>
        <br />
        <button id="btn_return" style="margin-top:10px;">&nbsp;</button>
    </div>
</asp:Content>

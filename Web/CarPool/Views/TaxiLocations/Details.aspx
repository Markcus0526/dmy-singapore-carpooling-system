<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div>
    <div class='content-sub-header'>
        Taxi Stand Management / Detail Taxi Stand
    </div>
    <div style='padding:20px'>
    
    
    
    <table style='width:100%;' border="0">
        <tr>
            <td style='width:380px;'>
                <% using (Html.BeginForm()) { %>
                <input type="hidden" id='uid' name='uid' value='<%= ViewData["uid"] %>' />
                <table border="0" class='info_tbl'>
                    <tr height='50px'>
                        <td width='120px' align=right>Taxi Stand no : </td>
                        <td><input type='text' id='Text1'  name='stand_no' style='width:300px' value = '<%= ViewData["taxi_stand_no"] %>' /></td>
                    </tr>
                    <tr height='50px'>
                        <td width='120px' align=right>Taxi Stand name : </td>
                        <td><input type='text' id='stand_name'  name='stand_name' style='width:300px' value = '<%= ViewData["taxi_stand_name"] %>' /></td>
                    </tr>
                    <tr height='50px'>
                        <td align=right>GPS Address : </td>
                        <td><input type='text' id='gps_address' name='gps_address' style='width:300px' value = '<%= ViewData["gps_address"] %>' /></td>
                    </tr>
                    <tr height='50px'>
                        <td align=right>Post code : </td>
                        <td><input type='text' id='Text2' name='post_code' style='width:300px' value = '<%= ViewData["post_code"] %>' /></td>
                    </tr>
                    <tr height='50px'>
                        <td align=right>Longitude : </td>
                        <td><input type='text' id='longitude' name='longitude' style='width:300px' value = '<%= ViewData["longitude"] %>' /></td>
                    </tr>
                    <tr height='50px'>
                        <td align=right>Latitude : </td>
                        <td><input type='text' id='latitude' name='latitude'  style='width:300px' value = '<%= ViewData["latitude"] %>' /></td>
                    </tr>
                    <tr height='50px'>
                        <td align=right>Taxi Stand Type : </td>
                        <%
                            var str = "<select  id='taxi_stand_type' name='taxi_stand_type' style='width:184px'>";
                            if (ViewData["taxi_stand_type"].Equals("TAXI STAND"))
                            {
                                str += "<option selected='selected'>TAXI STAND</option>";
                                str += "<option>TAXI STOP</option>";
                                str += "<option>TAXI PICK UP \\/ DROP OFF</option>";
                            }else if (ViewData["taxi_stand_type"].Equals("TAXI STOP")){
                                str += "<option>TAXI STAND</option>";
                                str += "<option selected='selected'>TAXI STOP</option>";
                                str += "<option>TAXI PICK UP \\/ DROP OFF</option>";
                            }
                            else
                            {
                                str += "<option>TAXI STAND</option>";
                                str += "<option>TAXI STOP</option>";
                                str += "<option selected='selected'>TAXI PICK UP \\/ DROP OFF</option>";
                            }                    
                            str += "</select>";
                    
                         %>
                        <td><%= str %></td>

                    </tr>
                    <tr height=60>
                        <td colspan=2 align=center> <input type='submit' id="btn_update" onclick='return checkValid();' value='' />
                <input type='button' id="btn_return" onclick='cancels();'  value='' /></td>
                    </tr>
                </table>
                <% } %>
            </td>
            <td>
                <div id='detailMap'>               
                <img src='<%= ViewData["rootUri"] %>Content/Images/TaxiLocations/edit-point.png' style='position:absolute; top:200px;left:600px' alt='edit-point' />                                 
                
                </div>
            </td>
        </tr>
    </table>
    </div>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <script language="javascript" type="text/javascript">
        var rootUri = "<%=ViewData["rootUri"] %>";
    </script>
    <link rel="Stylesheet" type="text/css" href="<%=ViewData["rootUri"] %>Content/TaxiLocations.min.css" />
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Common.min.js"></script>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Detail_TaxiLocations.min.js"></script>
</asp:Content>
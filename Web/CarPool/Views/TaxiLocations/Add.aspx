<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div >
    <div class='content-sub-header'>
        Taxi Stand Management / Add Taxi Stand&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GPS Address:
        <input type="text" id="target" name="target" title="Address to Geocode" style="width:200px"  />
        &nbsp;&nbsp;&nbsp;&nbsp;
        <input type="button" id="btnSearch" onclick="search();" value="Search" />
    </div>
    <div id="serachMap">
    </div>
    <div id='addMap'>
<!--         <div id='google_map' onmousedown='clickMap()'> -->
<!--              -->
<!--         </div> -->
		<div id="gmap_marker" class="gmaps" style="height:580px;"></div>

        <div id='add-dialog'>
        <div id='dlg-header'>
            <button id='close-dlg' onclick='closeMe()'>Close</button>
        </div>
        <div id='dlg-body' align=center>
        
        <table width=100% >
            <tr height=35>
                <td width='90px'>Taxi Stand no </td>
                <td><input type='text' id='Text1'  name='stand_name' style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td width='90px'>Taxi Stand name </td>
                <td><input type='text' id='stand_name'  name='stand_name' style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td>GPS Address </td>
                <td><input type='text' id='gps_address' name='gps_address'  style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td width='90px'>Post code </td>
                <td><input type='text' id='Text2'  name='stand_name' style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td>Longitude</td>
                <td><input type='text' id='longitude' name='longitude' style='width:135px;'  /></td>
            </tr>
            <tr height=35>
                <td>Latitude</td>
                <td><input type='text' id='latitude' name='latitude' style='width:135px;'  /></td>
            </tr>
            <tr height=35>
                <td>Taxi Stand Type </td>
                <td>
                <select  id='taxi_stand_type' name='taxi_stand_type' style='width:135px;'>
                    <option>TAXI STAND</option>
                    <option>TAXI STOP</option>
                    <option>TAXI PICK UP \\/ DROP OFF</option>
                </select>
                </td>
            </tr>
        </table>
        <br />
        
        <input type='button' id="btn_Add" onclick='addPoint();'/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type='button' id="btn_return" onclick='cancels();'/>
        </div>
    </div>

    <div id='point-info-dlg'>
        <div id='point-info-dlg-header'>
            <button id='point-info-dlg-close'>Close</button>
        </div>
        <div id='point-info-dlg-body' align=center>
        
        <table width=100% >
            <tr height=35>
                <td width='90px'>Taxi Stand no </td>
                <td><input type='text' id='Text3' style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td width='90px'>Taxi Stand name </td>
                <td><input type='text' id='info_stand_name' style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td>GPS Address </td>
                <td><input type='text' id='info_gps_address' style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td width='90px'>Post code </td>
                <td><input type='text' id='Text4' style='width:135px;' /></td>
            </tr>
            <tr height=35>
                <td>Longitude</td>
                <td><input type='text' id='info_longitude' style='width:135px;'  /></td>
            </tr>
            <tr height=35>
                <td>Latitude</td>
                <td><input type='text' id='info_latitude' style='width:135px;'  /></td>
            </tr>
            <tr height=35>
                <td>Taxi Stand Type </td>
                <td>
                <select  id='info_stand_type'  style='width:135px;'>
                    <option value='TAXI STAND'>TAXI STAND</option>
                    <option value='TAXI STOP'>TAXI STOP</option>
                    <option value='TAXI PICK UP \\/ DROP OFF'>TAXI PICK UP \\/ DROP OFF</option>
                </select>
                </td>
            </tr>
        </table>        
        </div>
    </div>
    </div>
    </div>

	<script>

    <% var serializer = new System.Web.Script.Serialization.JavaScriptSerializer(); %>
    var taxipoints = <%= serializer.Serialize(ViewData["taxipoints"]) %>;

	    jQuery(document).ready(function () {
	        MapsGoogle.init();
	    });
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .taxistand-detail td
        {
            padding:5px;
        }
    </style>
    <script language="javascript" type="text/javascript">
        //var points_data = '<%=ViewData["points-data"] %>';
        var rootUri = "<%=ViewData["rootUri"] %>";
    </script>
    <link rel="Stylesheet" type="text/css" href="<%=ViewData["rootUri"] %>Content/TaxiLocations.min.css" />
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Common.min.js"></script>
    <!--<script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/Add_TaxiLocations.min.js"></script>-->

	<script src="http://maps.google.com/maps/api/js?sensor=false" type="text/javascript"></script>
	<script src="<%=ViewData["rootUri"] %>Scripts/User-Defined/gmaps.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript" src="<%=ViewData["rootUri"] %>Scripts/User-Defined/maps-google.js"></script>
</asp:Content>
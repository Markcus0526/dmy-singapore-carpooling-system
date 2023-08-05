var selectedEmployee = 0;

function DeleteSelectedItems() {
    var $checkedRecords = $(':checkbox[id!=checkAllRecords]:checked');

    if ($checkedRecords.length < 1) {
        alert('Please select more than 1 records');
        return false;
    }
    if (confirm("Really delete these records?"))
        $.ajax({
            type: "POST",
            url: rootUri + "TaxiLocations/_DeleteSelectedItems",
            dataType: "json",
            data: $checkedRecords,
            success: onSuccess,
            error: onError
        });

    return false;
}
function onSuccess(data) 
{
    if (data.success == "True") 
    {
        var grid = $("#TaxiLocations").data("tGrid");
        grid.rebind();
        $(".close-green").click(function () 
        {
            $("#message-green").fadeOut("slow");
        });
    } else{
        alert("Please Check Queue Information!");
    }
    return false;
}
function onComplete(e) {
    
}
function SearchItems() {
    $.ajax({
        type: "POST",
        url: rootUri + "TaxiLocations/_GetTaxiList",
        data: {
            name:$("#stand_name").val(),
            gps:$("#GPS_Addr").val()
        },
        success: onSuccess,
        error: onError
    });
}
function onError(xhr) {
    alert('Error! Status = ' + xhr.status);
}

function isAlphanumeric(chkVal) {

    return !/[^a-zA-Z0-9]/.test(chkVal);
}
function btn_add_click() {
    document.location.href = rootUri + "TaxiLocations/Add";
}
var b_show_map = 0;

function btn_google_click() {
    
    //var addWindow = $("#ViewGoogleMap").data("tWindow");
    //$("#google_search").dialog();
    //alert(1);
    var addWindow = $("#ViewGoogleMap").data("tWindow");
    $("#google_search").show();
    addWindow.title("Taxi Stand Map");
    addWindow.center().open();
    return false;

    
}

function draw_points(str_data) {
    var arr_row = str_data.split("<#ROW#>");
    var str_data = "";
    for (var i = 0; i < arr_row.length; i++) {
        var arr_obj = arr_row[i].split("<#COL#>");
        str_data += "<img src='" + rootUri + "Content/Images/TaxiLocations/taxi-point.png' style='position:absolute;left:" + arr_obj[2] + "px; top:" + arr_obj[3] + "px' onmouseover='onOverPoint(\"" + arr_obj[0] + "\",\"" + arr_obj[1] + "\",\"" + arr_obj[2] + "\",\"" + arr_obj[3] + "\",\"" + arr_obj[4] + "\")' onmouseout='onOutPoint()' />";
    }
    $("#google_map").html(str_data);

}
$(function () {
    draw_points(points_data);
});
function onOverPoint(stand_no, stand_name, gps_address, post_code, longitude, latitude, stand_type) {

    $('#info_stand_no').val(stand_no);
    $('#info_stand_name').val(stand_name);
    $('#info_gps_address').val(gps_address);
    $('#info_post_code').val(post_code);
    $('#info_longitude').val(longitude);
    $('#info_latitude').val(latitude);
    $('#info_stand_type').val(stand_type);
    //$('#point-info-dlg').css("left", longitude + "px");
    //$('#point-info-dlg').css("top", (Number(latitude) + 35) + "px");
    $('#point-info-dlg').show();
}
function onOutPoint() {
    $('#point-info-dlg').hide();
}

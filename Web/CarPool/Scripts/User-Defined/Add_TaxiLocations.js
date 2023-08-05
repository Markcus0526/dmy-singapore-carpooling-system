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
function clickMap() {
    var a = Math.random() * 1024;
    var b = Math.random() * 768;
    $('#stand_name').val("");
    $('#gps_address').val("");
    $('#longitude').val(a);
    $('#latitude').val(b);
    $('#stand_type').val("");
    $('#add-dialog').show();
}
function closeMe() {
    $('#add-dialog').hide();
}
function onOverPoint(stand_name, gps_address, longitude, latitude, stand_type) {

    $('#info_stand_name').val(stand_name);
    $('#info_gps_address').val(gps_address);
    $('#info_longitude').val(longitude);
    $('#info_latitude').val(latitude);
    $('#info_stand_type').val(stand_type);
    $('#point-info-dlg').css("left", longitude + "px");
    $('#point-info-dlg').css("top", (Number(latitude) + 40) + "px");
    $('#point-info-dlg').show();
}
function onOutPoint() {
    $('#point-info-dlg').hide();
}
function checkValid() {
    if ($("#stand_name").val() == "") {
        alert("please input Taxi Stand name.");
        return false;
    }
    if ($("#gps_address").val() == "") {
        alert("please input GPS Address.");
        return false;
    }
    return true;
}
function addPoint() {
    if (checkValid()) {
        $.ajax({
            async: false,
            type: "post",
            dataType: "json",
            url: rootUri + "TaxiLocations/AddPoint",
            data: { "stand_name": $("#stand_name").val(),
                "gps_address": $("#gps_address").val(),
                "longitude": $("#longitude").val(),
                "latitude": $("#latitude").val(),
                "stand_type": $("#taxi_stand_type").val()
            },
            success: function (res) {

                if (res.success == "ok") {
                    var str_data = $("#google_map").html();
                    str_data += "<img src='" + rootUri + "Content/Images/TaxiLocations/taxi-point.png' style='position:absolute;left:" + $("#longitude").val() + "px; top:" + $("#latitude").val() + "px' onmouseover='onOverPoint(\"" + $("#stand_name").val() + "\",\"" + $("#gps_address").val() + "\",\"" + $("#longitude").val() + "\",\"" + $("#latitude").val() + "\",\"" + $("#taxi_stand_type").val() + "\")' onmouseout='onOutPoint()' />";
                    $("#google_map").html(str_data);
                    closeMe();
                    alert("Successfully Added!");
                }
                else {
                    $("#span_Filter").html(res.retStr);
                }
            },
            error: ErrorProcess
        });
    }
}
function cancels() {
    document.location.href = rootUri + 'TaxiLocations';
}
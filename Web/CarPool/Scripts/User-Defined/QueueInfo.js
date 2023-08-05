var selectedEmployee = 0;

var succMsg = "Successfully Deleted！";
var noticeStartDiv = "<div id='message-green'>" +
                "<table border='0' width='100%' cellpadding='0' cellspacing='0'>" +
                "<tr><td class='green-left'>";
var noticeEndDiv = "</td>" +
                "<td class='green-right'><a class='close-green'><img src='" + rootUri + "Content/Images/icon_close_green.gif' alt='' /></a></td>" +
				"</tr></table></div>";
function DeleteSelectedItems() {
    var $checkedRecords = $(':checkbox[id!=checkAllRecords]:checked');

    if ($checkedRecords.length < 1) {
        alert('Please select more than 1 records');
        return false;
    }
    if (confirm("Really delete these records?"))
        $.ajax({
            type: "POST",
            url: rootUri + "QueueStatus/_DeleteSelectedItems",
            dataType: "json",
            data: $checkedRecords,
            success: onSuccess,
            error: onError
        });
    return false;
}
function onSuccess(data) {
    if (data.success == "True") {
        var grid = $("#tlqueue").data("tGrid");
        grid.rebind();
        $("#result").empty();
        $("#result").hide().append(noticeStartDiv + succMsg + noticeEndDiv).slideDown('slow');
        $(".close-green").click(function () {
            $("#message-green").fadeOut("slow");
        });

    }
    return false;
}
function onComplete(e) {

}
/*function SearchItems() {
    $.ajax({
        type: "POST",
        url: rootUri + "TaxiLocations/_GetTaxiList",
        data: {
            name: $("#stand_name").val(),
            gps: $("#GPS_Addr").val()
        },
        success: onSuccess,
        error: onError
    });
}*/
function onError(xhr) {
    alert('Error! Status = ' + xhr.status);
}

function isAlphanumeric(chkVal) {

    return !/[^a-zA-Z0-9]/.test(chkVal);
}

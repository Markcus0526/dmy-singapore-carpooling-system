$(document).ready(function () {
    $(".isNormal").mouseover(function () {
        //alert( "over" );
        $(this).removeClass("isClicked").removeClass("isNormal").addClass("isHover");
    });
    $(".isNormal").mouseout(function () {
        //alert( "out" );
        $(this).removeClass("isClicked").removeClass("isHover").addClass("isNormal");
    });
    $(".isNormal").mouseup(function () {
        //alert($(this).attr("id").substr(3));
        $(this).removeClass("isClicked").addClass("isNormal");
        window.open($(this).attr("id").substr(3), "_self");
    });
    $(".isNormal").mousedown(function () {
        $(this).removeClass("isNormal").addClass("isClicked");
    });
});

function ErrorProcess(res) {
    alert("Ajax Request Error : " + res);
}
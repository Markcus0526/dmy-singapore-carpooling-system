$(document).ready(function () {
    $("#UserName").focus();
    $("#UserName").change(function () {
        $.ajax({
            async: false,
            type: "post",
            dataType: "json",
            url: rootUri + "Login/UserName_Change",
            data: { "userName": $("#UserName").val() },
            success: function (res) {
                if (res.success == "ok") {
                    $("#RememberMe").attr("checked", "checked");
                    $("#Password").val(res.password);
                }
                else if (res.success == "no" || res.success == "null" ) {
                    $("#RememberMe").removeAttr("checked");
                    $("#Password").val("");
                }
                else
                    alert(res);
            },
            error: ErrorProcess
        });
    });
})
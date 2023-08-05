function ViewHtmlCommand(options) {
    var that = this;
    
    that.options = options;
    
    Command.call(that, options);
    
    that.attributes = null;
    
    that.async = true;

    that.exec = function () {
        var editor = that.editor,
            range = editor.getRange(),
            dialog = $(ViewHtmlCommand.template).appendTo(document.body),
            content = ViewHtmlCommand.indent(editor.value()),
            textarea = ".t-editor-textarea";

        function apply(e) {
            editor.value(dialog.find(textarea).val());

            close(e);

            if (that.change) {
                that.change();
            }
        }

        function close(e) {
            if (e) e.preventDefault();

            dialog.data("tWindow").destroy();

            windowFromDocument(documentFromRange(range)).focus();
        }

        dialog.tWindow($.extend({}, editor.dialogOptions, {
            title: "View HTML",
            close: close
        }))
            .hide()
            .find(textarea).val(content).end()
            .find(".t-dialog-update").click(apply).end()
            .find(".t-dialog-close").click(close).end()
            .show()
            .data("tWindow")
            .center();

        dialog.find(textarea).focus();
    };
}

$.extend(ViewHtmlCommand, {
    template: "<div><div class='t-editor-dialog'>" +
                "<textarea class='t-editor-textarea t-input'></textarea>" +
                "<div class='t-button-wrapper'>" +
                    "<button class='t-dialog-update t-button'>Update</button>" +
                    "&nbsp;or&nbsp;" +
                    "<a href='#' class='t-dialog-close t-link'>Close</a>" +
                "</div>" +
            "</div></div>",
    indent: function(content) {
        return content.replace(/<\/(p|li|ul|ol|h[1-6]|table|tr|td|th)>/ig, "</$1>\n")
                      .replace(/<(ul|ol)([^>]*)><li/ig, "<$1$2>\n<li")
                      .replace(/<br \/>/ig, "<br />\n")
                      .replace(/\n$/, "");
    }
});

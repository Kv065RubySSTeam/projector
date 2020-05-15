$(document).on('turbolinks:load', function () {
    $('body').on('click', '.export-btn', function (e) {
        var URL, uuid;
        uuid = generateUUID();
        // Disable Export btn
        $('.export-btn').addClass('bx-loader-circle')
        toastr.info("Export is in progress. Please, wait...");
        $('.export-btn').addClass('disabled');
        URL = decodeURI(e.target.href + '?export_id=' + uuid);
        // Subscribe to the channel
        window.subscribeToExportBoard(uuid, function () {
            $.get(encodeURI(URL));
        });

        e.preventDefault();
    });

    $('body').on('click', '.export-and-email-btn', function (e) {
        let sendUrl = e.target.href;
        $.get(sendUrl);
        e.preventDefault();
        toastr.info("Your data will be sent via email");
    });
});

generateUUID = function () {
    var d;
    d = new Date().getTime();
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r;
        r = (d + Math.random() * 16) % 16 | 0;
        d = Math.floor(d / 16);
        return (c === 'x' ? r : r & 0x3 | 0x8).toString(16);
    });
};

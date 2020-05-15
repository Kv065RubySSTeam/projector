import consumer from "./consumer"

window.subscribeToExportBoard = function(export_id, onConnect) {
    var subscription = consumer.subscriptions.create(
        {
            channel: "ExportChannel",
            export_id: export_id
        },
        {
            connected() {
                // Called when the subscription is ready for use on the server
                console.log('connected');
                onConnect();
            },

            disconnected() {
                // Called when the subscription has been terminated by the server
            },

            received(data) {
                console.log("received");

                var blob, csv_download_link;
                blob = new Blob([data['csv_file']['content']]);
                csv_download_link = document.createElement('a');
                csv_download_link.href = window.URL.createObjectURL(blob);
                csv_download_link.download = data['csv_file']['file_name'];
                csv_download_link.click();
                $(".export-btn").removeClass("disabled");
                $('.export-btn').removeClass('bx-loader-circle');
                window.URL.revokeObjectURL(blob);
                toastr.remove();
                toastr.success("Data was imported!");

                subscription.unsubscribe();
            }
        });
}

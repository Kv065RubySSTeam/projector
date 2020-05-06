const token = $('meta[name="csrf-token"]').attr('content');
window.makeAdmin = function (event) {
    const user = event.target.id;
    let url = event.target;
    event.preventDefault();
    fetch(url, {
        method: 'PUT',
        headers: { 'X-CSRF-Token': token },
        }).then((response) => {
            if(response.ok) {
                event.target.remove();
                toastr.success(`Success! <br\>`+`${user}`+` is an admin now!`);
            } else {
                toastr.error("Error! <br\>Details: " + response.statusText);
            }
        });
}

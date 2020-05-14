const token = $('meta[name="csrf-token"]').attr('content');
window.changeRights = function (event) {
    const user = event.target.id;
    let url = event.target;
    event.preventDefault();
    fetch(url, {
        method: 'PUT',
        headers: { 'X-CSRF-Token': token },
        }).then((response) => {
            if(response.ok) {
                if (document.getElementById(user).innerHTML === 'Add Admin') {
                    document.getElementById(user).parentNode.firstElementChild.classList.add("warning");
                    document.getElementById(user).innerHTML = 'Remove Admin';
                    toastr.success(`Success! <br\>`+`${user}`+` is an admin now!`);
                } else {
                    document.getElementById(user).parentNode.firstElementChild.classList.remove("warning");
                    document.getElementById(user).innerHTML = 'Add Admin';
                    toastr.success(`Success! <br\>`+`${user}`+` is not admin anymore!`);
                    if (document.getElementById("creator").value == user ) {
                        document.getElementById("addMember").remove();
                    }
                } 
            } else {
                toastr.error("Error! <br\>Details: " + response.statusText);
            }
        });
}

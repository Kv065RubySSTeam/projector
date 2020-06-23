const token = $('meta[name="csrf-token"]').attr('content');
window.changeRights = function (event) {
    const user = event.target.id;
    let url = event.target;
    const allButton = $('#user-section section div').find('.btn-sm.btn-dark');
    const creator = document.getElementById('creator').value;
    const edit_btn = $('.edit-board-btn');
    const remove_btn = $('#kanban-wrapper .destroy-board-btn');
    console.log(event, user);

    event.preventDefault();
    fetch(url, {
        method: 'PATCH',
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
                    if (creator == user ) {
                        for (let link of allButton) {
                            link.remove();
                        }
                        edit_btn.remove();
                        remove_btn.remove();
                        document.getElementById("addMember").remove();
                    }
                } 
            } else {
                toastr.error("Error! <br\>Details: " + response.statusText);
            }
        });
}

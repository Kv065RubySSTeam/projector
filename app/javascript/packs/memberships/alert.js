$(() => {
    $('#add-user').on('click', function () {
        Swal.fire({
            title: '<strong>Add User</strong>',
            icon: 'info',
            html: '<input class="form-control" data-search="template-search" id="autoComplete" tabindex="0" type="text" placeholder="Please enter user email...">' +
                '<input id="addMembershipURL" type="hidden" value="/boards/1/memberships">' + 
                '<div id="autoComplete_list"></div>',
            showCloseButton: true,
            showCancelButton: true,
            focusConfirm: false,
        })
    });
});

// $(() => {
//     $('#add-user').on('click', function () {
//         Swal.fire({
//             title: '<strong>Add User</strong>',
//             input: 'text',
//             showLoaderOnConfirm: true,
//             icon: 'info',
//             showCloseButton: true,
//             showCancelButton: true,
//             focusConfirm: false,
//             preConfirm: (login) => {
//                 return fetch(`/user.json?search=${login}`)
//                   .then(response => {
//                     if (!response.ok) {
//                       throw new Error(response.statusText)
//                     }
//                     return response.json()
//                   })
//                   .catch(error => {
//                     Swal.showValidationMessage(
//                       `Request failed: ${error}`
//                     )
//                   })
//               },
//               allowOutsideClick: () => !Swal.isLoading()
//             }).then((result) => {
//                 // debugger;
//                 let data = result.value;
//                 for(let i=0; i<data.length; i++) {
//                     if (data[i].email) {
//                         Swal.fire({
//                           title: `${data[i].email}'s chosen`,
//                         //   imageUrl: result.value.avatar_url
//                         })
//                       }
//                 }
//         })
//     });
// });
$(function () {
    const token = $('meta[name="csrf-token"]').attr('content');
    
    const autoCompletejs = new autoComplete({
        data: {
            src: async () => {
                const query = document.querySelector("#autoComplete").value;
                // Fetch External Data Source
                const source = await fetch(
                    `/users/index.json?search=${query}`
                    );
                    const data = await source.json();
                    // Post loading placeholder text
                // Returns Fetched data
                return data;
            },
            key: ["email"],
            cache: false
        },
        sort: (a, b) => {
            if (a.match < b.match) return -1;
            if (a.match > b.match) return 1;
            return 0;
        },
        placeHolder: "Please enter user email...",
        selector: "#autoComplete",
        threshold: 0,
        debounce: 300,
        searchEngine: "strict",
        highlight: true,
        maxResults: 10,
        resultsList: {
            render: true,
            container: source => {
                source.setAttribute("id", "autoComplete_list");
                source.setAttribute("style", "position:absolute; width: 95%");
            },
            destination: document.querySelector("#show-users"),
            position: "afterbegin",
            element: "div"
        },
        resultItem: {
            content: (data, source) => {
                source.setAttribute("class", "list-group-item list-group-item-action")
                source.innerHTML = data.match;
            },
            element: "li"
        },
        noResults: () => {
            const result = document.createElement("li");
            result.setAttribute("class", "list-group-item");
            result.innerHTML = "No Results";
            document.querySelector("#autoComplete_list").appendChild(result);
        },
        onSelection: membership => {
            const selectedUserId = membership.selection.value.id;
            // Clear Input
            document.querySelector("#autoComplete").value = "";
            // Change placeholder with the selected value
            // Concole log autoComplete data membership
            // Send request to server to add user
            let url = document.getElementById("addMembershipURL").value;
            fetch(url, 
            {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': token 
                },
                body: `{"user_id": ${selectedUserId}}`
              } 
              ).then((response) => {
                  if(response.ok) {
                        $("#user-section").load(" #user-section > *");
                        toastr.success("Success!");
                    } else if (response.status == 401) {
                        toastr.info("Danger! <br\>Details: " + response.statusText);
                    } else {
                        response.json().then(function (parsedJson) {
                            toastr.error("Error <br\>" + parsedJson.error);
                        });
                    }
            })
        }
    });

    // $('#my-link').click(function (event) {
    //     alert('Hooray!');
    //     event.preventDefault(); // Prevent link from following its href
    //   });
});

// function makeAdmin() {
//     this.getAttribute('href');
// }

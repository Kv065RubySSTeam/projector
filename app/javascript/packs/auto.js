$(function () {
    const token = $('meta[name="csrf-token"]').attr('content');

    const autoCompletejs = new autoComplete({
        data: {
            src: async () => {
                // Loading placeholder text
                // document
                //     .querySelector("#autoComplete")
                //     .setAttribute("placeholder", "Loading...");

                // Read search string entered by user
                const query = document.querySelector("#autoComplete").value;
                // Fetch External Data Source
                const source = await fetch(
                    `/users/index.json?search=${query}`
                );
                const data = await source.json();
                // Post loading placeholder text
                // document
                //     .querySelector("#autoComplete")
                //     .setAttribute("placeholder", "Enter the user email here");
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
            },
            destination: document.querySelector("#show-users"),
            position: "afterbegin",
            element: "div"
        },
        resultItem: {
            content: (data, source) => {
                source.innerHTML = data.match;
            },
            element: "li"
        },
        noResults: () => {
            const result = document.createElement("li");
            result.setAttribute("class", "no_result");
            result.innerHTML = "No Results";
            document.querySelector("#autoComplete_list").appendChild(result);
        },
        onSelection: membership => {
            const selectedUserId = membership.selection.value.id;
            // Render selected choice to selection div
            // document.querySelector("#selection").value = selectedUserId;
            // Clear Input
            document.querySelector("#autoComplete").value = "";
            // Change placeholder with the selected value
            // document
            //     .querySelector("#autoComplete")
            //     .setAttribute("placeholder", selection);
            // Concole log autoComplete data membership
            // Send request to server to add user
            let url = document.getElementById("addMembershipURL").value;
            fetch(url + `?user_id=${selectedUserId}`
            // {
            //     method: 'GET',
            //     // headers: { 'X-CSRF-Token': token },
            //     body: '?user_id=' + `${selectedUserId}`
            //   } 
            ).then((response) => {
                if(response.ok) {
                    alert("User was successfully added!");
                } else {
                    alert("Failed to add user to the board. Details: " +  response.statusText);
                }
              });
        }
    });
});
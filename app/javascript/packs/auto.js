$(function () {
    document.querySelector("#autoComplete").addEventListener("autoComplete", event => {
        console.log(event);
    })

    const autoCompletejs = new autoComplete({
        data: {
            src: async () => {
                // Loading placeholder text
                document
                    .querySelector("#autoComplete")
                    .setAttribute("placeholder", "Loading...");
                // Fetch External Data Source
                const source = await fetch(
                    "/users/index.json"
                );
                const data = await source.json();
                // Post loading placeholder text
                document
                    .querySelector("#autoComplete")
                    .setAttribute("placeholder", "Enter the user email here");
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
        placeHolder: "Users",
        selector: "#autoComplete",
        threshold: 0,
        debounce: 0,
        searchEngine: "strict",
        highlight: true,
        maxResults: 5,
        resultsList: {
            render: true,
            container: source => {
                source.setAttribute("id", "autoComplete_list");
            },
            destination: document.querySelector("#autoComplete"),
            position: "afterend",
            element: "ul"
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
            result.setAttribute("tabindex", "1");
            result.innerHTML = "No Results";
            document.querySelector("#autoComplete_list").appendChild(result);
        },
        onSelection: membership => {
            const selection = membership.selection.value.id;
            // Render selected choice to selection div
            document.querySelector("#selection").value = selection;
            // Clear Input
            document.querySelector("#autoComplete").value = "";
            // Change placeholder with the selected value
            document
                .querySelector("#autoComplete")
                .setAttribute("placeholder", selection);
            // Concole log autoComplete data membership
            console.log(membership);
        }
    });
});
document
    .getElementById("update")
    .addEventListener("htmx:afterSettle", (_event) => {
        document.querySelectorAll("textarea").forEach((element) => {
            element.dispatchEvent(
                new Event("input", {
                    bubbles: true,
                    cancelable: true,
                }),
            );
        });
    });

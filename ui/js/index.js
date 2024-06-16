import htmx from "htmx.org";
import Mustache from "mustache";

htmx.defineExtension("client-side-formats", {
    transformResponse: (text, _xhr, elt) => {
        switch (elt.id) {
            case "invites": {
                let data = JSON.parse(text);
                if (data.length > 0) {
                    data = { invites: [true] };
                } else {
                    data = { invites: [] };
                }
                return JSON.stringify(data);
            }
            case "tags": {
                let data = JSON.parse(text);
                data = data.join();
                return JSON.stringify(data);
            }
        }
    },
});

window.addEventListener("htmx:configRequest", (event) => {
    // send tags as list
    if ("tags" in event.detail.parameters) {
        const tags = event.detail.parameters.tags;
        if (typeof tags === "string" || tags instanceof String) {
            const tagsArray = tags
                .replace(/\s+/g, " ")
                .trim()
                .replaceAll(" ", "")
                .split(",");
            event.detail.parameters.tags = tagsArray.filter((str) =>
                str !== ""
            );
        }
    }
});

window.htmx = htmx;
window.Mustache = Mustache;

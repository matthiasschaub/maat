import htmx from "htmx.org";
import Mustache from "mustache";

htmx.defineExtension("client-side-formats", {
  transformResponse: function (text, xhr, elt) {
    var data = JSON.parse(text);

    switch (elt.id) {
      case "invites": {
        if (data.length > 0) {
          data = { invites: [true] };
        } else {
          data = { invites: [] };
        }
        break;
      }
    }

    return JSON.stringify(data);
  },
});

window.htmx = htmx;
window.Mustache = Mustache;

import htmx from "../../node_modules/htmx.org/dist/htmx.esm.js";
import Mustache from "mustache";
// import PathDeps from "../../node_modules/htmx-ext-path-deps/path-deps.js";

htmx.defineExtension("client-side-formats", {
  transformResponse: (text, _xhr, elt) => {
    if (text) {
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
        default: {
          return text;
        }
      }
    } else {
      return text;
    }
  },
});

// https://github.com/bigskysoftware/htmx-extensions/blob/main/src/json-enc/json-enc.js
htmx.defineExtension("json-enc-maat", {
  onEvent: function (name, evt) {
    if (name === "htmx:configRequest") {
      evt.detail.headers["Content-Type"] = "application/json";
    }
  },

  encodeParameters: function (xhr, parameters, elt) {
    xhr.overrideMimeType("text/json");

    const params = JSON.parse(JSON.stringify(parameters));
    console.log(params);

    // send tags as list
    if (Object.keys(params).includes("tags")) {
      const tags = params.tags;
      if (typeof tags === "string" || tags instanceof String) {
        const tagsArray = tags
          .replace(/\s+/g, " ")
          .trim()
          .replaceAll(" ", "")
          .split(",");
        params.tags = tagsArray.filter((str) => str !== "");
      }
    }

    // send public flag as boolean
    if (Object.keys(params).includes("public")) {
      // cast to bool
      params.public = params.public === "true";
      // console.log(params.public === "true");
    }

    // send done flag as boolean
    if (Object.keys(params).includes("done")) {
      // cast to bool
      params.done = params.done === "true";
      // console.log(params.public === "true");
    }

    // send done date as int
    if (Object.keys(params).includes("date")) {
      params.date = Number(params.date);
    }

    return JSON.stringify(params);
  },
});

// Let DELETE requests use a form-encoded body rather than parameters
htmx.config.methodsThatUseUrlParams = ["get"];

window.htmx = htmx;
window.Mustache = Mustache;

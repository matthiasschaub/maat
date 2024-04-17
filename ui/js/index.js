import htmx from "htmx.org";
import Mustache from "mustache";

// extract group ID from URL
//
function lid() {
  const parts = window.location.href.split("/");
  parts.pop() || parts.pop(); // handle potential trailing slash
  return parts.pop() || parts.pop();
}

export { lid };

window.htmx = htmx;
window.Mustache = Mustache;
window.gid = gid;

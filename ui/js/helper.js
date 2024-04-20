// extract list ID from URL
//
function gid() {
  const parts = window.location.href.split("/");
  return parts[6];
}
// extract task ID from URL
//
function tid() {
  const parts = window.location.href.split("/");
  return parts[8];
}

// change HTMX request URL to make requests to the API
//
document.body.addEventListener("htmx:configRequest", (event) => {
  // TODO: if path starts with /apps/tahuti its an absolute path. Do not
  // change
  let path = event.detail.path;

  if (path.includes("{gid}")) {
    path = path.replace("{gid}", gid());
  }
  if (path.includes("{tid}")) {
    path = path.replace("{tid}", tid());
  }
  if (path.includes("/apps/maat")) {
    path = path.replace("/apps/maat", "");
  }

  const site = `/apps/maat${path}`;
  event.detail.path = site.replace(/\/$/, ""); // without trailing slash
});

// error display
//
document.body.addEventListener("htmx:responseError", function (evt) {
  const errorPre = document.getElementById("error-pre");
  const errorDiv = document.getElementById("error-div");
  if (evt.detail.xhr) {
    errorPre.removeAttribute("hidden");
    errorDiv.removeAttribute("hidden");
    if (evt.detail.xhr.status === 500) {
      errorPre.innerText = "500 - Internal Server Error";
      errorDiv.style.display = "grid";
    } else {
      errorPre.innerText = event.detail.xhr.response;
      errorDiv.style.display = "grid";
    }
  } else {
    // Unspecified failure, usually caused by network error
    (errorPre.innerText =
      "Unexpected error, check your connection and try to refresh the page."),
      (errorDiv.style.display = "grid");
  }
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth",
  });
});

export { gid, tid };

window.gid = gid;

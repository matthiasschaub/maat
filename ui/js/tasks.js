window.addEventListener("htmx:configRequest", (event) => {
  // send tags as list
  if ("tags" in event.detail.parameters) {
    const tagsString = event.detail.parameters.tags;
    const tagsArray = tagsString
      .replace(/\s+/g, " ")
      .trim()
      .replaceAll(" ", "")
      .split(",");
    event.detail.parameters.tags = tagsArray.filter((str) => str !== "");
  }
});

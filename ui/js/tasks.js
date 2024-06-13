const form = document.getElementById("filter-tasks");
form.addEventListener("htmx:configRequest", (event) => {
  // send tags as list
  if ("tags" in event.detail.parameters) {
    const tagsString = document.getElementById("filter-tasks-input").value;
    console.log(tagsString);
    const tagsArray = tagsString
      .replace(/\s+/g, " ")
      .trim()
      .replaceAll(" ", "")
      .split(",");
    event.detail.parameters.tags = tagsArray.filter((str) => str !== "");
  }
});

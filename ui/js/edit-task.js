document
  .getElementById("update")
  .addEventListener("htmx:afterSettle", (event) => {
    const form = document.getElementById("update-task");
    form.addEventListener("htmx:configRequest", (event) => {
      // send tags as list
      if ("tags" in event.detail.parameters) {
        const tagsString = document.getElementById("update-tags").value;
        const tagsArray = tagsString
          .replace(/\s+/g, " ")
          .trim()
          .replaceAll(" ", "")
          .split(",");
        event.detail.parameters.tags = tagsArray;
      }
    });
  });

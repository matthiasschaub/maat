from pathlib import Path
from string import Template

html_dir = Path(__file__).parent / "html"
templates_dir = Path(__file__).parent / "templates"

base = templates_dir / "base.html"
with open(base, "r") as f:
    template = Template(f.read())

# sidebar = Path(templates_dir / "sidebar.html").read_text()

# for site in ("index.html", "settings.html", "edit-list.html"):
#     main = Path(templates_dir / site).read_text()
#     html = template.substitute(sidebar=sidebar, main=main)
#     Path(html_dir / site).write_text(html)


header = Path(templates_dir / "header.html").read_text()
header_index = Path(templates_dir / "header-index.html").read_text()

for site in (
    "index.html",
    "create.html",
    "invite.html",
    "invites.html",
    "tasks.html",
    "tasks-public.html",
    "settings.html",
    "about.html",
    "edit-list.html",
    "edit-task.html",
    "show-task.html",
):
    main = Path(templates_dir / site).read_text()
    if site in (
        "index.html",
        "create.html",
        "invites.html",
        "tasks-public.html",
        "show-task.html",
    ):
        html = template.substitute(header=header_index, main=main)
    else:
        html = template.substitute(header=header, main=main)
    Path(html_dir / site).write_text(html)

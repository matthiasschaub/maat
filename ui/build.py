from pathlib import Path
from string import Template

html_dir = Path(__file__).parent / "html"
templates_dir = Path(__file__).parent / "templates"

base = templates_dir / "base.html"
with open(base, "r") as f:
    template = Template(f.read())

sidebar = Path(templates_dir / "sidebar.html").read_text()

for site in ("index.html", "settings.html"):
    main = Path(templates_dir / site).read_text()
    html = template.substitute(sidebar=sidebar, main=main)
    Path(html_dir / site).write_text(html)

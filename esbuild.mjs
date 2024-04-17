import * as esbuild from "esbuild";

let ctx = await esbuild.context({
  entryPoints: [
    "./ui/html/index.html",
    "./ui/css/udjat.css",
    "./ui/css/style.css",
    "./ui/css/soria.ttf",
    "./ui/svg/circles.svg",
    "./ui/js/index.js",
    "./node_modules/htmx.org/dist/ext/path-deps.js",
    "./node_modules/htmx.org/dist/ext/json-enc.js",
    "./node_modules/htmx.org/dist/ext/client-side-templates.js",
  ],
  external: ['*.ttf'],
  entryNames: "[ext]/[name]", // will name the result files by their folder names
  bundle: true,
  loader: { ".json": "copy", ".html": "copy", ".svg": "copy", ".png": "copy", ".ttf": "copy"},
  outdir: "maat/app/ui",
});

await ctx.watch();

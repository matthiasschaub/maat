import * as esbuild from "esbuild";

let ctx = await esbuild.context({
  entryPoints: [
    "./ui/manifest.json",
    "./ui/html/index.html",
    "./ui/html/create.html",
    "./ui/html/invite.html",
    "./ui/html/invites.html",
    "./ui/html/tasks.html",
    "./ui/html/settings.html",
    "./ui/html/about.html",
    "./ui/html/edit-list.html",
    "./ui/html/edit-task.html",
    "./ui/css/udjat.css",
    "./ui/css/style.css",
    "./ui/css/soria.woff2",
    "./ui/css/soria.ttf",
    "./ui/svg/circle-checked.svg",
    "./ui/svg/circle-plus.svg",
    "./ui/svg/circle-question.svg",
    "./ui/svg/circle.svg",
    "./ui/svg/circles.svg",
    "./ui/svg/icon.svg",
    "./ui/png/ios/16.png",
    "./ui/png/ios/180.png",
    "./ui/js/index.js",
    "./ui/js/helper.js",
    "./ui/js/edit-task.js",
    "./node_modules/htmx-ext-path-deps/path-deps.js",
    "./node_modules/htmx-ext-json-enc/json-enc.js",
    "./node_modules/htmx-ext-client-side-templates/client-side-templates.js",
  ],
  external: ["*.svg", "*.woff2", "*.ttf"],
  entryNames: "[ext]/[name]", // will name the result files by their folder names
  bundle: true,
  loader: {
    ".json": "copy",
    ".html": "copy",
    ".svg": "copy",
    ".png": "copy",
    ".woff2": "copy",
    ".ttf": "copy",
  },
  outdir: "maat/app/ui",
});

await ctx.watch();

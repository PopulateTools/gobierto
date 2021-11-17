import "@finos/perspective-viewer-datagrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";
import "../stylesheets/comp-perspective-viewer.scss";
import { getData } from "./render.js";

const appendStyle = async () => {
  const { src } = document.querySelector('script[src*="embeds.js"]');
  const { origin } = new URL(src);
  // get the manifest from the same origin as the script has
  const { "embeds.css": cssUrl } = await fetch(
    `${origin}/packs/manifest.json`
  ).then(r => r.json());
  const link = document.createElement("link");
  link.href = `${origin}${cssUrl}`;
  link.type = "text/css";
  link.rel = "stylesheet";
  link.media = "screen,print";
  document.getElementsByTagName("head")[0].appendChild(link);
};

appendStyle();

// Look for all possible vizzs in the site
document
  .querySelectorAll("[data-gobierto-visualization]")
  .forEach(getData);

import '../../assets/stylesheets/modules/_comp-perspective-viewer.scss';
import { getData } from './render.js';

/**
 * TODO: Sprockets generates a digest for each file
 * Once we can remove for the embeds.js and embeds.css,
 * this script becomes even simpler
 *
 * Currently won't work due to the hash is fetching (for debugging purposes)
 * Change it accordingly to make it work
 */
async function main() {
  const getEmbedStyle = async () => {
    const { src } = document.querySelector('script[src*="embeds"]');
    const { origin } = new URL(src);

    return `${origin}/assets/embeds.css`
  };

  const appendStyles = (...paths) => {
    paths.forEach(path => {
      const link = document.createElement("link");
      link.href = path;
      link.type = "text/css";
      link.rel = "stylesheet";
      link.media = "screen,print";

      document.getElementsByTagName("head")[0].appendChild(link);
    })
  };

  const appendScripts = (...paths) => {
    paths.forEach(path => {
      const script = document.createElement("script");
      script.type = "text/javascript";
      script.src = path;

      document.getElementsByTagName("head")[0].appendChild(script);
    })
  };

  appendScripts(
    "https://cdn.jsdelivr.net/npm/@finos/perspective@0.6.2/dist/umd/perspective.js",
    "https://cdn.jsdelivr.net/npm/@finos/perspective-viewer@0.6.2/dist/umd/perspective-viewer.js",
    "https://cdn.jsdelivr.net/npm/@finos/perspective-viewer-datagrid@0.6.2/dist/umd/perspective-viewer-datagrid.js",
    "https://cdn.jsdelivr.net/npm/@finos/perspective-viewer-d3fc@0.6.2/dist/umd/perspective-viewer-d3fc.js"
  );

  const embedcss = await getEmbedStyle()

  appendStyles(
    embedcss,
    "https://cdn.jsdelivr.net/npm/@finos/perspective-viewer@0.6.2/dist/umd/material-dense.min.css"
  );

  // Look for all possible vizzs in the site
  document
    .querySelectorAll("[data-gobierto-visualization]")
    .forEach(getData);
}

main()

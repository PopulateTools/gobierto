import "@finos/perspective";
import "@finos/perspective-viewer";
import "@finos/perspective-viewer-datagrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";
import "../../assets/stylesheets/comp-perspective-viewer.scss";

// Look for all possible vizzs in the site
document.querySelectorAll("[data-gobierto-visualization]").forEach(async container => {
  const { gobiertoVisualization: id, site } = container.dataset
  const { "embeds.css": cssUrl } = await fetch(`${site}/packs/manifest.json`).then(r => r.json())
  const cssHref = `${site}${cssUrl}`

  // Include the styles if they're not included yet
  if (!([...document.getElementsByTagName("link")].some(({ href }) => href === cssHref))) {
    const link = document.createElement("link");
    link.href = cssHref;
    link.type = "text/css";
    link.rel = "stylesheet";
    link.media = "screen,print";
    document.getElementsByTagName("head")[0].appendChild(link);
  }

  const response = await fetch(`${site}/api/v1/data/visualizations/${id}`).then(r => r.json())
  const { attributes: { query_id, sql, spec } } = response?.data

  let url = null
  if (query_id) {
    url = `${site}/api/v1/data/queries/${query_id}.csv`
  } else if (sql) {
    url = `${site}/api/v1/data/data.csv?sql=${encodeURIComponent(sql)}`
  }

  if (url) {
    const responseQuery = await fetch(url).then(r => r.text())

    const viewer = document.createElement("perspective-viewer")
    viewer.setAttribute("columns", spec.columns)
    viewer.setAttribute("plugin", spec.plugin)
    container.appendChild(viewer)

    // run perspective
    viewer.clear();
    viewer.restore(spec);
    viewer.load(responseQuery);

    // hide configuration
    const configButtonPerspective = viewer.shadowRoot.getElementById('config_button')
    configButtonPerspective.style.display = "none"
  }
})

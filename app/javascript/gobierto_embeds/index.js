import "@finos/perspective";
import "@finos/perspective-viewer";
import "@finos/perspective-viewer-datagrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";
import "../../assets/stylesheets/comp-perspective-viewer.scss";

// Look for all possible vizzs in the site
document.querySelectorAll("[data-gobierto-visualization]").forEach(async container => {
  const { gobiertoVisualization: id, site, token } = container.dataset
  const { "embeds.css": cssUrl } = await fetch(`${site}/packs/manifest.json`).then(r => r.json())
  const headers = token ? { Authorization: `Bearer ${token}` } : {}

  // Include the styles if they're not included yet
  if (!([...document.getElementsByTagName("link")].some(({ href }) => href.match(cssUrl)))) {
    const link = document.createElement("link");
    link.href = `${site}${cssUrl}`;
    link.type = "text/css";
    link.rel = "stylesheet";
    link.media = "screen,print";
    document.getElementsByTagName("head")[0].appendChild(link);
  }

  const { data: visualization } = await fetch(`${site}/api/v1/data/visualizations/${id}`, { headers }).then(r => r.json()) || {}
  if (visualization) {
    const { attributes: { query_id, sql, spec } } = visualization || {}

    let url = null
    if (query_id) {
      url = `${site}/api/v1/data/queries/${query_id}.csv`
    } else if (sql) {
      url = `${site}/api/v1/data/data.csv?sql=${encodeURIComponent(sql)}`
    }

    if (url) {
      const data = await fetch(url, { headers }).then(r => r.text())

      if (data) {
        const viewer = document.createElement("perspective-viewer")
        viewer.setAttribute("columns", spec.columns)
        viewer.setAttribute("plugin", spec.plugin)

        if (spec.column_pivots) {
          viewer.setAttribute("column-pivots", JSON.stringify(spec.column_pivots))
        }

        if (spec.row_pivots) {
          viewer.setAttribute("row-pivots", JSON.stringify(spec.row_pivots))
        }

        if (spec.computed_columns) {
          viewer.setAttribute("computed-columns", JSON.stringify(spec.computed_columns))
        }

        container.appendChild(viewer)

        // hide configuration
        const configButtonPerspective = viewer.shadowRoot.getElementById('config_button')
        configButtonPerspective.style.display = "none"

        // run perspective
        viewer.clear();
        viewer.restore(spec);
        viewer.load(data);
      }
    }
  }
})

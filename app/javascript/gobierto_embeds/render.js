// TODO: perspective must load via CDN
// import perspective from '@finos/perspective';

export const getData = async container => {
  const { gobiertoVisualization: id, site, token } = container.dataset;
  const headers = token ? { Authorization: `Bearer ${token}` } : {};

  const { data: visualization } =
  (await fetch(`${site}/api/v1/data/visualizations/${id}`, {
    headers
  }).then(r => r.json())) || {};
  if (visualization) {
    const {
      attributes: { query_id, sql, spec }
    } = visualization || {};

    const url = query_id ?
      `${site}/api/v1/data/queries/${query_id}.csv` :
      sql ?
      `${site}/api/v1/data/data.csv?sql=${encodeURIComponent(sql)}` :
      null;

    if (url) {
      const data = await fetch(url, { headers }).then(r => r.text());
      renderPerspective(data, container, spec)
    }
  }
};

export function renderPerspective(data, container, spec = {}) {
  const viewer = document.createElement("perspective-viewer");

  if (spec.column_pivots) {
    viewer.setAttribute(
      "column-pivots",
      JSON.stringify(spec.column_pivots)
    );
  }

  if (spec.row_pivots) {
    viewer.setAttribute("row-pivots", JSON.stringify(spec.row_pivots));
  }

  if (spec.computed_columns) {
    viewer.setAttribute(
      "computed-columns",
      JSON.stringify(spec.computed_columns)
    );
  }

  container.parentNode.replaceChild(viewer, container);

  // hide configuration
  const configButtonPerspective = viewer.shadowRoot.getElementById(
    "config_button"
  );
  configButtonPerspective.style.display = "none";

  // run perspective
  const table = perspective.worker().table(data);
  viewer.restore(spec);
  viewer.load(table);
}

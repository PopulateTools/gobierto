/**
 * @jest-environment jsdom
 */

const fetch = require("node-fetch");
import perspective from "@finos/perspective";
import "@finos/perspective-viewer/dist/umd/perspective-viewer.js";
import "@finos/perspective-viewer-datagrid/dist/umd/perspective-viewer-datagrid.js";

const getVisualizationList = async container => {
  const { gobiertoVisualization: id, site, token } = container.dataset;
  const headers = token ? { Authorization: `Bearer ${token}` } : {};

  const { data: visualization } =
  (await fetch(`${site}/api/v1/data/visualizations/${id}`, {
    headers
  }).then(r => r.json())) || {};
  if (visualization) {
    console.log("visualization", visualization);
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

      if (data) {
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

        // run perspective
        const table = perspective.worker().table(data);
        viewer.restore(spec);
        viewer.load(table);
        console.log("viewer", viewer);
      }
    }
  }
};

let element
let container
beforeAll(() => {
  container = document.createElement('section')
  element = document.createElement('div');
  element.setAttribute('data-gobierto-visualization', '183');
  element.setAttribute('data-site', 'https://getafe.gobify.net');
  element.setAttribute('data-token', '1yvuaff8H2Ta5XGTYCXBhzUV');
  container.appendChild(element)
});

describe('display visualization', () => {
  test('Mayor que', async () => {
    const perspectiveViz = await getVisualizationList(element)
    container.appendChild(element)
    expect(perspectiveViz).not.toBeNull();
  })
})

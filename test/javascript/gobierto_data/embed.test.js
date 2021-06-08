/**
 * @jest-environment jsdom
 */

import { renderPerspective } from "../../../app/javascript/gobierto_embeds/render.js";
import "@finos/perspective-viewer/dist/umd/perspective-viewer.js";
import "@finos/perspective-viewer-datagrid/dist/umd/perspective-viewer-datagrid.js";

const data = [{
  "fecha": "2021-06-01",
  "barrio": "Buenavista",
  "formacion": "Menores de 16",
  "total": 102,
  "mujer": 55,
  "varon": 47
}]

test('render perspective', () => {
  const container = document.createElement('section')
  document.body.appendChild(container)
  const element = document.createElement('div');
  container.appendChild(element)
  renderPerspective(data, element)

  expect(document.querySelector('perspective-viewer')).not.toBeNull();
})

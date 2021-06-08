/**
 * @jest-environment jsdom
 */

import data from '__mocks__/data.json'
import { renderPerspective } from "../../../app/javascript/gobierto_embeds/render.js";
import "@finos/perspective-viewer/dist/umd/perspective-viewer.js";
import "@finos/perspective-viewer-datagrid/dist/umd/perspective-viewer-datagrid.js";

test('render perspective', () => {
  const container = document.createElement('section')
  document.body.appendChild(container)
  const element = document.createElement('div');
  container.appendChild(element)
  renderPerspective(data, element)
  const testVIewer = document.querySelector('perspective-viewer')
  expect(document.querySelector('perspective-viewer')).not.toBeNull();
})

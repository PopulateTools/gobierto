/**
 * @jest-environment jsdom
 */

import data from '__mocks__/data.json'
import { renderPerspective } from "../../../app/javascript/gobierto_embeds/render.js";
import "@finos/perspective-viewer/dist/umd/perspective-viewer.js";
import "@finos/perspective-viewer-datagrid/dist/umd/perspective-viewer-datagrid.js";

describe('visualization', () => {
  const container = document.createElement('section')
  document.body.appendChild(container)
  const element = document.createElement('div');
  container.appendChild(element)

  test('render perspective', () => {
    renderPerspective(data, element)
    expect(document.querySelector('perspective-viewer')).not.toBeNull();
  })

  test('waits 1 second for Perspective to add the columns to the web component', (done) => {
    setTimeout(() => {
      expect(JSON.parse(document.querySelector('perspective-viewer').getAttribute('columns'))).toHaveLength(2);
      done();
    }, 1000);
  });

})

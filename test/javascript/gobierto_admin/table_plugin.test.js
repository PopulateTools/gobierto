/** @jest-environment jsdom */

import $ from 'jquery';
import { SlickGrid } from 'slickgrid';

jest.mock('slickgrid', () => ({
  Editors: {},
  EventHandler: jest.fn(),
  GlobalEditorLock: { isActive: jest.fn(() => false) },
  keyCode: {},
  SlickCellSelectionModel: jest.fn(),
  SlickGrid: jest.fn(() => ({
    setSelectionModel: jest.fn(),
    registerPlugin: jest.fn(),
    onAddNewRow: { subscribe: jest.fn() }
  }))
}));

global.$ = $;
window.GobiertoAdmin = {};
window.I18n = { locale: 'en', defaultLocale: 'en', t: key => key };
require('select2')(window, $);
require('../../../vendor/gobierto_engines/custom-fields-table-plugin/app/javascripts/custom_fields_table_plugin/modules/table_plugin');

const controller = window.GobiertoAdmin.gobierto_common_custom_field_records_table_plugin_controller;

async function vocabularyColumn(terms) {
  document.body.innerHTML = `
    <div id="custom_field_directory" data-uid="directory">
      <div class="custom_field_value"><input></div>
      <div class="data-container"></div>
    </div>`;
  $('#custom_field_directory').data('configuration', {
    columns: [{
      id: 'position',
      name_translations: { en: 'Position' },
      type: 'vocabulary',
      dataSource: '/admin/api/vocabularies/1'
    }]
  });
  $('#custom_field_directory input').val(JSON.stringify({ directory: [{ position: 7 }] }));
  jest.spyOn($, 'getJSON').mockImplementation((_url, callback) => callback({ terms }));

  controller.form({ uid: 'directory' });
  await new Promise(resolve => setTimeout(resolve, 0));

  const [, , columns] = SlickGrid.mock.calls[0];
  return columns.find(column => column.id === 'position');
}

describe('table plugin vocabulary options', () => {
  afterEach(() => {
    jest.restoreAllMocks();
    jest.clearAllMocks();
    $(document).off('click');
    document.body.innerHTML = '';
  });

  test.each([
    ['current locale', { es: 'Supervisor', en: 'Manager' }, 'Manager'],
    ['missing current locale', { es: 'Supervisor' }, 'Supervisor'],
    ['empty current locale', { en: '', es: 'Supervisor' }, 'Supervisor'],
    ['null current locale', { en: null, es: 'Supervisor' }, 'Supervisor'],
    ['whitespace-only current locale', { en: '  ', es: 'Supervisor' }, 'Supervisor'],
    ['blank translations before an available locale', { en: '', ca: null, gl: ' ', es: 'Supervisor' }, 'Supervisor'],
    ['multiple available locales', { ca: 'Supervisora', es: 'Supervisor' }, 'Supervisora']
  ])('selects a label with %s', async (_description, nameTranslations, expected) => {
    const column = await vocabularyColumn([{ id: 7, name_translations: nameTranslations }]);

    expect(column.dataSource).toEqual({ 7: expected });
    expect(column.formatter(0, 0, 7, column)).toBe(expected);
  });

  test('displays fallback labels in the select without changing term IDs or saved selections', async () => {
    const column = await vocabularyColumn([
      { id: 7, name_translations: { es: 'Supervisor' } },
      { id: 12, name_translations: { en: 'Assistant' } }
    ]);
    const container = document.createElement('div');
    document.body.appendChild(container);
    const editor = new column.editor({ column, container, grid: SlickGrid.mock.results[0].value });
    editor.loadValue({ position: 7 });

    expect($(container).find('option').map((_index, option) => [option.value, option.text]).get())
      .toEqual(['7', 'Supervisor', '12', 'Assistant']);
    expect($(container).find('.select2-selection__rendered').text()).toBe('Supervisor');
    expect(editor.isValueChanged()).toBe(false);
    expect(editor.serializeValue()).toBe(7);

    $(container).find('select').val('12').trigger('change');
    const item = { position: 7 };
    editor.applyValue(item, editor.serializeValue());
    expect(item).toEqual({ position: 12 });
    editor.destroy();
  });
});

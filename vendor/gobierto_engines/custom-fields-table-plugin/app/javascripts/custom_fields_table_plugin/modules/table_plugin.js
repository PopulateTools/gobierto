import { Grid, Editors, Plugins } from 'slickgrid-es6';
import { Select2Formatter, Select2Editor } from './data_grid_plugin_select2';
import CheckboxDeleteRowPlugin from './checkbox_delete_row_plugin';
import { applyPluginStyles, preventLosingCurrentEdit, defaultSlickGridOptions } from './common_slickgrid_behavior';
import { DateEditor } from './datepicker_editor';

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsTablePluginController = (function() {

  function GobiertoCommonCustomFieldRecordsTablePluginController() {}

  var _grid;
  var _pluginCssClass = 'table';

  GobiertoCommonCustomFieldRecordsTablePluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
    preventLosingCurrentEdit()
  };

  function _handlePluginData(uid) {
    let element = $(`[data-uid=${uid}]`)
    let id = element.attr('id')
    let data = _deserializeTablePluginData($(`#${id} .custom_field_value`).find("input").val(), uid)
    let columnsConfiguration = element.data("configuration").columns || []
    let vocabulariesConfiguration = columnsConfiguration.filter(
      column => { return column.type == "vocabulary" }
    );

    let vocabulariesRequests = vocabulariesConfiguration.map(
      column => {
        return new Promise(
          resolve => ($.getJSON(column.dataSource, jsonData => (resolve(jsonData))))
        )
      }
    )

    Promise.all(vocabulariesRequests).then(function(values) {
      let vocabulariesData = {}
      $.each(
        values,
        idx => {
          vocabulariesData[vocabulariesConfiguration[idx].id] = values[idx]["terms"] }
      )
      applyPluginStyles(element, _pluginCssClass)
      _slickGrid(id, data, _columnsSettings(columnsConfiguration, vocabulariesData))
    })
  }

  function _columnsSettings(columnsSettings, vocabulariesData) {
    if ( Array.isArray(columnsSettings) ) {
      return columnsSettings.map(columnSettings => {
        return {
          id: columnSettings.id,
          name: columnSettings.name_translations[I18n.locale] || columnSettings.name_translations[I18n.defaultLocale],
          field: columnSettings.id,
          ..._defaultColumnSettings(),
          ..._typeColumnSettings(columnSettings.type, vocabulariesData[columnSettings.id])
        };
      });
    } else {
      return [];
    }
  }

  function _defaultColumnSettings() {
    return {
      minWidth: 120,
      cssClass: "cell-title",
      editor: Editors.Text
    }
  }

  function _typeColumnSettings(type, vocabularyData) {
    let vocabularyOptions = {};

    if (type == "vocabulary") {
      $.each(vocabularyData, function(idx) {
        let term = vocabularyData[idx];
        vocabularyOptions[term.id] = term.name_translations[I18n.locale];
      });
    }

    return {
      text: { editor: Editors.Text },
      integer: { editor: Editors.Integer },
      float: { editor: Editors.Float },
      date: { editor: DateEditor },
      vocabulary: { formatter: Select2Formatter, editor: Select2Editor, dataSource: vocabularyOptions, sort: true },
      yes_no_select: { editor: Editors.YesNoSelect },
      checkbox: { editor: Editors.Checkbox },
      long_text: { editor: Editors.LongText }
    }[type]
  }

  function _slickGrid(id, data, columns) {
    function _initializeGrid(id, data, columns, options) {
      var checkboxSelector = new CheckboxDeleteRowPlugin({
        cssClass: "slick-cell-checkboxsel",
        hideSelectAllCheckbox: true,
        containerId: id,
      });

      columns.unshift(checkboxSelector.getColumnDefinition());

      _grid = new Grid(`#${id} .data-container`, data, columns, options);
      $(`#${id}`).data('slickGrid', _grid);

      _grid.setSelectionModel(new Plugins.CellSelectionModel({ selectActiveCell: false }));

      _grid.onAddNewRow.subscribe(function (_e, args) {
        _grid.invalidateRow(data.length);
        data.push(args.item);
        _grid.updateRowCount();
        _grid.render();
      });

      _grid.registerPlugin(checkboxSelector);
    }

    let customSlickGridOptions = { itemsCountId: `${id}_items` }

    _initializeGrid(id, data, columns, { ...defaultSlickGridOptions, ...customSlickGridOptions });
  }

  function _deserializeTablePluginData(inputValue, uid) {
    let inputDict = JSON.parse(inputValue) ? JSON.parse(inputValue)[uid] : null;

    if ( Array.isArray(inputDict) ) {
      return inputDict;
    } else {
      return [];
    }
  }

  return GobiertoCommonCustomFieldRecordsTablePluginController;
})();

function serializeTablePluginData(data, uid) {
  let dataObject = {};
  dataObject[uid] = data;
  return JSON.stringify(dataObject);
}

window.GobiertoAdmin.gobierto_common_custom_field_records_table_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsTablePluginController;
window.GobiertoAdmin.serializeTablePluginData = serializeTablePluginData

import { Grid, Editors, Plugins } from 'slickgrid-es6';
import { Select2Formatter, Select2Editor } from './data_grid_plugin_select2';
import CheckboxDeleteRowPlugin from './checkbox_delete_row_plugin';
import { applyPluginStyles, preventLosingCurrentEdit, defaultSlickGridOptions } from './common_slickgrid_behavior';

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsIndicatorsPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsIndicatorsPluginController() {}

  var _grid;
  var _pluginCssClass = 'indicators'
  var _indicatorsDictionary = {};

  GobiertoCommonCustomFieldRecordsIndicatorsPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
    preventLosingCurrentEdit()
  };

  function _deserializeTableData(inputValue) {
    if (inputValue && inputValue !== "null") return JSON.parse(inputValue)
    return []
  }

  function _handlePluginData(uid) {
    var indicatorsVocabularyId = $(`[data-uid=${uid}]`).attr("data-vocabulary-id");
    var vocabularyInfoPromise = new Promise((resolve) => {
      $.getJSON('/admin/api/vocabularies/' + indicatorsVocabularyId, function(jsonData) {
        resolve(jsonData);
      });
    })

    vocabularyInfoPromise.then(function(jsonData) {
      let vocabularyTerms = jsonData["terms"];
      let element = $(`[data-uid=${uid}]`)
      let id = element.attr('id')
      let data = _deserializeTableData($(`#${id}`).find("input[name$='[value]'").val());

      applyPluginStyles(element, _pluginCssClass)
      _slickGrid(id, data, vocabularyTerms)
    })
  }

  function _slickGrid(id, data, vocabularyTerms) {

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

    $.each(vocabularyTerms, function(idx) {
      let term = vocabularyTerms[idx];
      _indicatorsDictionary[term.id] = term.name_translations[I18n.locale]
    });

    let columns = [
      {
        id: "indicator",
        name: I18n.t("gobierto_admin.custom_fields_plugins.indicators.indicator"),
        field: "indicator",
        minWidth: 120,
        cssClass: "cell-title",
        formatter: Select2Formatter,
        editor: Select2Editor,
        dataSource: _indicatorsDictionary,
        sort: true
      },
      {
        id: "objective",
        name: I18n.t("gobierto_admin.custom_fields_plugins.indicators.objective"),
        field: "objective",
        width: 120,
        cssClass: "cell-title",
        editor: Editors.Float
      },
      {
        id: "value_reached",
        name: I18n.t("gobierto_admin.custom_fields_plugins.indicators.value_reached"),
        field: "value_reached",
        width: 120,
        cssClass: "cell-title",
        editor: Editors.Float
      },
      {
        id: "date",
        name: I18n.t("gobierto_admin.custom_fields_plugins.indicators.date"),
        field: "date",
        width: 120,
        cssClass: "cell-title",
        editor: Editors.Text
      }
    ];

    let customSlickGridOptions = { itemsCountId: `${id}_items` }

    _initializeGrid(id, data, columns, { ...defaultSlickGridOptions, ...customSlickGridOptions });
  }
  return GobiertoCommonCustomFieldRecordsIndicatorsPluginController;
})();

function serializeTableData(data) {
  return JSON.stringify(data)
}

window.GobiertoAdmin.gobierto_common_custom_field_records_indicators_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsIndicatorsPluginController;
window.GobiertoAdmin.serializeIndicatorsPluginData = serializeTableData

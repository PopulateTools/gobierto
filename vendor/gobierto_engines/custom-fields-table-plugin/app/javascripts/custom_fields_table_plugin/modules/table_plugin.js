import { Editors, SlickCellSelectionModel, SlickGrid } from 'slickgrid';
import CheckboxDeleteRowPlugin from './checkbox_delete_row_plugin';
import { applyPluginStyles, defaultSlickGridOptions, preventLosingCurrentEdit } from './common_slickgrid_behavior';
import { Select2Editor, Select2Formatter } from './data_grid_plugin_select2';
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
    let isDisabled = element.attr("data-disabled") === "true"
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
      _slickGrid(id, data, _columnsSettings(columnsConfiguration, vocabulariesData), isDisabled)
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

  function _slickGrid(id, data, columns, isDisabled) {
    function _initializeGrid(id, data, columns, options) {
      if (!isDisabled) {
        var checkboxSelector = new CheckboxDeleteRowPlugin({
          cssClass: "slick-cell-checkboxsel",
          hideSelectAllCheckbox: true,
          containerId: id,
        });

        columns.unshift(checkboxSelector.getColumnDefinition());
      }

      _grid = new SlickGrid(`#${id} .data-container`, data, columns, options);
      $(`#${id}`).data('slickGrid', _grid);

      _grid.setSelectionModel(new SlickCellSelectionModel({ selectActiveCell: false }));

      _grid.onAddNewRow.subscribe(function (_e, args) {
        _grid.invalidateRow(data.length);
        data.push(args.item);
        _grid.updateRowCount();
        _grid.render();
      });

      if (!isDisabled) {
        _grid.registerPlugin(checkboxSelector);
      }

      const gridHTML = document.getElementById(id)
      const addDashboardBtn = gridHTML.querySelector("[add-dashboard-btn]")
      if (addDashboardBtn) {
        _grid.onMouseEnter.subscribe((e, { grid }) => {
          const container = grid.getContainerNode()

          const data = grid.getDataItem(grid.getCellFromEvent(e).row);
          if (data) {
            const { top: rowTop } = e.target.parentElement.getBoundingClientRect()
            const { top: containerTop } = container.getBoundingClientRect()

            container.parentElement.style.position = "relative"
            addDashboardBtn.style.top = `${rowTop - containerTop}px`
            addDashboardBtn.classList.add("is-active")

            const url = new URL(addDashboardBtn.href)
            url.search = new URLSearchParams({ ...data, indicator_context: addDashboardBtn.dataset?.indicatorContext }).toString()
            addDashboardBtn.href = url
          }
        })

        // it cannot be done from _grid.onMouseLeave because the btn is outside of the grid
        gridHTML.addEventListener("mouseleave", () => addDashboardBtn.classList.remove("is-active"))
      }
    }

    let customSlickGridOptions = {
      itemsCountId: `${id}_items`,
      editable: !isDisabled,
      autoEdit: !isDisabled,
      enableAddRow: !isDisabled
    }

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

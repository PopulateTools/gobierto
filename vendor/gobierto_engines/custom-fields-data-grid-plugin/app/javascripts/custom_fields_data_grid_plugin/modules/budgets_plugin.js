import { Grid, Editors, Plugins } from 'slickgrid-es6';
import { Select2Formatter, Select2Editor } from './data_grid_plugin_select2';
import CheckboxDeleteRowPlugin from './checkbox_delete_row_plugin';
import { applyPluginStyles } from './common_slickgrid_behavior';

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsBudgetsPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsBudgetsPluginController() {}

  var _grid
  var _availableYears = {}
  var _budgetLines = {
    grouped: { economic: {}, functional: {} }
  }

  GobiertoCommonCustomFieldRecordsBudgetsPluginController.prototype.form = function(opts = {}) {
    _initializePlugin(opts.uid)
  };

  function _deserializeTableData(inputValue) {
    if (inputValue === "null") return []

    var inputDict = JSON.parse(inputValue)
    var deserializedData = []

    if ('budget_lines' in inputDict) {
      $.each(inputDict.budget_lines, function(idx) {
        var row = inputDict.budget_lines[idx]
        row.year = parseInt(row.id.split("/")[1])
        row.budget_line = `${row.area}/${row.id.replace(`/${row.year}`, "")}`
        delete row.id
        delete row.area
        deserializedData.push(row)
      })
    }

    return deserializedData
  }

  function _parseAvailableYears(jsonData) {
    $.each(jsonData, function(idx) {
      let year = jsonData[idx]
      _availableYears[year] = year.toString()
    })
  }

  function _parseBudgetLines(jsonData) {
    var organizationId = 28079

    Object.keys(jsonData.economic.G).sort().forEach(function(budgetLineCode) {
      _budgetLines.grouped.economic[`economic/${organizationId}/${budgetLineCode}/G`] = `${budgetLineCode} - ${jsonData.economic.G[budgetLineCode]}`
    });

    Object.keys(jsonData.functional.G).sort().forEach(function(budgetLineCode) {
      _budgetLines.grouped.functional[`functional/${organizationId}/${budgetLineCode}/G`] = `${budgetLineCode} - ${jsonData.functional.G[budgetLineCode]}`
    });
  }

  function _initializePlugin(uid) {
    var element = $(`[data-uid=${uid}]`)
    var id = element.attr('id')

    var availableYearsPromise = new Promise((resolve) => {
      $.getJSON('/presupuestos/api/data/available_years', function(jsonData) {
        resolve(jsonData)
      });
    })

    var budgetLinesPromise = new Promise((resolve) => {
      $.getJSON('/presupuestos/api/categories', function(jsonData) {
        resolve(jsonData)
      });
    })

    availableYearsPromise.then(function(jsonData) {
      _parseAvailableYears(jsonData)

      budgetLinesPromise.then(function(jsonData) {
        _parseBudgetLines(jsonData)

        let data = _deserializeTableData($(`#${id}`).find("input[name$='[value]'").val())

        applyPluginStyles(element, "budgets")
        _slickGrid(id, data)
      })

    })
  }

  function _refreshRowAmount(row) {
    var updatedRow = _grid.getData()[row]
    var idSegments = updatedRow.budget_line.split("/")
    var areaName = idSegments.shift()
    idSegments.splice(1, 0, updatedRow.year)
    var budgetLineId = idSegments.join("/")

    fetch(`/presupuestos/api/data/budget_lines/${areaName}/${budgetLineId}`).then(function(response) {
      if (response.status === 200) {
        return response.json()
      } else {
        updatedRow.amount = i18n("not_available")
        _grid.invalidateRow(row)
        _grid.render()
      }
    }).then(function(jsonData) {
      if (jsonData) {
        var amount = jsonData.forecast.updated_amount || jsonData.forecast.original_amount
        updatedRow.amount = `${Math.round(amount * updatedRow.weight / 100).toLocaleString(I18n.locale)} €`
        _grid.invalidateRow(row)
        _grid.render()
      }
    })
  }

  function _slickGrid(id, data) {
    function _initializeGrid(id, data, columns, options) {
      var checkboxSelector = new CheckboxDeleteRowPlugin({
        cssClass: "slick-cell-checkboxsel",
        hideSelectAllCheckbox: true,
        containerId: id
      });

      columns.unshift(checkboxSelector.getColumnDefinition());

      _grid = new Grid(`#${id} .data-container`, data, columns, options)
      $(`#${id}`).data('slickGrid', _grid)

      _grid.setSelectionModel(new Plugins.CellSelectionModel({selectActiveCell: false}))

      _grid.onAddNewRow.subscribe(function(e, args) {
        _grid.invalidateRow(data.length)
        data.push(args.item)
        _grid.updateRowCount()
        _grid.render()
        _updateBudgetLineAmount(e, args)
      })

      _grid.onCellChange.subscribe(function(_e, args) {
        _refreshRowAmount(args.row)
      })

      _grid.registerPlugin(checkboxSelector);
    }

    let columns = [
      {
        id: "year",
        name: i18n("year"),
        field: "year",
        width: 120,
        cssClass: "cell-title",
        formatter: Select2Formatter,
        editor: Select2Editor,
        dataSource: _availableYears
      },
      {
        id: "budget_line",
        name: i18n("budget_line"),
        field: "budget_line",
        width: 250,
        cssClass: "cell-title",
        formatter: Select2Formatter,
        editor: Select2Editor,
        dataSource: _budgetLines
      },
      {
        id: "weight",
        name: `${i18n("weight")} %`,
        field: "weight",
        width: 120,
        cssClass: "cell-title",
        editor: Editors.Integer
      },
      {
        id: "amount",
        name: i18n("amount"),
        field: "amount",
        width: 120,
        cssClass: "cell-title"
      }
    ];

    // generice grid options
    let options = {
      editable: true,
      enableAddRow: true,
      enableCellNavigation: true,
      asyncEditorLoading: false,
      enableColumnReorder: false,
      autoEdit: true,
      itemsCountId: `${id}_items`
    };

    _initializeGrid(id, data, columns, options);
    for (let i = 0; i < data.length; i++) _refreshRowAmount(i)
  }

  function i18n(key) {
    return I18n.t(`gobierto_admin.custom_fields_plugins.budgets.${key}`)
  }

  return GobiertoCommonCustomFieldRecordsBudgetsPluginController;
})();

function serializeTableData(data) {
  var serializedData = { budget_lines: [] }

  $.each(data, function(idx) {
    var row = data[idx]
    var idSegments = row.budget_line.split("/")
    row.area = idSegments.shift()
    idSegments.splice(1, 0, row.year)
    row.id = idSegments.join("/")
    delete row.amount
    delete row.budget_line
    delete row.year

    serializedData.budget_lines.push(row)
  })

  return JSON.stringify(serializedData);
}

window.GobiertoAdmin.gobierto_common_custom_field_records_budgets_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsBudgetsPluginController;
window.GobiertoAdmin.serializeBudgetsPluginData = serializeTableData

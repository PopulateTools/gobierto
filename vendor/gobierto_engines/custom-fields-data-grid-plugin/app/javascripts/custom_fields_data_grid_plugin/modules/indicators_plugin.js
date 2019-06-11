import { Grid, Editors, Plugins } from 'slickgrid-es6';
import { Select2Formatter, Select2Editor } from './data_grid_plugin_select2';

const defaultStartYear = 2018;
const defaultStartMonth = 12;
const defaultDateColumnsCount = 3;

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsDataGridPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsDataGridPluginController() {}

  var grid;

  GobiertoCommonCustomFieldRecordsDataGridPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
  };

  function _deserializeTableData(inputValue) {
    var inputDict = JSON.parse(inputValue);
    let deserializedData = []

    for (var termId in inputDict) {
      var newRow = inputDict[termId]
      newRow.indicator = termId
      deserializedData.push(newRow)
    }

    return deserializedData;
  }

  function _serializeTableData(data) {
    var serializedData = {}

    for (let i = 0; i < data.length; i++) {
      var indicatorId = data[i].indicator
      var indicatorValues = {}

      var validKeys = $.map(Object.keys(data[0]), function(key) {
        if (key !== "indicator" && data[0][key] != "") { return key }
      })

      $.each(validKeys, function(idx) {
        let date_key = validKeys[idx]
        indicatorValues[date_key] = data[i][date_key]
      })

      serializedData[indicatorId] = indicatorValues
    }

    return JSON.stringify(serializedData);
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

      _applyPluginStyles(element)
      _slickGrid(id, data, vocabularyTerms)

      $("form").submit(
        function() {
          $(".v_container .v_el .form_item.plugin_field.data_grid").each(function(i) {
            let uid = $(this).data("uid")
            $(`input[name$='[${uid}][value]']`).val(
              _serializeTableData($(this).data("slickGrid").getData())
            );
          });
        }
      );
    })
  }

  function _applyPluginStyles(element) {
    element.wrap("<div class='v_container'><div class='v_el v_el_level v_el_full_content'></div></div>");
    element.find("div.custom_field_value").addClass("indicators_table")
    element.find("div.data-container").addClass("slickgrid-container").css({ width: "100%", height: "500px" });
  }

  function _slickGrid(id, data, vocabularyTerms) {
    function _headerDateName(startYear, startMonth, offset) {
      return `${startYear + Math.floor((startMonth - 1 + offset)/12)}-${((startMonth - 1 + offset) % 12 + 1).toString().padStart(2, '0')}`;
    }

    function _dateColumn(startYear, startMonth, offset) {
      let headerName = _headerDateName(startYear, startMonth, offset);
      return {id: headerName, name: headerName, field: headerName, width: 100, editor: Editors.Text};
    }

    function _initializeGrid(id, data, columns, options) {
      var checkboxSelector = new Plugins.CheckboxSelectColumn({
        cssClass: "slick-cell-checkboxsel",
        hideSelectAllCheckbox: true
      });

      columns.unshift(checkboxSelector.getColumnDefinition());

      grid = new Grid(`#${id} .data-container`, data, columns, options);
      $(`#${id}`).data('slickGrid', grid);

      grid.setSelectionModel(new Plugins.CellSelectionModel());


      grid.onHeaderClick.subscribe(function (e, args) {
        let item = args.column;
        if(item.name === "Add"){
          let columns = args.grid.getColumns();
          let lastColumn = columns.pop();
          let lastYear = lastColumn.headerDateNameFunction(lastColumn.startYear, lastColumn.startMonth, lastColumn.offset)
          let columnDefinition = {id: lastYear, name: lastYear, field: lastYear, width: 100, editor: Editors.Text};
          lastColumn.offset++;
          columns.push(columnDefinition);
          columns.push(lastColumn);
          args.grid.setColumns(columns);
          args.grid.render();
        }
      });

      grid.onAddNewRow.subscribe(function (e, args) {
        let item = args.item;
        grid.invalidateRow(data.length);
        data.push(item);
        grid.updateRowCount();
        grid.invalidate();
        grid.render();
        $(`#${grid.getOptions().itemsCountId}`).html(data.length);
      });

      grid.registerPlugin(checkboxSelector);

      var deleteRowsButton = $('<button class="small js-delete-rows">Delete selected rows</button>');
      $(`#${id}`).append(deleteRowsButton);

      $('.js-delete-rows').click(function (e) {
        e.preventDefault();
        var selectedRows = grid.getSelectedRows();

        $.each(selectedRows, function(idx) {
          grid.getData().splice(selectedRows[idx], 1);
        })
        grid.invalidate()
      })

    }

    function _initializeEmptyTable(data, indicatorsNames) {
      for (let i = 0; i < defaultDateColumnsCount; i++) {
        columns.push(_dateColumn(defaultStartYear, defaultStartMonth, i));
      }
    }

    function _parseColumns(data) {
      let columns = [];

      var uniqueDates = Array.from(new Set(
        $.map(data, function(item) {
          return $.map(Object.keys(item), function(item_key) {
            if (item_key !== "indicator") { return item_key }
          })
        })
      ));

      var lastDateValues = uniqueDates[uniqueDates.length - 1].split("-");

      for (let item of uniqueDates) {
        let dateValues = item.split("-");
        columns.push(_dateColumn(parseInt(dateValues[0]), parseInt(dateValues[1]), 0));
      }

      return {
        lastYear: parseInt(lastDateValues[0]),
        lastMonth: parseInt(lastDateValues[1]),
        columns: columns
      };
    }

    let indicatorsDictionary = {}
    $.each(vocabularyTerms, function(idx) {
      let term = vocabularyTerms[idx];
      indicatorsDictionary[term.id] = term.name_translations[I18n.locale]
    });

    let new_column_id = `new_column_${id}`
    let dateColumnsCount = 5;
    let startYear = defaultStartYear;
    let startMonth = defaultStartMonth;
    let columns = [{
      id: "indicator",
      name: "Indicador",
      field: "indicator",
      width: 120,
      cssClass: "cell-title",
      formatter: Select2Formatter,
      editor: Select2Editor,
      dataSource: indicatorsDictionary
    }];

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

    var indicatorsNames = $.map(vocabularyTerms, function(item) { return item.name_translations[I18n.locale]});

    if (data.length === 0) {
      _initializeEmptyTable(data, indicatorsNames);
    } else {
      let columnsInfo = _parseColumns(data);
      columns = columns.concat(columnsInfo.columns);
      startYear = columnsInfo.lastYear;
      startMonth = columnsInfo.lastMonth;
      dateColumnsCount = 1;
    }

    // Create "button" to add new column
    columns.push({
      id: new_column_id,
      name: "Add",
      field: new_column_id,
      witdh: 50,
      headerCssClass: `add-${new_column_id}`,
      sortable: false,
      headerDateNameFunction: _headerDateName,
      startYear: startYear,
      startMonth: startMonth,
      offset: dateColumnsCount});

    _initializeGrid(id, data, columns, options);
  }
  return GobiertoCommonCustomFieldRecordsDataGridPluginController;
})();

window.GobiertoAdmin.gobierto_common_custom_field_records_data_grid_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsDataGridPluginController;

import { Grid, Data, Formatters, Editors, Plugins } from 'slickgrid-es6';

window.GobiertoAdmin.GobiertoCommonCustomFieldRecordsDataGridPluginController = (function() {

  function GobiertoCommonCustomFieldRecordsDataGridPluginController() {}

  GobiertoCommonCustomFieldRecordsDataGridPluginController.prototype.form = function(opts = {}) {
    _handlePluginData(opts.uid);
  };

  function _handlePluginData(uid) {
    let element = $(`[data-uid=${uid}]`)
    let id = element.attr('id')
    let data = JSON.parse($(`#${id}`).find("input[name$='[value]'").val())

    _applyPluginStyles(element)
    _slickGrid(id, data)

    $("form").submit(
      function() {
        $(".v_container .v_el .form_item.plugin_field.data_grid").each(function(i) {
          let uid = $(this).data("uid")
          $(`input[name$='[${uid}][value]']`).val(JSON.stringify($(this).data("slickGrid").getData()));
        });
      }
    );
  }

  function _applyPluginStyles(element) {
    element.wrap("<div class='v_container'><div class='v_el v_el_level v_el_full_content'></div></div>");
    element.find("div.custom_field_value").addClass("indicators_table")
    element.find("div.data-container").addClass("slickgrid-container").css({ width: "100%", height: "500px" });
  }

  function _slickGrid(id, data) {
    function requiredFieldValidator(value) {
      if (value == null || value == undefined || !value.length) {
        return {valid: false, msg: "This is a required field"};
      } else {
        return {valid: true, msg: null};
      }
    }

    function _headerDateName(startYear, startMonth, offset) {
      return `${startYear + Math.floor((startMonth - 1 + offset)/12)}-${((startMonth - 1 + offset) % 12 + 1).toString().padStart(2, '0')}`;
    }

    function _dateColumn(startYear, startMonth, offset) {
      let headerName = _headerDateName(startYear, startMonth, offset);
      return {id: headerName, name: headerName, field: headerName, width: 100, editor: Editors.Float};
    }

    function _dateColumnsFromData(data) {
      let columns = [];
      let firstRow = Object.assign({}, data[0]);
      delete firstRow.indicator
      let rowKeys = Object.keys(firstRow).sort();
      let lastDateValues = rowKeys[rowKeys.length - 1].split("-");
      for (let i = 0; i < rowKeys.length; i++) {
        let dateValues = rowKeys[i].split("-");
          columns.push(_dateColumn(parseInt(dateValues[0]), parseInt(dateValues[1]), 0));
      }
      return {
        lastYear: parseInt(lastDateValues[0]),
        lastMonth: parseInt(lastDateValues[1]),
        columns: columns
      };
    }

    let new_column_id = `new_column_${id}`
    let dateColumnsCount = 5;
    let startYear = 2018;
    let startMonth = 12;
    let grid;
    let columns = [{
      id: "indicator",
      name: "",
      field: "indicator",
      width: 120,
      cssClass: "cell-title",
      editor: Editors.Text,
      validator: requiredFieldValidator
    }];

    let options = {
      editable: true,
      enableAddRow: true,
      enableCellNavigation: true,
      asyncEditorLoading: false,
      enableColumnReorder: false,
      autoEdit: true,
      itemsCountId: `${id}_items`
    };

    $(function () {
      if (data.length === 0) {
        // initialize an empty table
        for (let i = 0; i < 5; i++) {
          let d = (data[i] = {});

          d["indicator"] = "indicator " + i;
          for (let o = 0; o < dateColumnsCount; o++) {
            d[_headerDateName(startYear, startMonth, o)] = null;
          }
        }

        for (let i = 0; i < dateColumnsCount; i++) {
          columns.push(_dateColumn(startYear, startMonth, i));
        }
      } else {
        let dateColumns = _dateColumnsFromData(data);
        columns = columns.concat(dateColumns.columns);
        startYear = dateColumns.lastYear;
        startMonth = dateColumns.lastMonth;
        dateColumnsCount = 1;
      }

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

      grid = new Grid(`#${id} .data-container`, data, columns, options);
      $(`#${id}`).data('slickGrid', grid);

      grid.setSelectionModel(new Plugins.CellSelectionModel());

      grid.onHeaderClick.subscribe(function (e, args) {
        let item = args.column;
        if(item.name === "Add"){
          let columns = args.grid.getColumns();
          let lastColumn = columns.pop();
          let lastYear = lastColumn.headerDateNameFunction(lastColumn.startYear, lastColumn.startMonth, lastColumn.offset)
          let columnDefinition = {id: lastYear, name: lastYear, field: lastYear, width: 100, editor: Editors.Integer};
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
    })

  }
  return GobiertoCommonCustomFieldRecordsDataGridPluginController;
})();

window.GobiertoAdmin.gobierto_common_custom_field_records_data_grid_plugin_controller = new GobiertoAdmin.GobiertoCommonCustomFieldRecordsDataGridPluginController;

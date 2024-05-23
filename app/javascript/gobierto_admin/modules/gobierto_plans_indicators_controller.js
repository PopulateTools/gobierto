import { SlickGrid, Editors, SlickCellSelectionModel } from 'slickgrid';

window.GobiertoAdmin.GobiertoPlansIndicatorsController = (function() {
  function GobiertoPlansIndicatorsController() {}

  GobiertoPlansIndicatorsController.prototype.form = function() {
    _handleGroupsList();
  };

  function _handleGroupsList() {

    // Toggle selected element child
    $('.v_container .v_el .icon-caret').click(function(e) {
      e.preventDefault();

      // ToDo: Don't relay on icon specific names
      if ($(this).is('.fa-caret-right')) {
        $(this).removeClass('fa-caret-right');
        $(this).addClass('fa-caret-down');
      }
      else {
        $(this).removeClass('fa-caret-down');
        $(this).addClass('fa-caret-right');
      }

      let vElement = $(this).parent().parent().parent().parent().find('> .v_el')
      vElement.toggleClass('el-opened');
      if (vElement.hasClass('el-opened')) {
        let id = vElement.attr('id');
        let data = JSON.parse($(`#${id}`).find("input").val())
        _slickGrid(id, data);
      }

    });

    // show only action buttons (edit, delete) when hovering an item
    // ToDo: Control that only elements for the item are shown, not for it's parents
    $('.v_el').hover(
      function(e) {
        $(this).first('.v_el_actions').addClass('v_el_active');
      },
      function(e) {
        $(this).first('.v_el_actions').removeClass('v_el_active');
      }
    );

    $("form").submit(
      function() {
        $(".v_container .v_el .v_el_content.el-opened").each(function(i) {
          let id = $(this).attr("id").replace(/[^\d]+/, "");
          $(`input[name='project[indicators][${id}]']`).val(JSON.stringify($(this).data("slickGrid").getData()));
        });
      }
    );
  }

  function _slickGrid(id, data) {
    function requiredFieldValidator(value) {
      if (value == null || value == undefined || !value.length) {
        return { valid: false, msg: "This is a required field" };
      } else {
        return { valid: true, msg: null };
      }
    }

    function _headerDateName(startYear, startMonth, offset) {
      return `${startYear + Math.floor((startMonth - 1 + offset)/12)}-${((startMonth - 1 + offset) % 12 + 1).toString().padStart(2, '0')}`;
    }

    function _dateColumn(startYear, startMonth, offset) {
      let headerName = _headerDateName(startYear, startMonth, offset);
      return { id: headerName, name: headerName, field: headerName, width: 100, editor: Editors.Float };
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
        for (let i = 0; i < 10; i++) {
          let d = (data[i] = {});

          d["indicator"] = "indicator " + i;
          for (let o = 0; o < dateColumnsCount; o++) {
            d[_headerDateName(startYear, startMonth, o)] = Math.round(Math.random() * 100);
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
        offset: dateColumnsCount });

      grid = new SlickGrid(`#${id} .slickgrid-container`, data, columns, options);
      $(`#${id}`).data('slickGrid', grid);

      grid.setSelectionModel(new SlickCellSelectionModel());

      grid.onHeaderClick.subscribe(function (e, args) {
        let item = args.column;
        if (item.name === "Add"){
          let columns = args.grid.getColumns();
          let lastColumn = columns.pop();
          let lastYear = lastColumn.headerDateNameFunction(lastColumn.startYear, lastColumn.startMonth, lastColumn.offset)
          let columnDefinition = { id: lastYear, name: lastYear, field: lastYear, width: 100, editor: Editors.Integer };
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

  return GobiertoPlansIndicatorsController;
})();

window.GobiertoAdmin.gobierto_plans_indicators_controller = new GobiertoAdmin.GobiertoPlansIndicatorsController;

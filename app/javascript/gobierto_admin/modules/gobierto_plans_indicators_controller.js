import { Grid, Data, Formatters, Editors, Plugins } from 'slickgrid-es6';

window.GobiertoAdmin.GobiertoPlansIndicatorsController = (function() {
  function GobiertoPlansIndicatorsController() {}

  GobiertoPlansIndicatorsController.prototype.form = function(opts) {
    _handleGroupsList();
  };

  function _handleGroupsList() {

    // Toggle selected element child
    $('.v_container .v_el .icon-caret').click(function(e) {
      e.preventDefault();

      // ToDo: Don't relay on icon specific names
      if($(this).is('.fa-caret-right')) {
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
        _slickGrid(vElement.attr('id'));
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

  }


  function _slickGrid(id) {
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
      return {id: headerName, name: headerName, field: headerName, width: 100, editor: Editors.Integer};
    }

    let new_column_id = `new_column_${id}`
    let dateColumnsCount = 5;
    let startYear = 2018;
    let startMonth = 12;
    let grid;
    let data = [];
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
      autoEdit: true
    };

    $(function () {
      for (let i = 0; i < 10; i++) {
        let d = (data[i] = {});

        d["indicator"] = "indicator " + i;
        for (let o = 0; o < dateColumnsCount; o++) {
          d[_headerDateName(startYear, startMonth, o)] =  Math.round(Math.random() * 100);
        }
      }

      for (let i = 0; i < dateColumnsCount; i++) {
        columns.push(_dateColumn(startYear, startMonth, i));
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

      grid = new Grid(`#${id} .slickgrid-container`, data, columns, options);

      grid.setSelectionModel(new Plugins.CellSelectionModel());

      $(`.add-${new_column_id}`).click(function() {
        let columns = grid.getColumns();
        let lastColumn = columns.pop();
        let lastYear = lastColumn.headerDateNameFunction(lastColumn.startYear, lastColumn.startMonth, lastColumn.offset)
        let columnDefinition = {id: lastYear, name: lastYear, field: lastYear, width: 100, editor: Editors.Integer};
        lastColumn.offset++
        columns.push(columnDefinition);
        columns.push(lastColumn);
        grid.setColumns(columns);
        grid.render();
      });

      grid.onAddNewRow.subscribe(function (e, args) {
        let item = args.item;
        grid.invalidateRow(data.length);
        data.push(item);
        grid.updateRowCount();
        grid.invalidate();
        grid.render();
      });
    })

  }

  return GobiertoPlansIndicatorsController;
})();

window.GobiertoAdmin.gobierto_plans_indicators_controller = new GobiertoAdmin.GobiertoPlansIndicatorsController;

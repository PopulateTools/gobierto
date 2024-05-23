import { EventHandler } from 'slickgrid';

export default class {
  constructor(options) {
    let _grid, $container, $deleteButton;

    const _handler = new EventHandler();
    let _selectedRowsLookup = {};
    const _defaults = {
      columnId: '_checkbox_selector',
      cssClass: null,
      toolTip: I18n.t("gobierto_admin.custom_fields_plugins.data_grid.select_deselect_all"),
      width: 30,
      deleteRowsButtonClass: "js-delete-rows"
    };

    const _options = $.extend(true, {}, _defaults, options);

    function init(grid){
      _grid = grid;
      _handler
      .subscribe(_grid.onClick, handleClick)
      .subscribe(_grid.onHeaderClick, handleHeaderClick)
      .subscribe(_grid.onKeyDown, handleKeyDown);

      const deleteRowsButton = $(`<button class="small ${_options.deleteRowsButtonClass}">${I18n.t("gobierto_admin.custom_fields_plugins.data_grid.remove_rows")}</button>`);
      $container = $(`#${_options.containerId}`);
      $container.append(deleteRowsButton);

      $deleteButton = $container.find(`.${_options.deleteRowsButtonClass}`);
      $deleteButton.hide();
      $deleteButton.click(removeRow);
    }

    function destroy(){
      _handler.unsubscribeAll();
    }

    function handleKeyDown(e, args){
      if (e.which == 32){
        if (_grid.getColumns()[args.cell].id === _options.columnId){
          // if editing, try to commit
          if (!_grid.getEditorLock().isActive() || _grid.getEditorLock().commitCurrentEdit()){
            toggleRowSelection(args.row);
          }
          e.preventDefault();
          e.stopImmediatePropagation();
        }
      }
    }

    function handleClick(e, args){
      // clicking on a row select checkbox
      if (_grid.getColumns()[args.cell].id === _options.columnId && $(e.target).is(':checkbox')){
        // if editing, try to commit
        if (_grid.getEditorLock().isActive() && !_grid.getEditorLock().commitCurrentEdit()){
          e.preventDefault();
          e.stopImmediatePropagation();
          return;
        }

        var currentSelectedRows = _grid.getSelectedRows();

        if ($(e.target).is(":checked")) {
          // Show delete button
          $deleteButton.show();
          // ensure row is selected
          var newSelectedRows = currentSelectedRows.concat(args.row);
          _grid.setSelectedRows(newSelectedRows);
        } else {
          // Hide delete button
          $deleteButton.hide();
          // ensure row is not selected
          var index = currentSelectedRows.indexOf(args.row);
          if (index != -1) {
            currentSelectedRows.splice(index, 1)
            _grid.setSelectedRows(currentSelectedRows);
          }
        }

        e.stopPropagation();
        e.stopImmediatePropagation();
      }
    }

    function removeRow(e) {
      e.preventDefault();
      let rowsToRemove = [];
      _grid.getSelectedRows().forEach(idx => {
        rowsToRemove.push(_grid.getData()[idx]);
      })

      rowsToRemove.forEach(row => {
        _grid.getData().forEach((d, idx) => {
          if (JSON.stringify(row) === JSON.stringify(d)){
            _grid.getData().splice(idx, 1);
          }
        })
      });
      _grid.setSelectedRows([]);
      _grid.invalidate()

      // Hide button
      $deleteButton.hide();
    }

    function toggleRowSelection(row){
      if (_selectedRowsLookup[row]){
        _grid.setSelectedRows($.grep(_grid.getSelectedRows(), function(n){
          return n != row;
        }));
      } else {
        _grid.setSelectedRows(_grid.getSelectedRows().concat(row));
      }
    }

    function handleHeaderClick(e, args){
      if (args.column.id == _options.columnId && $(e.target).is(':checkbox')){
        // if editing, try to commit
        if (_grid.getEditorLock().isActive() && !_grid.getEditorLock().commitCurrentEdit()){
          e.preventDefault();
          e.stopImmediatePropagation();
          return;
        }

        // Check / uncheck all checkboxes
        if ($(e.target).is(':checked')){
          $container.find("input:checkbox").attr("checked", true);
          $deleteButton.show();
        } else {
          $container.find("input:checkbox").attr("checked", false);
          $deleteButton.hide();
        }

        if ($(e.target).is(':checked')){
          const rows = [];
          for (let i = 0; i < _grid.getDataLength(); i++){
            rows.push(i);
          }
          _grid.setSelectedRows(rows);
        } else {
          _grid.setSelectedRows([]);
        }
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
    }

    function getColumnDefinition(){
      return {
        id: _options.columnId,
        name: "<input type='checkbox'>",
        toolTip: _options.toolTip,
        field: 'sel',
        width: _options.width,
        resizable: false,
        sortable: false,
        cssClass: _options.cssClass,
        formatter: checkboxSelectionFormatter
      };
    }

    function checkboxSelectionFormatter(row, cell, value, columnDef, dataContext){
      if (dataContext){
        return _selectedRowsLookup[row]
          ? "<input type='checkbox' checked='checked'>"
          : "<input type='checkbox'>";
      }
      return null;
    }

    Object.assign(this, {
      init,
      destroy,

      getColumnDefinition
    });
  }
}

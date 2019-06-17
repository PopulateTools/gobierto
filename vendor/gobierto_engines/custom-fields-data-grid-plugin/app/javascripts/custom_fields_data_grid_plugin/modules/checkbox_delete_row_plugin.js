import { Slick } from 'slickgrid-es6';

export default class {
  constructor(options) {
    let _grid;
    const _self = this;
    const _handler = new Slick.EventHandler();
    let _selectedRowsLookup = {};
    const _defaults = {
      columnId: '_checkbox_selector',
      cssClass: null,
      toolTip: 'Select/Deselect All',
      width: 30
    };

    const _options = $.extend(true, {}, _defaults, options);

    function init(grid){
      _grid = grid;
      _handler
      .subscribe(_grid.onClick, handleClick)
      .subscribe(_grid.onHeaderClick, handleHeaderClick)
      .subscribe(_grid.onKeyDown, handleKeyDown);
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
      console.log("checkbox plugin - handleClick")
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
          // ensure row is selected
          var newSelectedRows = currentSelectedRows.concat(args.row);
          _grid.setSelectedRows(newSelectedRows);
        } else {
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

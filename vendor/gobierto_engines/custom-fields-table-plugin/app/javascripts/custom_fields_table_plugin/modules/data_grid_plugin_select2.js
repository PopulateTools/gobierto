import { GlobalEditorLock, keyCode } from 'slickgrid';
import { toPairs } from 'lodash';

function PopulateSelect(select, dataSource, addBlank) {
  var newOption;

  if (dataSource === null) { return }

  if (addBlank) { select.appendChild(new Option('', '')); }

  if (dataSource.grouped) {
    $.each(dataSource.grouped, function (groupKey, groupItems) {
      let groupName = I18n.t(`gobierto_admin.custom_fields_plugins.common.${groupKey}`)
      var $group = $(`<optgroup label="${groupName}"></optgroup`)
      $group.appendTo($(select));

      var groupItemsPairs = toPairs(groupItems)
      $.each(groupItemsPairs, function(idx) {
        newOption = new Option(groupItemsPairs[idx][1], groupItemsPairs[idx][0]);
        $group[0].appendChild(newOption);
      })
    });
  } else if (Array.isArray(dataSource)) {
    $.each(dataSource, function (_idx, value) {
      newOption = new Option(value, value)
      select.appendChild(newOption)
    })
  } else {
    $.each(dataSource, function (value, text) {
      newOption = new Option(text, value);
      select.appendChild(newOption);
    });
  }
}

export function Select2Formatter(_row, _cell, value, columnDef) {
  if (columnDef.dataSource === null) { return }
  var groupedData = columnDef.dataSource.grouped

  if (groupedData) {
    var result
    $.each(groupedData, function (_groupKey, groupItems) {
      $.each(groupItems, function (itemValue) {
        if (groupedData[itemValue.split("/")[0]][value]) {
          result = groupedData[itemValue.split("/")[0]][value]
          return false
        }
      })
      if (result) return false
    })
  }

  if (Array.isArray(columnDef.dataSource) && columnDef.dataSource.indexOf(value) > -1) {
    return value
  }

  return result || columnDef.dataSource[value] || '-'
}

export function Select2Editor(args) {
  var _grid = args.grid
  var $input;
  var defaultValue;
  var _allowBlank = false

  this.keyCaptureList = [keyCode.UP, keyCode.DOWN, keyCode.ENTER];

  this.init = function () {
    $input = $('<select></select>');
    $input.width(args.container.clientWidth + 3);
    PopulateSelect($input[0], args.column.dataSource, _allowBlank)
    $input.appendTo(args.container);
    $input.focus().select();

    $input.select2({
      placeholder: '-',
      allowClear: _allowBlank
    });

    /* Automatically remove focus after chosing an option */
    $input.on('select2:close', function() {
      var lock = GlobalEditorLock
      if (lock.isActive()) lock.commitCurrentEdit()

      _grid.resetActiveCell()
    })
  };

  this.destroy = function () {
    // Don't close to avoid conflict on close callback
    // $input.select2('close');
    $input.select2('destroy');
    $input.remove();
  };

  this.show = function () {
    $input.select2('open');
  };

  this.hide = function () {
  };

  this.position = function (position) {
  };

  this.focus = function () {
    $input.select2('input_focus');
  };

  this.loadValue = function (item) {
    defaultValue = item[args.column.field];
    $input.val(defaultValue);
    $input[0].defaultValue = defaultValue;
    $input.trigger("change.select2");
  };

  this.serializeValue = function () {
    var inputValue = $input.val()
    var inputValueInt = parseInt(inputValue)

    if (isNaN(inputValueInt)) return inputValue
    return inputValueInt
  };

  this.applyValue = function (item, state) {
    item[args.column.field] = state;
  };

  this.isValueChanged = function () {
    return (!($input.val() == "" && defaultValue == null)) && ($input.val() != defaultValue);
  };

  this.validate = function () {
    return {
      valid: true,
      msg: null
    };
  };

  this.init();
}

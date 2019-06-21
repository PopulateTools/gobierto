import 'select2'
import { Slick } from 'slickgrid-es6';

export { Select2Formatter, Select2Editor }

function PopulateSelect(select, dataSource, addBlank) {
  var newOption;

  if (addBlank) { select.appendChild(new Option('', '')); }

  $.each(dataSource, function (value, text) {
    newOption = new Option(text, value);
    select.appendChild(newOption);
  });
};

function Select2Formatter(_row, _cell, value, columnDef, _dataContext) {
  return columnDef.dataSource[value] || '-';
}

function Select2Editor(args) {
  var $input;
  var defaultValue;

  this.keyCaptureList = [Slick.keyCode.UP, Slick.keyCode.DOWN, Slick.keyCode.ENTER];

  this.init = function () {
    $input = $('<select></select>');
    $input.width(args.container.clientWidth + 3);
    PopulateSelect($input[0], args.column.dataSource, true);
    $input.appendTo(args.container);
    $input.focus().select();

    $input.select2({
      placeholder: '-',
      allowClear: true
    });
  };

  this.destroy = function () {
    $input.select2('close');
    $input.select2('destroy');
    $input.remove();
  };

  this.show = function () {
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
    return $input.val();
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

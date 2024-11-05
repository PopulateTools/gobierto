import 'air-datepicker'

export { DateEditor }

/* TODO: avoid duplication */
$.fn.datepicker.language['en'] = {
  days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  daysShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
  daysMin: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
  months: ['January','February','March','April','May','June', 'July','August','September','October','November','December'],
  monthsShort: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  today: 'Today',
  clear: 'Clear',
  dateFormat: 'yyyy-mm-dd',
  timeFormat: 'hh:ii aa',
  firstDay: 0
};

$.fn.datepicker.language['ca'] = {
  days: ['Diumenge', 'Dilluns', 'Dimarts', 'Dimecres', 'Dijous', 'Divendres', 'Dissabte'],
  daysShort: ['Diu', 'Dill', 'Dima', 'Dime', 'Dij', 'Div', 'Dis'],
  daysMin: ['Dg', 'Dl', 'Dm', 'Dc', 'Dj', 'Dv', 'Ds'],
  months: ['Gener','Febrer','Març','Abril','Maig','Juny', 'Juliol','Agost','Setembre','Octubre','Novembre','Desembre'],
  monthsShort: ['Gen', 'Feb', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Des'],
  today: 'Avui',
  clear: 'Netejar',
  dateFormat: 'yyyy-mm-dd',
  timeFormat: 'hh:ii aa',
  firstDay: 1
};

$.fn.datepicker.language['es'] = {
  days: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
  daysShort: ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'],
  daysMin: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
  months: ['Enero','Febrero','Marzo','Abril','Mayo','Junio', 'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
  monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
  today: 'Hoy',
  clear: 'Limpiar',
  dateFormat: 'yyyy-mm-dd',
  timeFormat: 'hh:ii aa',
  firstDay: 1
};
/* ./ TODO: avoid duplication */

function DateEditor(args) {
  let $input,
    datepickerInstance,
    defaultDate,
    options = args.column.options && args.column.options.date ? args.column.options.date : {};

  this.init = function(){
    defaultDate = options.defaultDate = args.item[args.column.field];

    $input = $('<input type="text" class="editor-text" autocomplete="off" disabled />');
    $input.appendTo(args.container);
    $input.focus().val(defaultDate).select();

    datepickerInstance = $input.datepicker({
      autoClose: true,
      language: I18n.locale
    }).data('datepicker');
  };

  this.destroy = function() {
    datepickerInstance.destroy();
    $input.remove();
  };

  this.show = function() {
    datepickerInstance.show();
  };

  this.hide = function() {
    datepickerInstance.hide();
  };

  this.position = function() {};

  this.focus = function(){
    $input.focus();
  };

  this.loadValue = function(item) {
    var currentDateString = item[args.column.field];
    var date = currentDateString ? new Date(currentDateString) : new Date()

    $input.val(currentDateString);
    $input.select();
    datepickerInstance.selectDate(date);
  };

  this.serializeValue = function(){
    return $input.val();
  };

  this.applyValue = function(item, state){
    item[args.column.field] = state;
  };

  this.isValueChanged = function(){
    return (!($input.val() == '' && defaultDate == null)) && ($input.val() != defaultDate);
  };

  this.validate = function(){
    if (args.column.validator){
      let validationResults = args.column.validator($input.val(), args);
      if (!validationResults.valid){
        return validationResults;
      }
    }

    return {
      valid: true,
      msg: null
    };
  };

  this.init();
}

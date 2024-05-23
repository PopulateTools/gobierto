import 'air-datepicker';
import 'air-datepicker/dist/css/datepicker.css';

$.fn.datepicker.language["en"] = {
  days: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
  daysShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
  daysMin: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"],
  months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
  monthsShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
  today: "Today",
  clear: "Clear",
  dateFormat: "mm/dd/yyyy",
  timeFormat: "hh:ii aa",
  firstDay: 0
};

$.fn.datepicker.language["ca"] = {
  days: ["Diumenge", "Dilluns", "Dimarts", "Dimecres", "Dijous", "Divendres", "Dissabte"],
  daysShort: ["Diu", "Dill", "Dima", "Dime", "Dij", "Div", "Dis"],
  daysMin: ["Dg", "Dl", "Dm", "Dc", "Dj", "Dv", "Ds"],
  months: ["Gener", "Febrer", "Març", "Abril", "Maig", "Juny", "Juliol", "Agost", "Setembre", "Octubre", "Novembre", "Desembre"],
  monthsShort: ["Gen", "Feb", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Des"],
  today: "Avui",
  clear: "Netejar",
  dateFormat: "dd/mm/yyyy",
  timeFormat: "hh:ii aa",
  firstDay: 1
};

$.fn.datepicker.language["es"] = {
  days: ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"],
  daysShort: ["Dom", "Lun", "Mar", "Mie", "Jue", "Vie", "Sab"],
  daysMin: ["Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sa"],
  months: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"],
  monthsShort: ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"],
  today: "Hoy",
  clear: "Limpiar",
  dateFormat: "dd/mm/yyyy",
  timeFormat: "hh:ii aa",
  firstDay: 1
};

// http://t1m0n.name/air-datepicker/docs/
export class Datepicker {
  constructor(elem, options) {
    this.element = elem || undefined

    if (this.element) {
      const $selector = $(this.element)
      if ($selector.data('datepicker') === undefined) {
        $selector.datepicker(options);
      }

      return $selector.data('datepicker');
    }
  }

  destroy() {
    $(this.element).data('datepicker').destroy()
  }
}

'use strict';

var CardIndicators = Class.extend({
  init: function(divClass, city_id) {
    var es_ES = {
      "decimal": ",",
      "thousands": ".",
      "grouping": [3],
      "currency": ["€", ""],
      "dateTime": "%a %b %e %X %Y",
      "date": "%d/%m/%Y",
      "time": "%H:%M:%S",
      "periods": ["AM", "PM"],
      "days": ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"],
      "shortDays": ["Dom", "Lun", "Mar", "Mi", "Jue", "Vie", "Sab"],
      "months": ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"],
      "shortMonths": ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
    };
    
    // Set formats
    d3.timeFormatDefaultLocale(es_ES);
    var parseDate = d3.timeParse("%Y-%m-%d");
    var formatDate = d3.timeFormat("%B %Y");
    
    d3.selectAll(divClass).each(function(d) {
      var div = d3.select(this);
      var dataUrl = d3.select(this).attr('data-url');
      var dataType = d3.select(this).attr('data-type');
      var url = dataUrl + city_id;
      
      d3.json(url)
        .header('authorization', 'Bearer ' + window.tbiToken)
        .get(function(error, json) {
          if (error) throw error;
          
          // console.log(json)
          
          var parsedDate = parseDate(json.data[0].date);
          
          // Paint the figure
          div.select('.widget_figure')
            .text(function() {
              // Switch between different figure types
              switch (dataType) {
                case 'percentage':
                  return accounting.formatNumber(json.data[0].value, 1) + '%';
                  break;
                case 'currency':
                  return accounting.formatNumber(json.data[0].value, 1) + '€';
                  break;
                default:
                  return accounting.formatNumber(json.data[0].value, 0);
              }
            });
          
          // Append source 
          div.selectAll('.widget_src')
            .append('a')
            .attr('href', json.metadata.indicator['source url'])
            .text(json.metadata.indicator['source name']);
            
          // Append date of last data point
          div.select('.widget_updated')
            .text(formatDate(parsedDate));
            
          // Append metadata
          div.selectAll('.js-data-desc')
            .text(json.metadata.indicator.name);
            
          div.selectAll('.js-data-freq')
            .text(function() {
              // Switch between different figure types
              switch (json.metadata.frequency_type) {
                case 'yearly':
                  return 'anualmente'
                  break;
                case 'monthly':
                  return 'mensualmente'
                  break;
                case 'weekly':
                  return 'semanalmente'
                  break;
                case 'daily':
                  return 'diariamente'
                  break;
                default:
                  return ''
              }
            });
            
          if (typeof json.data[1] !== 'undefined') {
            var pctChange = (json.data[0].value / json.data[1].value * 100) - 100;
            var pctFormat = accounting.formatNumber(pctChange, 1) + '%';
            var isPositive = pctChange > 0;
            
            // If is a positive change, attach a plus sign to the number
            div.select('.widget_pct')
              .text(function() { return isPositive ? '+' + pctFormat : pctFormat; });
            
            // Return the correct icon
            div.select('.widget_pct')
              .append('i')
              .attr('aria-hidden', 'true')
              .attr('class', function() {
                return isPositive ? 'fa fa-caret-up' : 'fa fa-caret-down';
              });
          }
        });
    });
  }
});
  

'use strict';

var CardIndicators = Class.extend({
  init: function(divClass, city_id) {
    // Set formats
    d3.timeFormatDefaultLocale(eval(I18n.locale));
    var parseDate = d3.timeParse("%Y-%m-%d");
    var formatDate = d3.timeFormat("%B %Y");

    d3.selectAll(divClass).each(function(d) {
      var div = d3.select(this);
      var dataUrl = d3.select(this).attr('data-url');
      var dataType = d3.select(this).attr('data-type');
      var url = dataUrl + city_id;

      d3.json(url)
        .header('authorization', 'Bearer ' + window.populateData.token)
        .get(function(error, json) {
          if (error) throw error;

          var parsedDate = parseDate(json.data[0].date);

          // Paint the figure
          div.select('.widget_figure')
            .text(printData);

          // Append source
          div.selectAll('.widget_src')
            .text(json.metadata.indicator['source name']);

          // Append date of last data point
          div.selectAll('.widget_updated')
            .text(formatDate(parsedDate));

          // Append metadata
          div.selectAll('.js-data-desc')
            .text(json.metadata.indicator.name);
            
          div.selectAll('.tw-sharer')
            .attr('target', '_blank')
            .attr('href', 'https://twitter.com/intent/tweet?text=' + 'En ' + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(json.metadata.name).toLowerCase() + ' en ' + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(printData())  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

          div.selectAll('.fb-sharer')
            .attr('target', '_blank')
            .attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href);

          div.selectAll('.js-data-freq')
            .text(printFreq);

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
          
          function printData() {
            // Switch between different figure types
            switch (dataType) {
              case 'percentage':
                return accounting.formatNumber(json.data[0].value, 1) + '%';
                break;
              case 'currency':
                return accounting.formatNumber(json.data[0].value, 1) + '€';
                break;
              case 'currency_per_person':
                return accounting.formatNumber(json.data[0].value, 1) + '€/' + I18n.t('gobierto_indicators.inhabitants');
                break;
              default:
                return accounting.formatNumber(json.data[0].value, 0);
            }
          };
          
          function printFreq() {
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
          };
          
        });
    });
  }
});


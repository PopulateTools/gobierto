'use strict';

var CardIndicators = Class.extend({
  init: function(divClass, city_id) {
    d3.selectAll(divClass).each(function(d) {
      var div = d3.select(this);
      var dataSlug = d3.select(this).attr('data-slug');
      var url = 'https://tbi.populate.tools/gobierto/datasets/' + dataSlug + '.json?sort_desc_by=date&filter_by_location_id=' + city_id;
      
      d3.json(url)
        .header('authorization', 'Bearer ' + window.tbiToken)
        .get(function(error, data) {
          if (error) throw error;

          // Paint the figure
          div.select('.widget_figure')
            .datum(data)
            .text(function(d) { return accounting.formatNumber(d[0].value, 0) });
          
          // Only calculated if we want to show a pct variation in the indicator
          if ($('.widget_pct').length > 0) {
            var pctChange = (data[0].value / data[1].value * 100) - 100;
            var pctFormat = accounting.formatNumber(pctChange, 1);
            var isPositive = pctChange > 0;
            
            // If is a positive change, attach a plus sign to the number
            div.select('.widget_pct')
              .datum(data)
              .text(function() {
                return isPositive ? '+' + pctFormat : pctFormat;
              });
            
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
  

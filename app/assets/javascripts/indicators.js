$(document).on('turbolinks:load', function() {
  var vis_agedb = [];
  var vis_unempl = [];

  if ($('#age_distribution').length > 0) {
    var vis = new VisAgeDistribution('#age_distribution', '39075', '2015');
    vis.render();
    vis_agedb.push(vis);
  }
  
  if ($('#unemployment_age').length > 0) {
    var vis = new VisUnemploymentAge('#unemployment_age', '39075', '2015');
    vis.render();
    vis_unempl.push(vis);
  }
  
  // Render indicator cards info
  if ($('.indicator_widget').length > 0) {
    var cityId = '39075';
    
    d3.selectAll('.indicator_widget').each(function(d, i) {
      var dataSlug = d3.select(this).attr('data-slug');
      var div = d3.select(this);
      var url = 'https://tbi.populate.tools/gobierto/datasets/' + dataSlug + '.json?sort_desc_by=date&filter_by_location_id=' + cityId;
      
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
            
            // If is a positive change, attach a plus sign to the number
            div.select('.widget_pct')
              .datum(data)
              .text(function() {
                return pctChange > 0 ? '+' + pctFormat : pctFormat;
              });
            
            // Return the correct icon
            div.select('.widget_pct')
              .append('i')
              .attr('aria-hidden', 'true')
              .attr('class', function() {
                return pctChange > 0 ? 'fa fa-caret-up' : 'fa fa-caret-down';
              });
          }
        });
    });
  }
  
});

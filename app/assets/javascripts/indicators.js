$(document).on('turbolinks:load', function() {
  var city = '39075';
  var year = '2015';
  
  if ($('#age_distribution').length > 0) {
    var vis_agedb = new VisAgeDistribution('#age_distribution', city, year);
    vis_agedb.render();
  }
  
  if ($('#unemployment_age').length > 0) {
    var vis_unempl = new VisUnemploymentAge('#unemployment_age', city, year);
    vis_unempl.render();
  }
  
  // Paint the city name
  if ($('.js-city').length > 0) {
    d3.json('https://tbi.populate.tools/gobierto/datasets/ds-poblacion-municipal.json?include=municipality&limit=1&filter_by_location_id=' + city)
      .header('authorization', 'Bearer ' + window.tbiToken)
      .get(function(error, json) {
        if (error) throw error;
        
        d3.selectAll('.js-city')
          .text(json[0].municipality_name);
      });
  }
  
  // Render indicator cards info
  if ($('.indicator_widget').length > 0) {
    new CardIndicators('.indicator_widget', city);
    
    // Show dataset info while hovering in circles
    $('.fa-question-circle').hover(
      function() {
        $(this).parents('.pure-u-md-1-3').find('.widget_body').hide();
        $(this).parents('.pure-u-md-1-3').find('.widget_info').show();
      }, function(e) {
        $(this).parents('.pure-u-md-1-3').find('.widget_body').show();
        $(this).parents('.pure-u-md-1-3').find('.widget_info').hide();
      }
    );
  }
  
});

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
  
  if ($('#unemployment_sectors').length > 0) {
    var vis_unemplSec = new VisUnemploymentSectors('#unemployment_sectors', city, year);
    vis_unemplSec.render();
  }
  
  if ($('#rent_distribution').length > 0) {
    var vis_rent = new VisRentDistribution('#rent_distribution', city, year);
    vis_rent.render();
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
    $('.indicator_widget').click(function() {
      $(this).find('.widget_headline i').toggleClass('fa-question-circle fa-times');
      $(this).find('.widget_body').toggle();
      $(this).find('.widget_info').toggle();
    });
  }
  
});

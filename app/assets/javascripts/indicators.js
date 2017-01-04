$(document).on('turbolinks:load', function() {
  var city_id = '39075';
  var year = '2015';
  
  if ($('#age_distribution').length > 0) {
    var vis_agedb = new VisAgeDistribution('#age_distribution', city_id, year);
    vis_agedb.render();
  }
  
  if ($('#unemployment_age').length > 0) {
    var vis_unempl = new VisUnemploymentAge('#unemployment_age', city_id, year);
    vis_unempl.render();
  }
  
  // Render indicator cards info
  if ($('.indicator_widget').length > 0) {
    new CardIndicators('.indicator_widget', city_id);
    
    // $('.fa-question-circle').hover(
    //   function() {
    //     console.log('hover')
    //     $(this).parents().find('.widget_info').css('display', 'block');
    //     $(this).parents().find('.widget_body').css('display', 'none');
    //   }, function() {
    //     console.log('leaving')
    //     $(this).parents().find('.widget_info').css('display', 'none');
    //     $(this).parents().find('.widget_body').css('display', 'block');
    //   }
    // );
  }
  
});

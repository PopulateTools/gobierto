$(document).on('turbolinks:load', function() {
  if ($('#age_distribution').length > 0) {
    var vis_agedb = new VisAgeDistribution('#age_distribution', '39075', '2015');
    vis_agedb.render();
  }
  
  if ($('#unemployment_age').length > 0) {
    var vis_unempl = new VisUnemploymentAge('#unemployment_age', '39075', '2015');
    vis_unempl.render();
  }
  
  // Render indicator cards info
  if ($('.indicator_widget').length > 0) {
    new CardIndicators('.indicator_widget', '39075');
    
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

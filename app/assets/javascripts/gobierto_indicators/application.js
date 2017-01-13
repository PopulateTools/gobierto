//= require_directory ./visualizations/

$(document).on('turbolinks:load', function() {
  if ($('#age_distribution').length > 0) {
    var vis_agedb = new VisAgeDistribution('#age_distribution', window.populateData.municipalityId, window.populateData.year);
    vis_agedb.render();
  }

  if ($('#unemployment_age').length > 0) {
    var vis_unempl = new VisUnemploymentAge('#unemployment_age', window.populateData.municipalityId, window.populateData.year);
    vis_unempl.render();
  }

  if ($('#unemployment_sectors').length > 0) {
    var vis_unemplSec = new VisUnemploymentSectors('#unemployment_sectors', window.populateData.municipalityId, window.populateData.year);
    vis_unemplSec.render();
  }

  if ($('#rent_distribution').length > 0) {
    var vis_rent = new VisRentDistribution('#rent_distribution', window.populateData.municipalityId, window.populateData.year);
    vis_rent.render();
  }

  // Render indicator cards info
  if ($('.indicator_widget').length > 0) {
    new CardIndicators('.indicator_widget', window.populateData.municipalityId);

    // Show dataset info while hovering in circles
    $('.indicator_widget').click(function() {
      $(this).find('.widget_headline i').toggleClass('fa-question-circle fa-times');
      $(this).find('.widget_body').toggle();
      $(this).find('.widget_info').toggle();
    });
  }
});

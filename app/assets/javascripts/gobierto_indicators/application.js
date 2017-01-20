//= require_directory ./visualizations/

function selectSection(html){
  var $el = $('[data-breadcrumb-sub-item]');
  if($el.prev()[0].tagName !== "SPAN")
    $('<span>/</span>').insertBefore($el);

  if(html === undefined) {
    $('.sub_sections li a').each(function(){
      if($(this).attr('href').indexOf(window.location.hash) !== -1)
        $el.html($(this).html());
    });
  } else {
    $el.html(html);
  }
}

$(document).on('turbolinks:click', function (event) {
  if (event.target.getAttribute('href').indexOf('#') !== -1) {
    event.preventDefault();
    selectSection($(event.target).html());
    return;
  }
})

$(document).on('turbolinks:load', function() {
  if ($('#age_distribution').length && !$('#age_distribution svg').length) {
    var vis_agedb = new VisAgeDistribution('#age_distribution', window.populateData.municipalityId, window.populateData.year - 1);
    vis_agedb.render();
  }

  if ($('#unemployment_age').length && !$('#unemployment_age svg').length) {
    var vis_unempl = new VisUnemploymentAge('#unemployment_age', window.populateData.municipalityId);
    vis_unempl.render();
  }

  if ($('#unemployment_sectors').length && !$('#unemployment_sectors svg').length) {
    var vis_unemplSec = new VisUnemploymentSectors('#unemployment_sectors', window.populateData.municipalityId);
    vis_unemplSec.render();
  }

  if ($('#rent_distribution').length && !$('#rent_distribution svg').length) {
    var vis_rent = new VisRentDistribution('#rent_distribution', window.populateData.municipalityId, window.populateData.year - 1);
    vis_rent.render();
  }

  // Render indicator cards info
  if ($('.indicator_widget').length) {
    new CardIndicators('.indicator_widget', window.populateData.municipalityId);

    // Show dataset info while hovering in circles
    $('.indicator_widget').click(function() {
      $(this).find('.widget_headline i').toggleClass('fa-question-circle fa-times');
      $(this).find('.widget_body').toggle();
      $(this).find('.widget_info').toggle();
    });
  }

  if(window.location.hash !== ""){
    selectSection();
  }
});

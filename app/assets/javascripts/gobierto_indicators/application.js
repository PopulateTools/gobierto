//= require_directory ./visualizations/
//= require_directory ./cards/

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
    var vis_unempl = new VisUnemploymentAge('#unemployment_age', 39073);
    vis_unempl.render();
  }

  if ($('#unemployment_sex').length && !$('#unemployment_sex svg').length) {
    var vis_unemplSex = new VisUnemploymentSex('#unemployment_sex', window.populateData.municipalityId);
    vis_unemplSex.render();
  }

  if ($('#rent_distribution').length && !$('#rent_distribution svg').length) {
    var vis_rent = new VisRentDistribution('#rent_distribution', window.populateData.municipalityId, window.populateData.year - 1);
    vis_rent.render();
  }
  
  var popCard = new PopulationCard('.population-card', populateData.municipalityId);
  popCard.render();
  
  var activePopCard = new ActivePopulationCard('.active-pop-card', populateData.municipalityId);
  activePopCard.render();
  
  var hCard = new HomesCard('.homes-card', populateData.municipalityId);
  hCard.render();
  
  var ssCard = new ssMembersCard('.ss-members', populateData.municipalityId);
  ssCard.render();
  
  var fCard = new FreelancersCard('.freelancers', populateData.municipalityId);
  fCard.render();
  
  var cCard = new CompaniesCard('.companies', populateData.municipalityId);
  cCard.render();
  
  var contractsCard = new ContractsCard('.contracts-comparison', populateData.municipalityId);
  contractsCard.render();
  
  var unBySector = new UnemplBySectorCard('.unemployed-sector', populateData.municipalityId);
  unBySector.render();
  
  // var birthRate = new BirthRateCard('.births', populateData.municipalityId);
  // birthRate.render();

  // // Render indicator cards info
  // if ($('.indicator_widget').length) {
  //   new CardIndicators('.indicator_widget', window.populateData.municipalityId);
  // 
  //   // Show dataset info on click
  //   $('.card_container').click(function() {
  //     $(this).toggleClass('hover');
  //   });
  // }

  if(window.location.hash !== ""){
    selectSection();
  }
});

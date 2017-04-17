//= require_directory ./visualizations/
//= require_directory ./cards/
//= require_directory ./lib/

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
  var getUnemplAgeData = new GetUnemploymentAgeData(window.populateData.municipalityId);
  
  // Process unemployment age data and pass it to the charts
  getUnemplAgeData.getData(function() {
    // Needs the data to set the same y scale
    if ($('#unemployment_sex').length && !$('#unemployment_sex svg').length) {
      var vis_unemplSex = new VisUnemploymentSex('#unemployment_sex', window.populateData.municipalityId, window.unemplAgeData);
      vis_unemplSex.render();
    }
    
    if ($('#unemployment_age').length && !$('#unemployment_age svg').length) {
      var vis_unempl = new VisUnemploymentAge('#unemployment_age', window.populateData.municipalityId, window.unemplAgeData);
      vis_unempl.render();
    }
  })

  if ($('#age_distribution').length && !$('#age_distribution svg').length) {
    var vis_agedb = new VisAgeDistribution('#age_distribution', window.populateData.municipalityId, window.populateData.year - 1);
    vis_agedb.render();
  }
  
  if ($('#unemployment_rate').length && !$('#unemployment_rate svg').length) {
    var vis_unemplR = new VisUnemploymentRate('#unemployment_rate', window.populateData.municipalityId, window.populateData.ccaaId);
    vis_unemplR.render();
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
  
  var unBySectorCard = new UnemplBySectorCard('.unemployed-sector', populateData.municipalityId);
  unBySectorCard.render();
  
  var contrSectorCard = new ContractsBySectorCard('.contracts-sector', populateData.municipalityId);
  contrSectorCard.render();
  
  var incomeCard = new IncomeCard('.income', populateData.municipalityId);
  incomeCard.render();
  
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

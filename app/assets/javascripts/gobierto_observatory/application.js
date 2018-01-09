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

  // Process unemployment age data and pass it to both charts
  getUnemplAgeData.getData(function() {
    // Needs the data to set the same y scale
    var vis_unemplSex = new VisUnemploymentSex('#unemployment_sex', window.populateData.municipalityId, window.unemplAgeData);
    vis_unemplSex.render();

    var vis_unempl = new VisUnemploymentAge('#unemployment_age', window.populateData.municipalityId, window.unemplAgeData);
    vis_unempl.render();
  });

  var vis_agedb = new VisAgeDistribution('#age_distribution', window.populateData.municipalityId, window.populateData.year - 1);
  vis_agedb.render();

  var vis_unemplR = new VisUnemploymentRate('#unemployment_rate', window.populateData.municipalityId, window.populateData.ccaaId);
  vis_unemplR.render();

  var vis_rent = new VisRentDistribution('#rent_distribution', window.populateData.municipalityId, window.populateData.provinceId, window.populateData.year - 1);
  vis_rent.render();

  var popCard = new PopulationCard('.population_card', populateData.municipalityId);
  popCard.render();

  var births = new BirthRateCard('.births', populateData.municipalityId);
  births.render();

  var deaths = new DeathRateCard('.deaths', populateData.municipalityId);
  deaths.render();

  var activePopCard = new ActivePopulationCard('.active_pop', populateData.municipalityId);
  activePopCard.render();

  var hCard = new HousesCard('.houses', populateData.municipalityId);
  hCard.render();

  var cCard = new CarsCard('.cars', populateData.municipalityId);
  cCard.render();

  var ssCard = new ssMembersCard('.ss_members', populateData.municipalityId);
  ssCard.render();

  var fCard = new FreelancersCard('.freelancers', populateData.municipalityId);
  fCard.render();

  var cCard = new CompaniesCard('.companies', populateData.municipalityId);
  cCard.render();

  var contractsCard = new ContractsCard('.contracts_comparison', populateData.municipalityId);
  contractsCard.render();

  var unBySectorCard = new UnemplBySectorCard('.unemployed_sector', populateData.municipalityId);
  unBySectorCard.render();

  var contrSectorCard = new ContractsBySectorCard('.contracts_sector', populateData.municipalityId);
  contrSectorCard.render();

  var incomeOverviewCard = new IncomeOverviewCard('.income_overview', populateData.municipalityId);
  incomeOverviewCard.render();

  var incomeCard = new IncomeCard('.income', populateData.municipalityId);
  incomeCard.render();

  var invByInhab  = new InvestmentByInhabitantCard('.investment_by_inhabitant', populateData.municipalityId);
  invByInhab.render();

  var debtPerInhab = new DebtByInhabitantCard('.debt_by_inhabitant', populateData.municipalityId);
  debtPerInhab.render();

  var ibi =  new IbiCard('.ibi', populateData.municipalityId)
  ibi.render();

  var budget =  new BudgetByInhabitantCard('.budget_by_inhabitant', populateData.municipalityId)
  budget.render();

  var constructionTax =  new ConstructionTaxCard('.construction_tax', populateData.municipalityId)
  constructionTax.render();

  var carsTax =  new CarsTaxCard('.cars_tax', populateData.municipalityId)
  carsTax.render();

  var economicTax =  new EconomicTaxCard('.economic_tax', populateData.municipalityId)
  economicTax.render();

  $(".sections-nav").stick_in_parent();

  // Smooth scrolling
  $('.sections-nav a[href*="#"]').on('click', function (e) {
    // prevent default action and bubbling
    e.preventDefault();
    e.stopPropagation();
    // set target to anchor's "href" attribute
    var target = $(this).attr('href');
    // scroll to each target
    $(target).velocity('scroll', {
      duration: 500,
      offset: 0,
      easing: 'ease-in-out'
    });
  });

  // Show dataset info on click
  $('.card_container .widget_headline > i.fa').click(function() {
    $(this).closest('.card_container').toggleClass('hover');
  });

  if(window.location.hash !== ""){
    selectSection();
  }
});

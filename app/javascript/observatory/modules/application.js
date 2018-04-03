import { GetUnemploymentAgeData } from './get_unemployment_age_data.js'
import { VisUnemploymentSex } from './vis_unemployment_sex.js'
import { VisUnemploymentAge } from './vis_unemployment_age.js'
import { VisUnemploymentRate } from './vis_unemployment_rate.js'
import { VisAgeDistribution } from './vis_age_distribution.js'
import { VisRentDistribution } from './vis_rent_distribution.js'
import { PopulationCard } from './population.js'
import { BirthRateCard } from './birth_rate.js'
import { DeathRateCard } from './death_rate.js'
import { ActivePopulationCard } from './active_population.js'
import { HousesCard } from './houses.js'
import { CarsCard } from './cars.js'
import { ssMembersCard } from './ss_members.js'
import { FreelancersCard } from './freelancers.js'
import { CompaniesCard } from './companies.js'
import { ContractsCard } from './contracts.js'
import { UnemplBySectorCard } from './unemployed_sector.js'
import { ContractsBySectorCard } from './contracts_sector.js'
import { IncomeOverviewCard } from './income_overview.js'
import { IncomeCard } from './income.js'
import { InvestmentByInhabitantCard } from './investment_by_inhabitant.js'
import { DebtByInhabitantCard } from './debt_by_inhabitant.js'
import { IbiCard } from './ibi.js'
import { ConstructionTaxCard } from './construction_tax.js'
import { CarsTaxCard } from './cars_tax.js'
import { EconomicTaxCard } from './economic_tax.js'

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

  var popCard = new PopulationCard('.population_card', window.populateData.municipalityId);
  popCard.render();

  var births = new BirthRateCard('.births', window.populateData.municipalityId);
  births.render();

  var deaths = new DeathRateCard('.deaths', window.populateData.municipalityId);
  deaths.render();

  var activePopCard = new ActivePopulationCard('.active_pop', window.populateData.municipalityId);
  activePopCard.render();

  var hCard = new HousesCard('.houses', window.populateData.municipalityId);
  hCard.render();

  var cCard = new CarsCard('.cars', window.populateData.municipalityId);
  cCard.render();

  var ssCard = new ssMembersCard('.ss_members', window.populateData.municipalityId);
  ssCard.render();

  var fCard = new FreelancersCard('.freelancers', window.populateData.municipalityId);
  fCard.render();

  var cmCard = new CompaniesCard('.companies', window.populateData.municipalityId);
  cmCard.render();

  var contractsCard = new ContractsCard('.contracts_comparison', window.populateData.municipalityId);
  contractsCard.render();

  var unBySectorCard = new UnemplBySectorCard('.unemployed_sector', window.populateData.municipalityId);
  unBySectorCard.render();

  var contrSectorCard = new ContractsBySectorCard('.contracts_sector', window.populateData.municipalityId);
  contrSectorCard.render();

  var incomeOverviewCard = new IncomeOverviewCard('.income_overview', window.populateData.municipalityId);
  incomeOverviewCard.render();

  var incomeCard = new IncomeCard('.income', window.populateData.municipalityId);
  incomeCard.render();

  var invByInhab  = new InvestmentByInhabitantCard('.investment_by_inhabitant', window.populateData.municipalityId);
  invByInhab.render();

  var debtPerInhab = new DebtByInhabitantCard('.debt_by_inhabitant', window.populateData.municipalityId);
  debtPerInhab.render();

  var ibi =  new IbiCard('.ibi', window.populateData.municipalityId)
  ibi.render();

  var constructionTax =  new ConstructionTaxCard('.construction_tax', window.populateData.municipalityId)
  constructionTax.render();

  var carsTax =  new CarsTaxCard('.cars_tax', window.populateData.municipalityId)
  carsTax.render();

  var economicTax =  new EconomicTaxCard('.economic_tax', window.populateData.municipalityId)
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

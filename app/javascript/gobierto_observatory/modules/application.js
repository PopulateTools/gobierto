import {
  VisPopulationPyramid,
  VisRentDistribution,
  VisUnemploymentAge,
  VisUnemploymentRate,
  VisUnemploymentSex
} from "lib/visualizations";
import "sticky-kit/dist/sticky-kit.js";
import { ActivePopulationCard } from "./classes/active_population.js";
import { ContractsCard } from "./classes/contracts.js";
// TODO migrate
import { ContractsBySectorCard } from "./classes/contracts_sector.js";
import { DebtByInhabitantCard } from "./classes/debt_by_inhabitant.js";
import { FreelancersCard } from "./classes/freelancers.js";
import { BirthRateCard } from "./classes/birth_rate.js";
import { UnemplBySectorCard } from "./classes/unemployed_sector.js";
import { ssMembersCard } from "./classes/ss_members.js";
import { PopulationCard } from "./classes/population.js";
import { GetUnemploymentAgeData } from "./classes/get_unemployment_age_data.js";

import { BudgetByInhabitantCard } from "./classes/budget_by_inhabitant.js";
import { CarsCard } from "./classes/cars.js";
import { CarsTaxCard } from "./classes/cars_tax.js";
import { CompaniesCard } from "./classes/companies.js";
import { ConstructionTaxCard } from "./classes/construction_tax.js";
import { DeathRateCard } from "./classes/death_rate.js";
import { EconomicTaxCard } from "./classes/economic_tax.js";
import { HousesCard } from "./classes/houses.js";
import { IbiCard } from "./classes/ibi.js";
import { IncomeCard } from "./classes/income.js";
import { IncomeOverviewCard } from "./classes/income_overview.js";
import { InvestmentByInhabitantCard } from "./classes/investment_by_inhabitant.js";

function selectSection(html) {
  var $el = $("[data-breadcrumb-sub-item]");
  var $prev = $el.prev();
  if ($prev !== undefined && $prev[0] !== undefined) {
    if ($prev[0].tagName !== "SPAN") {
      $("<span>/</span>").insertBefore($el);
    }
  }

  if (html === undefined) {
    $(".sub_sections li a").each(function() {
      if (
        $(this)
          .attr("href")
          .indexOf(window.location.hash) !== -1
      )
        $el.html($(this).html());
    });
  } else {
    $el.html(html);
  }
}

$(document).on("turbolinks:click", function(event) {
  if (event.target.getAttribute("href").indexOf("#") !== -1) {
    event.preventDefault();
    selectSection($(event.target).html());
    return;
  }
});

var vis_population;

$(document).on("turbolinks:load", function() {
  // Skip all this execution if we are in the observatory map
  if ($("body.gobierto_observatory_observatory_demography_map").length) {
    return;
  }

  var getUnemplAgeData = new GetUnemploymentAgeData(
    window.populateData.municipalityId
  );

  /*Process unemployment age data and pass it to both charts*/
  getUnemplAgeData.getData(function() {
    // Needs the data to set the same y scale
    var vis_unemplSex = new VisUnemploymentSex(
      "#unemployment_sex",
      window.populateData.municipalityId,
      window.unemplAgeData
    );
    vis_unemplSex.render();

    var vis_unempl = new VisUnemploymentAge(
      "#unemployment_age",
      window.populateData.municipalityId,
      window.unemplAgeData
    );
    vis_unempl.render();
  });

 /* vis_population = new VisPopulationPyramid(
    "#population_pyramid",
    window.populateData.municipalityId,
    window.populateData.year
  );
  vis_population.render();

  //TODO
  var vis_unemplR = new VisUnemploymentRate(
    "#unemployment_rate",
    window.populateData.municipalityId,
    window.populateData.ccaaId
  );
  vis_unemplR.render();

  var vis_rent = new VisRentDistribution(
    "#rent_distribution",
    window.populateData.municipalityId,
    window.populateData.provinceId,
    window.populateData.year - 1
  );
  vis_rent.render();*/

  var popCard = new PopulationCard(
    ".population_card",
    window.populateData.municipalityId
  );
  popCard.render();

  var births = new BirthRateCard(".births", window.populateData.municipalityId);
  births.render();

  /*var deaths = new DeathRateCard(".deaths", window.populateData.municipalityId);
  deaths.render();*/

  var activePopCard = new ActivePopulationCard(
    ".active_pop",
    window.populateData.municipalityId
  );
  activePopCard.render();

  var hCard = new HousesCard(".houses", window.populateData.municipalityId);
  hCard.render();

  /*var cCard = new CarsCard(".cars", window.populateData.municipalityId);
  cCard.render();*/

  var ssCard = new ssMembersCard(
    ".ss_members",
    window.populateData.municipalityId
  );
  ssCard.render();

  var fCard = new FreelancersCard(
    ".freelancers",
    window.populateData.municipalityId
  );
  fCard.render();

  // var cmCard = new CompaniesCard(
  //   ".companies",
  //   window.populateData.municipalityId
  // );
  // cmCard.render();

  var contractsCard = new ContractsCard(
    ".contracts_comparison",
    window.populateData.municipalityId
  );
  contractsCard.render();

  // var unBySectorCard = new UnemplBySectorCard(
  //   ".unemployed_sector",
  //   window.populateData.municipalityId
  // );
  // unBySectorCard.render();

  // var contrSectorCard = new ContractsBySectorCard(
  //   ".contracts_sector",
  //   window.populateData.municipalityId
  // );
  // contrSectorCard.render();

  // var incomeOverviewCard = new IncomeOverviewCard(
  //   ".income_overview",
  //   window.populateData.municipalityId
  // );
  // incomeOverviewCard.render();

  // var incomeCard = new IncomeCard(
  //   ".income",
  //   window.populateData.municipalityId
  // );
  // incomeCard.render();

  // var invByInhab = new InvestmentByInhabitantCard(
  //   ".investment_by_inhabitant",
  //   window.populateData.municipalityId
  // );
  // invByInhab.render();

  var debtPerInhab = new DebtByInhabitantCard(
    ".debt_by_inhabitant",
    window.populateData.municipalityId
  );
  debtPerInhab.render();

  // var ibi = new IbiCard(".ibi", window.populateData.municipalityId);
  // ibi.render();

  // var budget = new BudgetByInhabitantCard(
  //   ".budget_by_inhabitant",
  //   window.populateData.municipalityId
  // );
  // budget.render();

  // var constructionTax = new ConstructionTaxCard(
  //   ".construction_tax",
  //   window.populateData.municipalityId
  // );
  // constructionTax.render();

  // var carsTax = new CarsTaxCard(
  //   ".cars_tax",
  //   window.populateData.municipalityId
  // );
  // carsTax.render();

  // var economicTax = new EconomicTaxCard(
  //   ".economic_tax",
  //   window.populateData.municipalityId
  // );
  // economicTax.render();

  $(".sections-nav").stick_in_parent();

  // Smooth scrolling
  $('.sections-nav a[href*="#"]').on("click", function(e) {
    // prevent default action and bubbling
    e.preventDefault();
    e.stopPropagation();
    // set target to anchor's "href" attribute
    var target = $(this).attr("href");
    // scroll to each target
    $(target).velocity("scroll", {
      duration: 500,
      offset: 0,
      easing: "ease-in-out"
    });
  });

  // Show dataset info on click
  $(".card_container .widget_headline > i.fas").click(function() {
    $(this)
      .closest(".card_container")
      .toggleClass("hover");
  });

  if (window.location.hash !== "") {
    selectSection();
  }

  $("#population_pyramid-filters button[data-toggle]").click(function() {
    let filter = $(this).data("toggle");
    let prev = $(this)
      .parent()
      .find(".active")
      .data("toggle");

    // Same filter as previous, do nothing
    if (filter === prev) return;

    $(this)
      .siblings()
      .removeClass("active");
    $(this).toggleClass("active");

    /*
     * filter values
     * 0 - municipality
     * 1 - province/autonomous-region
     * 2 - country
     */
    let elemId =
      filter === 0
        ? window.populateData.municipalityId
        : filter === 1
        ? window.populateData.ccaaId
        : null;

    // Update the urls
    vis_population.dataUrls = vis_population.getUrls(elemId, filter);
    // render again
    vis_population.render();
  });
});

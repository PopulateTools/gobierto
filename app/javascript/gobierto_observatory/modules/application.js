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
import { ContractsBySectorCard } from "./classes/contracts_sector.js";
import { DebtByInhabitantCard } from "./classes/debt_by_inhabitant.js";
import { FreelancersCard } from "./classes/freelancers.js";
import { BirthRateCard } from "./classes/birth_rate.js";
import { UnemplBySectorCard } from "./classes/unemployed_sector.js";
import { ssMembersCard } from "./classes/ss_members.js";
import { PopulationCard } from "./classes/population.js";
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
import { getProvinceIds } from "./helpers.js";

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

  const cityId = window.populateData.municipalityId;

  vis_population = new VisPopulationPyramid(
    "#population_pyramid",
    cityId,
    0
  )
  vis_population.render();

  new VisUnemploymentRate(
    "#unemployment_rate",
    cityId,
    getProvinceIds(cityId)
  ).render();

  new VisUnemploymentSex("#unemployment_sex", cityId).render();

  new VisUnemploymentAge("#unemployment_age", cityId).render();

  new VisRentDistribution("#rent_distribution", cityId).render();

  new PopulationCard(".population_card", cityId).render();

  new BirthRateCard(".births", cityId).render();

  new DeathRateCard(".deaths", cityId).render();

  new ActivePopulationCard(".active_pop", cityId).render();

  new HousesCard(".houses", cityId).render();

  new CarsCard(".cars", cityId).render();

  new ssMembersCard(".ss_members", cityId).render();

  new FreelancersCard(".freelancers", cityId).render();

  new CompaniesCard(".companies", cityId).render();

  new ContractsCard(".contracts_comparison", cityId).render();

  new UnemplBySectorCard(".unemployed_sector", cityId).render();

  new ContractsBySectorCard(".contracts_sector", cityId).render();

  new IncomeOverviewCard(".income_overview", cityId).render();

  new IncomeCard(".income", cityId).render();

  new InvestmentByInhabitantCard(".investment_by_inhabitant", cityId).render();

  new DebtByInhabitantCard(".debt_by_inhabitant", cityId).render();

  new IbiCard(".ibi", cityId).render();

  new BudgetByInhabitantCard(".budget_by_inhabitant", cityId).render();

  new ConstructionTaxCard(".construction_tax", cityId).render();

  new CarsTaxCard(".cars_tax", cityId).render();

  new EconomicTaxCard(".economic_tax", cityId).render();

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

  // NOTE: this should be included in the pyramid visualization code (plus the HTML)
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

    // Update the urls
    vis_population.dataUrls = vis_population.getUrls(window.populateData.municipalityId, filter);
    // render again
    vis_population.render();
  });
});

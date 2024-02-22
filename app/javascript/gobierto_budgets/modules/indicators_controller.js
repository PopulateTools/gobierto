import { GrossSavingCard } from './classes/gross_saving.js'
import { NetSavingCard } from './classes/net_saving.js'
import { TaxAutonomyCard } from './classes/tax_autonomy.js'
import { SelfFinancingCapacityCard } from './classes/self_financing_capacity.js'
import { FinancialChargeCard } from './classes/financial_charge.js'
import { LiabilityCostCard } from './classes/liability_cost.js'
import { InvestmentFinancingCard } from './classes/investment_financing.js'
import { GrossSavingsRateCard } from './classes/gross_savings_rate.js'
import { NetSavingsRateCard } from './classes/net_savings_rate.js'
import { PerCapitaInvestmentCard } from './classes/per_capita_investment.js'
import { DebtLevelCard } from './classes/debt_level.js'
import { PerCapitaTaxBurdenCard } from './classes/per_capita_tax_burden.js'
import { FinancialRiskCard } from './classes/financial_risk.js'
import { ExpenditureRigidityCard } from './classes/expenditure_rigidity.js'

window.GobiertoBudgets.IndicatorsController = (function() {

  function IndicatorsController() {}

  IndicatorsController.prototype.index = function(){
    _runIndicatorsApplication();
  };

  function _runIndicatorsApplication() {
    const cityId = window.populateData.municipalityId
    const currentYear = window.populateDataYear.currentYear

    new GrossSavingCard('.gross_saving_card', cityId, currentYear).render();

    new NetSavingCard('.net_saving_card', cityId, currentYear).render();

    new TaxAutonomyCard('.tax_autonomy_card', cityId, currentYear).render();

    new SelfFinancingCapacityCard('.self_financing_capacity_card', cityId, currentYear).render();

    new FinancialChargeCard('.financial_charge_card', cityId, currentYear).render();

    new LiabilityCostCard('.liability_cost_card', cityId, currentYear).render();

    new InvestmentFinancingCard('.investment_financing_card', cityId, currentYear).render();

    new GrossSavingsRateCard('.gross_savings_rate_card', cityId, currentYear).render();

    new NetSavingsRateCard('.net_savings_rate_card', cityId, currentYear).render();

    new PerCapitaInvestmentCard('.per_capita_investment_card', cityId, currentYear).render();

    new DebtLevelCard('.debt_level_card', cityId, currentYear).render();

    new PerCapitaTaxBurdenCard('.per_capita_tax_burden_card', cityId, currentYear).render();

    new FinancialRiskCard('.financial_risk_card', cityId, currentYear).render();

    new ExpenditureRigidityCard('.expenditure_rigidity_card', cityId, currentYear).render();
  }

  return IndicatorsController;
})();

window.GobiertoBudgets.indicators_controller = new GobiertoBudgets.IndicatorsController;

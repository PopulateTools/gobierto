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
    var grossSavingCard = new GrossSavingCard('.gross_saving_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    grossSavingCard.render();

    var netSavingCard = new NetSavingCard('.net_saving_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    netSavingCard.render();

    var taxAutonomyCard = new TaxAutonomyCard('.tax_autonomy_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    taxAutonomyCard.render();

    var selfFinancingCapacityCard = new SelfFinancingCapacityCard('.self_financing_capacity_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    selfFinancingCapacityCard.render();

    var financialChargeCard = new FinancialChargeCard('.financial_charge_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    financialChargeCard.render();

    var liabilityCostCard = new LiabilityCostCard('.liability_cost_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    liabilityCostCard.render();

    var investmentFinancingCard = new InvestmentFinancingCard('.investment_financing_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    investmentFinancingCard.render();

    var grossSavingsRateCard = new GrossSavingsRateCard('.gross_savings_rate_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    grossSavingsRateCard.render();

    var netSavingsRateCard = new NetSavingsRateCard('.net_savings_rate_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    netSavingsRateCard.render();

    var perCapitaInvestmentCard = new PerCapitaInvestmentCard('.per_capita_investment_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    perCapitaInvestmentCard.render();

    var debtLevelCard = new DebtLevelCard('.debt_level_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    debtLevelCard.render();

    var perCapitaTaxBurdenCard = new PerCapitaTaxBurdenCard('.per_capita_tax_burden_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    perCapitaTaxBurdenCard.render();

    var financialRiskCard = new FinancialRiskCard('.financial_risk_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    financialRiskCard.render();

    var expenditureRigidityCard = new ExpenditureRigidityCard('.expenditure_rigidity_card', window.populateData.municipalityId, window.populateDataYear.currentYear);
    expenditureRigidityCard.render();
  }

  return IndicatorsController;
})();

window.GobiertoBudgets.indicators_controller = new GobiertoBudgets.IndicatorsController;

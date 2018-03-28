this.GobiertoBudgets.IndicatorsController = (function() {

  function IndicatorsController() {}

  IndicatorsController.prototype.index = function(options){
    _runIndicatorsApplication();
  };

  function _runIndicatorsApplication() {
    $(document).on('turbolinks:load', function() {
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
    });
  }

  return IndicatorsController;
})();

this.GobiertoBudgets.indicators_controller = new GobiertoBudgets.IndicatorsController;

this.GobiertoBudgets.BudgetsController = (function() {
  function BudgetsController() {}

  BudgetsController.prototype.guide = function(incomeUrl, expenseUrl){
    console.log('in the guide');
    _loadTotalIncomeWidget(incomeUrl);
    _loadExpensePerInhabitantWidget(expenseUrl);
  };

  function _loadTotalIncomeWidget(url){
    $('[data-income]').html('');
  }

  function _loadExpensePerInhabitantWidget(url){
    $('[data-expense]').html('');
  }

  return BudgetsController;
})();

this.GobiertoBudgets.budgets_controller = new GobiertoBudgets.BudgetsController;

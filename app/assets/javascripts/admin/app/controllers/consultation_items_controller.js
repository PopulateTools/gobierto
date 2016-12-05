this.App.ConsultationItemsController = (function() {
  function ConsultationItemsController() {}

  function _handleBudgetLineChange() {
    var budgetLineSelectHandler = "#consultation_item_budget_line_id";
    var budgetLineAmountHandler = "#consultation_item_budget_line_amount";
    var consultationItemTitleHandler = "#consultation_item_title";

    $(budgetLineSelectHandler).on("change", function() {
      $(budgetLineAmountHandler).val($(this).find(":selected").data("amount"));
      $(consultationItemTitleHandler).val($(this).find(":selected").text());
    });
  }

  ConsultationItemsController.prototype.edit = function() {
    _handleBudgetLineChange();
  };

  return ConsultationItemsController;
})();

this.App.consultation_items_controller = new App.ConsultationItemsController;

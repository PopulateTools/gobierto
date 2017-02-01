this.GobiertoAdmin.ConsultationItemsController = (function() {
  function ConsultationItemsController() {}

  ConsultationItemsController.prototype.edit = function() {
    _handleBudgetLineAutocomplete();
  };

  ConsultationItemsController.prototype.index = function() {
    _handleSortableList();
  };

  function _handleBudgetLineAutocomplete() {
    var budgetLineAutocompleteHandler = "#consultation_item_budget_line_name";
    var budgetLineIdHandler = "#consultation_item_budget_line_id";
    var consultationItemTitleHandler = "#consultation_item_title";
    var budgetLineAmountHandler = "#consultation_item_budget_line_amount";

    var autocompleteOptions = {
      source: $(budgetLineAutocompleteHandler).data("source"),
      select: function(event, ui) {
        $(budgetLineIdHandler).val(ui.item.id);
        $(consultationItemTitleHandler).val(ui.item.name);
        $(budgetLineAmountHandler).val(ui.item.amount);
      }
    };

    $.ui.autocomplete(autocompleteOptions, $(budgetLineAutocompleteHandler));
  }

  function _handleSortableList() {
    var wrapper = "ul[data-behavior=sortable]";
    var positions = [];

    sortable(wrapper);

    $(wrapper).on("sortupdate", function(e) {
      _refreshPositions(wrapper);
      _requestUpdate(wrapper, _buildPositions(wrapper));
    });
  }

  function _refreshPositions(wrapper) {
    $(wrapper).find("li").each(function(index) {
      $(this).attr("data-pos", index + 1);
    });
  };

  function _buildPositions(wrapper) {
    var positions = [];

    $(wrapper).find("li").each(function(index) {
      positions.push({
        id: $(this).data("id"),
        position: index + 1
      });
    });

    return positions;
  };

  function _requestUpdate(wrapper, positions) {
    $.ajax({
      url: $(wrapper).data("sortable-target"),
      method: "POST",
      data: { positions: positions }
    });
  };

  return ConsultationItemsController;
})();

this.GobiertoAdmin.consultation_items_controller = new GobiertoAdmin.ConsultationItemsController;

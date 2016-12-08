this.GobiertoAdmin.ConsultationItemsController = (function() {
  function ConsultationItemsController() {}

  ConsultationItemsController.prototype.edit = function() {
    _handleBudgetLineChange();
  };

  ConsultationItemsController.prototype.index = function() {
    _handleSortableList();
  };

  function _handleBudgetLineChange() {
    var budgetLineSelectHandler = "#consultation_item_budget_line_id";
    var budgetLineAmountHandler = "#consultation_item_budget_line_amount";
    var consultationItemTitleHandler = "#consultation_item_title";

    $(budgetLineSelectHandler).on("change", function() {
      $(budgetLineAmountHandler).val($(this).find(":selected").data("amount"));
      $(consultationItemTitleHandler).val($(this).find(":selected").data("name"));
    });
  }

  function _handleSortableList() {
    var wrapper = "ul[data-behavior=sortable]"
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

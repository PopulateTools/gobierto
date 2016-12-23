this.GobiertoBudgetConsultations.ConsultationResponsesController = (function() {
  function ConsultationResponsesController() {}

  ConsultationResponsesController.prototype.new = function(locale) {
    handleNavigation();
    handleBudgetCalculation(locale);
  };

  function handleNavigation() {
    var navigationWrapper = ".continue";
    var consultationStageWrapper = ".consultation_stage";

    $(consultationStageWrapper + ":first").addClass("active");

    $(navigationWrapper).on("click", "[data-navigation=next]", function(e) {
      e.preventDefault();
      _navigateNextStage();
    });
  }

  function handleBudgetCalculation(locale) {
    var consultationStageWrapper = ".consultation_stage";
    var responseOptionWrapper = ".response-option input[type=radio]";
    var budgetLineWrapper = "[data-budget-line-amount]";
    var currentBudgetWrapper = "[data-current-budget-amount]";
    var currentBudgetAmount = parseFloat($(currentBudgetWrapper).data("current-budget-amount"));

    _updateCurrentBudgetAmount(currentBudgetAmount, locale);

    $(responseOptionWrapper).on("click", function() {
      currentBudgetAmount = 0.0;

      $(consultationStageWrapper).each(function(_, consultationStage) {
        var selectedOption = $(consultationStage).find(responseOptionWrapper + ":checked");
        var budgetLineAmount = parseFloat($(consultationStage).find(budgetLineWrapper).data("budget-line-amount"));

        currentBudgetAmount += _calculateBudgetAmount(selectedOption.data("label"), budgetLineAmount);
      });

      _updateCurrentBudgetAmount(currentBudgetAmount, locale);
    });
  }

  function _navigateNextStage() {
    var consultationStageWrapper = ".consultation_stage";
    var currentStage = $(consultationStageWrapper + ".active:first");
    var nextStage = currentStage.next(consultationStageWrapper);

    currentStage.removeClass("active");
    nextStage.addClass("active");
  }

  function _calculateBudgetAmount(operation, amount) {
    switch(operation) {
      case "keep":
        return amount; // Keep amount
        break;
      case "increase":
        return amount * 1.1; // Increase amount by 10.0%
        break;
      case "reduce":
        return amount * 0.9; // Reduce amount by 10.0%
        break;
    }
  }

  function _updateCurrentBudgetAmount(amount, locale) {
    var budgetWrapper = "[data-budget-amount]";
    var budgetAmount = parseFloat($(budgetWrapper).data("budget-amount"));
    var currentBudgetWrapper = "[data-current-budget-amount]";

    $(currentBudgetWrapper).data("budget-line-amount", amount);
    $(currentBudgetWrapper).find(".qty").html(_formatAmount(amount, locale));

    if (amount > budgetAmount) {
      _setCurrentBudgetWarning();
    } else {
      _unsetCurrentBudgetWarning();
    }
  }

  function _formatAmount(amount, locale) {
    var amountFormat = amount >= 1e6 ? "0,0.0 a $" : "0,0.00 $";
    var limitedAmountPrecision = parseFloat(Number(amount).toPrecision(3));

    numeral.locale(locale);

    return numeral(limitedAmountPrecision).format(amountFormat);
  }

  function _setCurrentBudgetWarning() {
    if ($(".debt_marker.debt_warning").length) {
      return true;
    }

    $(".debt_marker").addClass("debt_warning");
    $(".debt_marker .qty")
      .velocity({backgroundColor: "#AC3E3E"})
      .velocity("callout.flash");
    $(".warning_text").velocity("transition.slideDownBigIn");
  }

  function _unsetCurrentBudgetWarning() {
    if (!$(".debt_marker.debt_warning").length) {
      return true;
    }

    $(".debt_marker").removeClass("debt_warning");
    $(".debt_marker .qty").velocity({backgroundColor: "#F0F0F0"});
    $(".warning_text").velocity("transition.slideUpBigOut");
  }

  return ConsultationResponsesController;
})();

this.GobiertoBudgetConsultations.consultation_responses_controller = new GobiertoBudgetConsultations.ConsultationResponsesController;

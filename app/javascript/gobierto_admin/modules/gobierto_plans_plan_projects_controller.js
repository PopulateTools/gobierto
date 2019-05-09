window.GobiertoAdmin.GobiertoPlansPlanProjectsController = (function() {
  function GobiertoPlansPlanProjectsController() {}

  GobiertoPlansPlanProjectsController.prototype.form = function(opts) {
    _handleSubmitChangeBehaviors();
  };

  function _handleSubmitChangeBehaviors() {
    $(document).on("change", "select[data-behavior]", function(e) {
      if ($(this).data("behavior") === "submit_change") {
        $("form#edit_projects_filter").submit();
      }
    });

    $(document).on("datepicker-change", "input[data-behavior]", function(e) {
      if ($(this).data("behavior") === "submit_change") {
        if ($(this).data("datepicker").selectedDates.length < 2) return

        $("form#edit_projects_filter").submit();
      }
    })
  }

  return GobiertoPlansPlanProjectsController;
})();

window.GobiertoAdmin.gobierto_plans_plan_projects_controller = new GobiertoAdmin.GobiertoPlansPlanProjectsController;

window.GobiertoAdmin.GobiertoPlansPlanProjectsController = (function() {
  function GobiertoPlansPlanProjectsController() {}

  GobiertoPlansPlanProjectsController.prototype.index = function(opts) {
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

  function _handleCategoriesSelectBehaviors() {
    $("select#project_category_id").select2()

    // This should be controlled via css
    $(".select2-container").css("padding-top", "22px");
  }

  GobiertoPlansPlanProjectsController.prototype.form = function(opts) {
    $(".js-admin-widget-save label").click(function(e) {
      var styleClass = $(e.target).attr("data-status-style")
      let $dropdownToggle = $(e.target).closest(".js-admin-widget-save").find("span.i_p_status")

      $dropdownToggle.removeClass()
      $dropdownToggle.addClass(`i_p_status ${styleClass}`)

      var newStateText = e.target.textContent.trim();
      $(".g_popup_context .i_p_status a").text(newStateText);
    })
    _handleCategoriesSelectBehaviors()
  };

  return GobiertoPlansPlanProjectsController;
})();

window.GobiertoAdmin.gobierto_plans_plan_projects_controller = new GobiertoAdmin.GobiertoPlansPlanProjectsController;

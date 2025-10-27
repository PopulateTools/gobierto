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

  function _handleMinorChangeCheckbox() {
    var minorChangeCheckbox = document.querySelector('.js-minor-change-checkbox');
    var saveButton = document.querySelector('.js-save-button');

    if (minorChangeCheckbox && saveButton) {
      // Store the original data-confirm value
      var originalConfirmData = saveButton.dataset.confirm;

      minorChangeCheckbox.addEventListener('change', function() {
        if (this.checked) {
          // Remove data-confirm when minor_change is checked
          if (saveButton.dataset.confirm) {
            delete saveButton.dataset.confirm;
          }
        } else {
          // Restore data-confirm when minor_change is unchecked
          if (originalConfirmData) {
            saveButton.dataset.confirm = originalConfirmData;
          }
        }
      });

      // Initialize on page load in case checkbox is already checked
      if (minorChangeCheckbox.checked && saveButton.dataset.confirm) {
        delete saveButton.dataset.confirm;
      }
    }
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
    _handleMinorChangeCheckbox()
  };

  return GobiertoPlansPlanProjectsController;
})();

window.GobiertoAdmin.gobierto_plans_plan_projects_controller = new GobiertoAdmin.GobiertoPlansPlanProjectsController;

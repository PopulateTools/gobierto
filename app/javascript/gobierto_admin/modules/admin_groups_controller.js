window.GobiertoAdmin.AdminGroupsController = (function() {

    function AdminGroupsController() {}

    AdminGroupsController.prototype.form = function() {
      _addToggleModulesBehaviors();
      _addToggleActionsBehaviors();
      _addToggleAllPeopleBehaviors();
      _addTogglePersonBehaviors();
    };


    function _addToggleModulesBehaviors() {
      $("[data-behavior='toggle-module']").click(function() {
        let $modules_actions_block = $(`#modules_actions_${this.value}`);
        let $subresources_block = $(`#subresources_${this.value}`);
        if (this.checked) {
          $modules_actions_block.find("[data-class='modules_action'] input[type='checkbox']").prop('disabled', false);
          $modules_actions_block.show('slow');
          $modules_actions_block.prop("disabled", false);
          if ($modules_actions_block.find("[data-class='modules_action'] input[type='checkbox']:checked").length == 0) {
            // For Gobierto Plans, use 'manage_plans' instead of deprecated 'manage'
            let defaultAction = this.value === 'GobiertoPlans' ? 'manage_plans' : 'manage';
            $modules_actions_block.find(`[data-class='modules_action'] input[type='checkbox'][value='${defaultAction}']`).prop('checked', true);
          }
          $subresources_block.show('slow');
        } else {
          $modules_actions_block.hide('slow');
          $modules_actions_block.prop("disabled", true);
          $modules_actions_block.find("[data-class='modules_action'] input[type='checkbox']").prop('disabled', true);
          $subresources_block.hide('slow');
        }
      });
    }

    function _addToggleActionsBehaviors() {
      $("[data-behavior='toggle-action']").click(function() {
        if (!this.checked) {
          let module_name = this.parentElement.getAttribute("data-module")
          let $modules_actions_block = $(`#modules_actions_${this.parentElement.getAttribute("data-module")}`);
          if ($modules_actions_block.find("[data-class='modules_action'] input[type='checkbox']:checked").length == 0) {
            $(`input[type='checkbox'][data-behavior='toggle-module'][value='${module_name}']`).trigger("click");
          }
        }
      });
    }

    function _addToggleAllPeopleBehaviors() {
      $('#admin_group_all_people').click(function() {
        if (this.checked) {
          $("[data-class='site_person'] input[type='checkbox']").prop('checked', false);
        }
      });
    }

    function _addTogglePersonBehaviors() {
      $("[data-class='site_person'] input[type='checkbox']").click(function() {
        if (this.checked) {
          $('#admin_group_all_people').prop('checked', false);
        }
      });
    }

    return AdminGroupsController;
  })();

  window.GobiertoAdmin.admin_groups_controller = new GobiertoAdmin.AdminGroupsController;

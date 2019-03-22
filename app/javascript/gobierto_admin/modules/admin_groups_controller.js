window.GobiertoAdmin.AdminGroupsController = (function() {

    function AdminGroupsController() {}

    AdminGroupsController.prototype.form = function() {
      _addToggleGobiertoPeopleBehaviors();
      _addToggleAllPeopleBehaviors();
      _addTogglePersonBehaviors();
    };


    function _addToggleGobiertoPeopleBehaviors() {
      var $checkbox = $("[data-behavior='toggle-module-GobiertoPeople']");
      $checkbox.click(function() {
        if (this.checked) {
          $('#people_permissions').show('slow');
        } else {
          $('#people_permissions').hide('slow');
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

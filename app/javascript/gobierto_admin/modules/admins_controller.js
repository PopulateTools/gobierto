window.GobiertoAdmin.AdminsController = (function() {

    function AdminsController() {}

    AdminsController.prototype.form = function() {
      _addChangeAuthorizationLevelBehaviors();
    };

    function _addChangeAuthorizationLevelBehaviors() {
      var $regular  = $("[data-behavior='authorization-level-regular']");
      var $manager  = $("[data-behavior='authorization-level-manager']");
      var $disabled = $("[data-behavior='authorization-level-disabled']");

      $regular.click(function() {
        $('#sites_permissions').show('fast');
      });

      $manager.click(function() {
        $('#sites_permissions').hide('fast');
      });

      $disabled.click(function() {
        $('#sites_permissions').hide('fast');
      });
    }

    return AdminsController;
  })();

  window.GobiertoAdmin.admins_controller = new GobiertoAdmin.AdminsController;

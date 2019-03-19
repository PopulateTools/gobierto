window.GobiertoAdmin.AdminsController = (function() {

    function AdminsController() {}

    AdminsController.prototype.form = function() {
      _addToggleSiteBehaviors();
      _addChangeAuthorizationLevelBehaviors();
    };

    function _addToggleSiteBehaviors() {
      var $siteCheckboxes = $("[data-behavior='toggle_site']");

      $siteCheckboxes.click(function() {
        var siteId = $(this).attr('data-site-id');
        var $siteAdminGroups = $("[data-class='site_admin_group'][data-site-id='" + siteId + "']");

        if (this.checked) {
          $siteAdminGroups.show('slow');
        } else {
          $siteAdminGroups.hide('slow');

          var siteCheckboxes = $("[data-behavior='toggle_site']");
          var sitePermissions = $.map(siteCheckboxes, function (val) {
            if (val.checked) {
              return val.checked;
            }
          });
        }
      });
    }

    function _addChangeAuthorizationLevelBehaviors() {
      var $regular  = $("[data-behavior='authorization-level-regular']");
      var $manager  = $("[data-behavior='authorization-level-manager']");
      var $disabled = $("[data-behavior='authorization-level-disabled']");

      $regular.click(function() {
        $('#sites_permissions').show('fast');
        $('#admin_groups').show('fast');
      });

      $manager.click(function() {
        $('#sites_permissions').hide('fast');
        $('#admin_groups').hide('fast');
      });

      $disabled.click(function() {
        $('#sites_permissions').hide('fast');
        $('#admin_groups').hide('fast');
      });
    }

    return AdminsController;
  })();

  window.GobiertoAdmin.admins_controller = new GobiertoAdmin.AdminsController;

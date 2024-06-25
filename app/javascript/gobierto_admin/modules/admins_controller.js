window.GobiertoAdmin.AdminsController = (function() {

    function AdminsController() {}

    AdminsController.prototype.form = function() {
      _addToggleSiteBehaviors();
      _addChangeAuthorizationLevelBehaviors();
    };

    AdminsController.prototype.show = function() {
      _addCopyBehaviors()
    }

    function _addToggleSiteBehaviors() {
      var $siteCheckboxes = $("[data-behavior='toggle_site']");

      $siteCheckboxes.click(function() {
        var siteId = $(this).attr('data-site-id');
        var $siteAdminGroups = $("[data-class='site_admin_group'][data-site-id='" + siteId + "']");
        var $adminGroups = $("[data-class='site_admin_group']");

        if (this.checked) {
          if ($siteAdminGroups.length > 0) { $('#admin_groups').show('slow'); }

          $siteAdminGroups.show('slow');
        } else {
          $siteAdminGroups.hide('slow');

          if ($siteAdminGroups.length == $adminGroups.length) { $('#admin_groups').hide('slow'); }
        }
      });
    }

    function _addChangeAuthorizationLevelBehaviors() {
      var $regular = $("[data-behavior='authorization-level-regular']");
      var $manager = $("[data-behavior='authorization-level-manager']");
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

    function _addCopyBehaviors() {
      $("[data-behavior='copy']").click(function() {
          var textArea = document.createElement("textarea");
          textArea.value = this.parentNode.children[1].innerText
          document.body.appendChild(textArea);
          textArea.select();
          document.execCommand("copy");
          document.body.removeChild(textArea);
          $(this.parentElement).find("span").removeClass("hidden")
      })
    }

    return AdminsController;
  })();

  window.GobiertoAdmin.admins_controller = new GobiertoAdmin.AdminsController;

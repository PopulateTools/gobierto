this.GobiertoAdmin.AdminsController = (function() {
  
    function AdminsController() {}
  
    AdminsController.prototype.form = function() {
      _addToggleSiteBehaviors();
      _addChangeAuthorizationLevelBehaviors();
      _addToggleGobiertoPeopleBehaviors();
      _addToggleAllPeopleBehaviors();
      _addTogglePersonBehaviors();
    };

    function _addToggleSiteBehaviors() {
      var $siteCheckboxes = $("[data-behavior='toggle_site']");

      $siteCheckboxes.click(function() {
        var siteId = $(this).attr('data-site-id');
        console.log('Clicked on site '+ siteId);
        var $sitePeople = $("[data-class='site_person'][data-site-id='" + siteId + "']");

        if (this.checked) {
          $sitePeople.show('slow');
        } else {
          $sitePeople.hide('slow');
        }
      });
    };

    function _addChangeAuthorizationLevelBehaviors() {
      var $regular  = $("[data-behavior='authorization-level-regular']");
      var $manager  = $("[data-behavior='authorization-level-manager']");
      var $disabled = $("[data-behavior='authorization-level-disabled']");

      $regular.click(function() {
        $('#sites_permissions').show('fast', function() {
          $('#modules_permissions').show('fast');
        });
      });

      $manager.click(function() {
        $('#modules_permissions').hide('fast', function() {
          $('#sites_permissions').show('fast');
        });
      });

      $disabled.click(function() {
        $('#modules_permissions').hide('fast', function() {
          $('#sites_permissions').hide('fast');
        });
      });
    }
  
    function _addToggleGobiertoPeopleBehaviors() {
      var $checkbox = $("[data-behavior='toggle-module-GobiertoPeople']");
      $checkbox.click(function() {
        if (this.checked) {
          $('#people_permissions').show('slow');
        } else {
          $('#people_permissions').hide('slow');
        }
      });
    };

    function _addToggleAllPeopleBehaviors() {
      $('#permission_all_people').click(function() {
        if (this.checked) {
          $("[data-class='site_person'] input[type='checkbox']").prop('checked', false);
        }
      });
    };

    function _addTogglePersonBehaviors() {
      $("[data-class='site_person'] input[type='checkbox']").click(function() {
        if (this.checked) {
          $('#permission_all_people').prop('checked', false);
        }
      });
    };

    return AdminsController;
  })();
  
  this.GobiertoAdmin.admins_controller = new GobiertoAdmin.AdminsController;
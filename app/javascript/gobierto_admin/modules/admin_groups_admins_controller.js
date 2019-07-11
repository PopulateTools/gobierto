window.GobiertoAdmin.AdminGroupsAdminsController = (function() {

  function AdminGroupsAdminsController() {}

  AdminGroupsAdminsController.prototype.index = function() {
    _handleSelectBehaviors();
  };

  function _handleSelectBehaviors() {
    $("[data-behavior=select2]").select2()
  }

  return AdminGroupsAdminsController;
})();

window.GobiertoAdmin.admin_groups_admins_controller = new GobiertoAdmin.AdminGroupsAdminsController;

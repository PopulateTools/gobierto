window.GobiertoAdmin.AdminGroupsAdminsController = (function() {

  function AdminGroupsAdminsController() {}

  AdminGroupsAdminsController.prototype.index = function() {
    _handleSelectBehaviors();
  };

  function _handleSelectBehaviors() {
    $("[data-behavior=select2]")
      .select2()
      .on("select2:select", ({ params }) => {
        // this callback only applies to list_modal.html.erb
        const { element } = params?.data
        if (element) {
          const { dataset, value } = element
          const btn = document.getElementById("add-current-dashboard-btn")
          if (btn) {
            const url = new URL(btn.href)
            url.searchParams.set("id", value)
            url.searchParams.set("preview_path", dataset?.previewPath)

            btn.href = url
          }
        }
      })
  }

  return AdminGroupsAdminsController;
})();

window.GobiertoAdmin.admin_groups_admins_controller = new GobiertoAdmin.AdminGroupsAdminsController;

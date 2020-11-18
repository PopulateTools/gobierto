import "magnific-popup";
import { GobiertoEvents } from "lib/shared"

document.addEventListener("DOMContentLoaded", ({ type }) => {
  console.log(type);
})

$(document).on("turbolinks:load ajax:complete ajaxSuccess", function() {
  $(".open_remote_modal").magnificPopup({
    type: "ajax",
    removalDelay: 300,
    mainClass: "mfp-move-horizontal",
    callbacks: {
      ajaxContentAdded: function() {
        // This conditionals are always true ¬¬
        if (window.GobiertoAdmin && window.GobiertoAdmin.process_stages_controller) {
          window.GobiertoAdmin.process_stages_controller.form();
        }
        if (window.GobiertoAdmin && window.GobiertoAdmin.globalized_forms_component) {
          window.GobiertoAdmin.globalized_forms_component.handleGlobalizedForm();
        }
        if (window.GobiertoAdmin && window.GobiertoAdmin.gobierto_citizens_charters_editions_intervals_controller) {
          window.GobiertoAdmin.gobierto_citizens_charters_editions_intervals_controller.handleForm();
        }
        if (window.GobiertoAdmin && window.GobiertoAdmin.admin_groups_admins_controller) {
          window.GobiertoAdmin.admin_groups_admins_controller.index();
        }
        if (window.GobiertoAdmin && window.GobiertoAdmin.terms_controller) {
          window.GobiertoAdmin.terms_controller.form()
        }

        // autofocus on the first modal input field
        $(".modal .form_item input[type=text]:visible").first().focus()

        console.log('hola');

        const event = new Event(GobiertoEvents.CREATE_DASHBOARD_EVENT)
        document.dispatchEvent(event)
      }
    }
  });
});
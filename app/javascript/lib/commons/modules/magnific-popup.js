import { GOBIERTO_DASHBOARDS } from '../../../lib/events';
import 'magnific-popup';

function addMagnificPopups() {
  // flag storing whether the modal trigger is a dashboard initializer or not
  let isDashboardTrigger = false

  $(".open_remote_modal").magnificPopup({
    type: "ajax",
    removalDelay: 300,
    mainClass: "mfp-move-horizontal",
    // closeOnContentClick: !isDashboardTrigger,
    // closeOnBgClick: !isDashboardTrigger,
    callbacks: {
      change: function({ el }) {
        const { dataset } = el[0] || {} // 0 is a jQuery value, not array index

        // if the modal trigger (.open_remote_modal) contains data-dashboards-maker directive
        // then it activates the trigger. Once the DOM (the modal content) has been loaded, ajaxContentAdded will dispatch the event.
        // it must be done in this callback, due to next one does not provide access to "el" object
        isDashboardTrigger = (!!dataset?.dashboardsMaker)
      },
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

        if (isDashboardTrigger) {
          const event = new Event(GOBIERTO_DASHBOARDS.CREATE)
          document.dispatchEvent(event)
        }
    },
    }
  });
}

$(document).on("turbolinks:load ajax:complete ajaxSuccess", addMagnificPopups);

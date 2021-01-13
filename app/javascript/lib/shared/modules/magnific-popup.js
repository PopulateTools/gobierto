import "magnific-popup";
import { GOBIERTO_DASHBOARDS } from "lib/events"

function addMagnificPopups() {
  function ajaxContentAdded() {
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

    // launch modal only if the target has data-dashboards-maker directive
    // public properties: https://dimsemenov.com/plugins/magnific-popup/documentation.html#api
    const { dataset } = this.st.el[0] || {}
    // console.log($.magnificPopup.instance);
    if (dataset?.dashboardsMaker) {
      const event = new Event(GOBIERTO_DASHBOARDS.CREATE)
      document.dispatchEvent(event)
    }

    console.log('ajaxAdded');
  }

  $(".open_remote_modal").magnificPopup({
    type: "ajax",
    removalDelay: 300,
    mainClass: "mfp-move-horizontal",
    callbacks: {
      ajaxContentAdded,
      change: function({ el }) {
        console.log('Content changed', el[0]);

        const { dataset } = el[0] || {}
        if (dataset?.dashboardsMaker) {
          console.log('in');
          // TODO: hacer un flag para lanzarlo en el otro callback (DOM renderizado)
          setTimeout(() => {
            const event = new Event(GOBIERTO_DASHBOARDS.CREATE)
            document.dispatchEvent(event)
          }, 250);
        }
      },
    }
  });
}

$(document).on("turbolinks:load ajax:complete ajaxSuccess", addMagnificPopups);
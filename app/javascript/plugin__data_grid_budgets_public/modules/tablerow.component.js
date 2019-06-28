import Vue from "vue";

window.GobiertoPlans.TableRowController = (function() {
  function TableRowController() {}

  const PLUGINS = [];
  const template = `<div>{{ key }}</div>`;

  TableRowController.prototype.show = function() {
    document.addEventListener("gobierto-plans-mount-plugin", e => {
      handleComponent(e.detail);
    });
  };

  TableRowController.prototype.add = function(key, id) {
    PLUGINS.push({ key, id });
  };

  function handleComponent(params) {
    const { id } = PLUGINS.find(d => d.key === params.key) || {};

    if (id) {
      new Vue({
        el: `#${id}`,
        name: "gobierto-planification__plugin",
        template: template,
        data: {
          key: params.key
        },
        created() {
        }
      })
    }
  }

  return TableRowController;
})();

window.GobiertoPlans.tablerow_controller = new GobiertoPlans.TableRowController();

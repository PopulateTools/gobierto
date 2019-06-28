import Vue from "vue";

window.GobiertoPlans.TableRowController = (function() {
  function TableRowController() {}

  TableRowController.prototype.show = function() {
    document.addEventListener("gobierto-plans-mount-plugin", e => {
      handleComponent(e.detail);
    });
  };

  TableRowController.prototype.add = function(id) {
    console.log(id);
  };

  function handleComponent(params) {
    console.log(params);

    //     new Vue({
    //   el: `#${id}`,
    //   name: "gobierto-planification__plugin",
    //   template: `<div>HOLAPLUGIN</div>`,
    //   created() {
    //     console.log('hola created');

    //   }
    // })
  }

  return TableRowController;
})();

window.GobiertoPlans.tablerow_controller = new GobiertoPlans.TableRowController();

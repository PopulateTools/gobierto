import { rangeSlider } from "lib/globals";

window.GobiertoInvestments.InvestmentsController = (function() {
  class InvestmentsController {
    constructor() {}
    show() {
      const rangeSliders = document.querySelectorAll(".js-range-slider");

      rangeSliders.forEach(slider => {
        const { min = 0, max = 100, default: defaultRange = [0, 100] } = slider.dataset;

        const fn = (event, ui) => console.log(event, ui);

        rangeSlider({
          elem: slider,
          min: parseFloat(min),
          max: parseFloat(max),
          defaultRange: JSON.parse(defaultRange),
          rangeCallback: fn
        });
      });
    }
  }

  return InvestmentsController;
})();

window.GobiertoInvestments.investments_controller = new GobiertoInvestments.InvestmentsController();

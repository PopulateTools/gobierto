import { rangeSlider } from "lib/shared";
import Vue from "vue";
Vue.config.productionTip = false;

export class InvestmentsController {
  constructor() {
    this.inRangeClass = "in-range";

    // Initialize all possible rangeSliders
    const rangeSliders = document.querySelectorAll(".js-range-slider");
    rangeSliders.forEach(slider => this._setRangeSlider(slider));

    // Mount Vue application
    const entryPoint = document.getElementById("investments-app");
    if (entryPoint) {
      const Component = require(`../webapp/App.vue`).default;
      const Plugin = Vue.extend(Component);
      const instance = new Plugin({});

      instance.$mount(entryPoint);
    }
  }

  _setRangeSlider(slider) {
    const { min = 0, max = 1, default: defaultRange = [0, 100], rangeBarsSelector } = slider.dataset;

    const callback = (_, ui) => {
      const { values = [] } = ui;

      slider.selectedRange = values;

      if (slider.selector) {
        this._setRangeBar(slider);
      }
    };

    // Update values for THIS slider
    slider.min = parseFloat(min);
    slider.max = parseFloat(max);
    slider.selectedRange = JSON.parse(defaultRange);

    rangeSlider({
      elem: slider,
      min: slider.min,
      max: slider.max,
      defaultRange: slider.selectedRange,
      rangeCallback: callback
    });

    // Initialize range bars if present
    if (rangeBarsSelector) {
      slider.selector = document.querySelector(rangeBarsSelector);
      this._setRangeBar(slider);
    }
  }

  _setRangeBar(rangeBars) {
    const { min, max, selectedRange, selector } = rangeBars;
    const bars = selector.children;
    const step = (max - min) / bars.length;
    const [start, end] = selectedRange;

    for (let index = 0; index < bars.length; index++) {
      const bar = bars[index];

      start <= step * index + step + min && end >= step * index + min
        ? bar.classList.add(this.inRangeClass)
        : bar.classList.remove(this.inRangeClass);
    }
  }
}

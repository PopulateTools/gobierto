<template>
  <div>
    <div
      id="randomID"
      class="investments-home-aside--bars"
    >
      <div
        v-for="i in bars"
        :key="i"
        :style="{ height: `${100 * Math.random()}%`}"
      />
    </div>
    <div
      class="js-range-slider"
      data-min="50"
      data-max="500"
      data-default="[100, 200]"
      data-range-bars-selector="#randomID"
    />
  </div>
</template>

<script>
import { rangeSlider } from "lib/shared";

export default {
  name: "RangeBars",
  props: {
    bars: {
      type: Number,
      default: 6
    }
  },
  inRangeClass: "in-range",
  mounted() {
    const rangeSlider = this.$el.querySelector(".js-range-slider");
    this.setRangeSlider(rangeSlider);
  },
  methods: {
    setRangeSlider(slider) {
      const {
        min = 0,
        max = 1,
        default: defaultRange = [0, 100],
        rangeBarsSelector
      } = slider.dataset;

      const callback = (_, ui) => {
        const { values = [] } = ui;

        slider.selectedRange = values;
        this.setRangeBar(slider);
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
        slider.selector = this.$el.querySelector(rangeBarsSelector);
        this.setRangeBar(slider);
      }
    },
    setRangeBar(rangeBars) {
      const { min, max, selectedRange, selector } = rangeBars;
      const bars = selector.children;
      const step = (max - min) / bars.length;
      const [start, end] = selectedRange;

      for (let index = 0; index < bars.length; index++) {
        const bar = bars[index];

        start <= step * index + step + min && end >= step * index + min
          ? bar.classList.add(this.$options.inRangeClass)
          : bar.classList.remove(this.$options.inRangeClass);
      }
    }
  }
};
</script>
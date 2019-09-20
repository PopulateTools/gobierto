<template>
  <div>
    <div
      :id="`range-bars-${random}`"
      class="investments-home-aside--bars"
    >
      <div
        v-for="bar in rangeBars"
        :key="bar.id"
        :style="{ height: `${100 * (bar.count / total)}%`}"
      >
        <span>{{ rangeMin(bar.start) | money({ minimumFractionDigits: 0 }) }}</span>
        <span>{{ rangeMax(bar.end) | money({ minimumFractionDigits: 0 }) }}</span>
      </div>
    </div>
    <div
      :data-min="min"
      :data-max="max"
      :data-default="rangeDefault"
      :data-range-bars-selector="`#range-bars-${random}`"
      class="js-range-slider"
    />
    <div class="investments-home-aside--bars-values">
      <span>{{ selectedMin | money({ minimumFractionDigits: 0 }) }}</span>
      <span>{{ selectedMax | money({ minimumFractionDigits: 0 }) }}</span>
    </div>
  </div>
</template>

<script>
import { rangeSlider } from "lib/shared";
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "RangeBars",
  mixins: [CommonsMixin],
  props: {
    min: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 100
    },
    total: {
      type: Number,
      default: 1
    },
    rangeBars: {
      type: Array,
      default: () => []
    }
  },
  inRangeClass: "in-range",
  data() {
    return {
      defaultRange: [this.min, this.max],
      selectedMin: this.min,
      selectedMax: this.max,
      random: Math.random().toString(36).substring(7),
    }
  },
  computed: {
    rangeMin() {
      return value => Math.floor(parseFloat(value))
    },
    rangeMax() {
      return value => Math.ceil(parseFloat(value))
    },
    rangeDefault() {
      return JSON.stringify([Math.floor(this.min), Math.ceil(this.max)])
    }
  },
  mounted() {
    const rangeSlider = this.$el.querySelector(".js-range-slider");
    this.setRangeSlider(rangeSlider);
  },
  methods: {
    setRangeSlider(slider) {
      const {
        min = 0,
        max = 100,
        default: defaultRange = `[${min},${max}]`,
        rangeBarsSelector
      } = slider.dataset;

      const callback = (_, ui) => {
        const { values = [] } = ui;

        slider.selectedRange = values;
        this.setRangeBar(slider);

        const [min = this.min, max = this.max] = values
        this.selectedMin = min
        this.selectedMax = max
        this.$emit("range-change", min, max)
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
    },
  }
};
</script>
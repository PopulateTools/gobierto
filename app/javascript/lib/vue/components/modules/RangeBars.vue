<template>
  <div class="range-slider">
    <div
      :id="`range-bars-${seed}`"
      class="range-slider--bars"
    >
      <div
        v-for="bar in histogram"
        :key="bar.id"
        :style="{ height: `${100 * (bar.count / totalItems)}%` }"
      >
        <span>{{
          rangeMin(bar.start) | money({ minimumFractionDigits: 0 })
        }}</span>
        <span>{{
          rangeMax(bar.end) | money({ minimumFractionDigits: 0 })
        }}</span>
      </div>
    </div>
    <div
      :data-min="min"
      :data-max="max"
      :data-default="rangeDefault"
      :data-range-bars-selector="`#range-bars-${seed}`"
      class="js-range-slider"
    />
    <div class="range-slider--values">
      <span>{{ selectedMin | money({ minimumFractionDigits: 0 }) }}</span>
      <span>{{ selectedMax | money({ minimumFractionDigits: 0 }) }}</span>
    </div>
  </div>
</template>

<script>
import { VueFiltersMixin } from "lib/vue/filters";
import { RangeSlider, debounce } from "lib/shared";

export default {
  name: "RangeBars",
  mixins: [VueFiltersMixin],
  props: {
    min: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 100
    },
    totalItems: {
      type: Number,
      default: 1
    },
    savedMin: {
      type: Number,
      default: null
    },
    savedMax: {
      type: Number,
      default: null
    },
    histogram: {
      type: Array,
      default: () => []
    }
  },
  inRangeClass: "in-range",
  data() {
    return {
      defaultRange: [this.min, this.max],
      selectedMin: this.savedMin || this.min,
      selectedMax: this.savedMax || this.max,
      seed: Math.random()
        .toString(36)
        .substring(7)
    };
  },
  computed: {
    rangeMin() {
      return value => Math.floor(parseFloat(value));
    },
    rangeMax() {
      return value => Math.ceil(parseFloat(value));
    },
    rangeDefault() {
      return JSON.stringify([
        this.savedMin || Math.floor(this.min),
        this.savedMax || Math.ceil(this.max)
      ]);
    }
  },
  mounted() {
    this.getRangeSlider()
  },
  updated() {
    this.selectedMin = this.savedMin || this.min;
    this.selectedMax = this.savedMax || this.max;
    this.getRangeSlider()
  },
  beforeDestroy() {
    // https://vuejs.org/v2/cookbook/avoiding-memory-leaks.html
    this.rangeSlider.destroy()
  },
  methods: {
    getRangeSlider() {
      const rangeSlider = this.$el.querySelector(".js-range-slider");
      this.setRangeSlider(rangeSlider);
    },
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

        const [min = this.min, max = this.max] = values;
        this.selectedMin = min;
        this.selectedMax = max;
        this.$emit("range-change", { min, max });
      };

      // Update values for THIS slider
      slider.min = parseFloat(min);
      slider.max = parseFloat(max);
      slider.selectedRange = JSON.parse(defaultRange);

      this.rangeSlider = new RangeSlider({
        elem: slider,
        min: slider.min,
        max: slider.max,
        defaultRange: slider.selectedRange,
        rangeCallback: debounce(callback, 750)
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

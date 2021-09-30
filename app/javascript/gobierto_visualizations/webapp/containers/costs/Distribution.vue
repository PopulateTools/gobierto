<template>
  <div class="pure-u-1 m_b_1">
    <div class="pure-g gutters">
      <h2 class="pure-u-1 gobierto-visualizations-title">
        {{ labelDistribution }}
      </h2>
      <div class="pure-u-1 pure-u-lg-1-4 metric_boxes">
        <div class="pure-u-1-1 metric_box tipsit">
          <div class="inner">
            <h3>{{ labelTotalCost }}</h3>
            <div class="metric">
              {{ totalCost }}
            </div>
          </div>
        </div>
        <div class="pure-u-1-1 metric_box tipsit">
          <div class="inner">
            <h3>{{ labelCostPerInhabitant }}</h3>
            <div class="metric">
              {{ totalCostPerHabitant | money }}
            </div>
          </div>
        </div>
        <div class="pure-u-1-1 metric_box tipsit">
          <div class="inner">
            <h3>{{ labelInhabitant }}</h3>
            <div class="metric">
              {{ populationNumber }}
            </div>
          </div>
        </div>
      </div>
      <div
        id="gobierto-visualizations-bubble-container"
        class="pure-u-1 pure-u-lg-3-4"
      >
        <div class="vis-costs vis-bubbles" />
        <div
          v-if="yearsMultiple"
          class="range-slider-costs"
        >
          <div class="range-slider-costs--container">
            <div
              v-for="item in years"
              :key="item"
              class="range-slider-costs--values"
              :class="{ 'active-slider' : activeYear === item }"
              @click="selectYearHandler(item)"
            >
              <span class="range-slider-costs--values-circle" />
              <span class="range-slider-costs--values-text">{{ item }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { VisBubble } from "lib/visualizations";
import { VueFiltersMixin } from "lib/vue/filters";

export default {
  name: 'Distribution',
  mixins: [VueFiltersMixin],
  props: {
    data: {
      type: Array,
      default: () => []
    },
    year: {
      type: String,
      default: ''
    },
    years: {
      type: Array,
      default: () => []
    },
    yearsMultiple: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      labelDistribution: I18n.t("gobierto_visualizations.visualizations.costs.distribution") || "",
      labelTotalCost: I18n.t("gobierto_visualizations.visualizations.costs.total_cost") || "",
      labelInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.inhabitants") || "",
      labelCostPerInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.cost_per_inhabitant") || "",
      population: '',
      populationNumber: '',
      visBubblesCosts: null,
      dataFilter: [],
      activeYear: null
    }
  },
  computed: {
    totalCost() {
      const total = this.dataFilter.reduce((accum,element) => accum + element.costtotal, 0)
      return (total / 1000000).toFixed(1).replace(/\./, ',') + ' M€';
    },
    totalCostPerHabitant() {
      return this.dataFilter.reduce((accum,element) => accum + element.costtotal, 0) / this.population
    }
  },
  watch: {
    year(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.updateYear(newValue)
        this.updateBubbles()
        this.activeYear = newValue
      }
    },
    activeYear(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.updateYear(newValue)
      }
    },
  },
  created() {
    this.updateYear(this.year)
  },
  mounted() {
    this.createBubbleViz()
  },
  methods: {
    updateYear(year) {
      this.activeYear = year
      this.dataFilter = this.data.filter(({ any_ }) => any_ === year)
      const [{ population: population }] = this.dataFilter
      this.population = population
      this.populationNumber = Number(population).toLocaleString(I18n.locale)
    },
    createBubbleViz() {
      this.visBubblesCosts = new VisBubble('.vis-costs', this.year, this.data);
      this.visBubblesCosts.render();
      window.addEventListener('resize', function() {
        this.updateBubbles()
      }.bind(this));
    },
    updateBubbles() {
      this.visBubblesCosts.resize(this.year)
      this.$emit('preventReload')
    },
    selectYearHandler(year) {
      this.activeYear = year
      this.visBubblesCosts.resize(year)
      this.$emit('updateYear', year)
      this.$emit('preventReload')
    },
  }
}
</script>

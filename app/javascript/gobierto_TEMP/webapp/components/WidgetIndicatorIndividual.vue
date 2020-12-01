<template>
  <div class="graph-individual">
    <div class="graph-individual__barchart">
      <div
        class="graph-individual__barchart--active"
        :style="{ width: `${percentage}%` }"
      />
    </div>
    <div class="graph-individual__title">
      {{ title }}
    </div>
    <div class="graph-individual__metric--container">
      <template v-for="{ metric, value } in metrics">
        <div
          :key="metric"
          class="graph-individual__metric"
        >
          <div class="graph-individual__metric--title">
            {{ metric }}
          </div>
          <div class="graph-individual__metric--value">
            {{ value }}
          </div>
        </div>
      </template>
    </div>
    <div class="graph-individual__date">
      {{ dateLabel }} {{ year }}
    </div>
  </div>
</template>

<script>
import { date, percent } from "lib/shared"

export default {
  name: "WidgetIndicatorIndividual",
  props: {
    title: {
      type: String,
      default: null
    },
    values: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      percentage: 0,
      year: null,
      metrics: [],
      dateLabel: "Fecha: ",
      valueLabel: "Alcanzado",
      objectiveLabel: "Objetivo",
      percentageLabel: "Consecución",
    }
  },
  created() {
    const [indicator] = this.values.sort(({ date: a }, { date: b }) => new Date(a) < new Date(b)) // first position will have the most up to date item

    if (indicator) {
      this.year = date(indicator.date, { year: 'numeric' })
      this.percentage = indicator.objective ? 100 * (indicator.value / indicator.objective) : 0
      this.metrics = [
        { metric: this.valueLabel, value: indicator.value },
        { metric: this.objectiveLabel, value: indicator.objective },
        { metric: this.percentageLabel, value: percent(this.percentage) },
      ]
    }
  }
}
</script>
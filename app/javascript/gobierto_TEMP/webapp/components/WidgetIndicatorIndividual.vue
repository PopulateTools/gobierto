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
export default {
  name: "WidgetIndicatorIndividual",
  data() {
    return {
      percentage: 78,
      title: "Recusandae aperiam obcaecati quam cumque? Voluptatum minima dolorum quidem perspiciatis",
      year: 2020,
      metrics: [
        { metric: "Alcanzado", value: 30 },
        { metric: "Objetivo", value: 30 },
        { metric: "Consecución", value: "30%" },
      ],
      dateLabel: "Fecha: "
    }
  }
}
</script>
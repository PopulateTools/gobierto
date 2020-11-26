<template>
  <div class="graph-table">
    <div class="graph-table__title">
      {{ title }}
    </div>
    <table class="graph-table__table">
      <thead>
        <th
          v-for="(year, ix) in years"
          :key="year"
          class="graph-table__table--th"
        >
          <template v-if="ix !== 0">
            <div class="graph-table__barchart--wrapper">
              <div class="graph-table__barchart">
                <div
                  class="graph-table__barchart--active"
                  :style="{ height: '30%' }"
                />
              </div>
              <span>{{ year }}</span>
            </div>
          </template>
        </th>
      </thead>
      <tbody>
        <tr
          v-for="metric in metrics"
          :key="metric.metric"
          class="graph-table__table--tr"
        >
          <td
            v-for="year in years"
            :key="year"
            class="graph-table__table--td"
          >
            {{ metric[year] }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: "WidgetIndicatorTable",
    data() {
    return {
      percentage: 78,
      title: "nobis sunt sapiente tempore itaque enim dicta eum error doloremque optio cumque?",
      years: [
        "metric", 2018, 2019, 2020
      ],
      metrics: [
        { metric: "Alcanzado", 2018: 30 , 2019: 45, 2020: 60 },
        { metric: "Objetivo", 2018: 30 , 2019: 45, 2020: 60 },
        { metric: "% consecución", 2018: "30%", 2019: "45%", 2020: "60%" },
      ],
      dateLabel: "Fecha: "
    }
  }
}
</script>
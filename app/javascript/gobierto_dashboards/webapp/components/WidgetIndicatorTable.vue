<template>
  <div class="graph-table">
    <div class="graph-table__title">
      {{ title }}
    </div>
    <table class="graph-table__table">
      <thead>
        <th
          v-for="({ year, percentageRelative, percentageAbsolute }, ix) in years"
          :key="year"
          class="graph-table__table--th"
        >
          <template v-if="ix !== 0">
            <div class="graph-table__barchart--wrapper">
              <div class="graph-table__barchart--wrapper-relative">
                <div
                  class="graph-table__barchart"
                  :style="{ height: `${percentageAbsolute}%` }"
                >
                  <div
                    class="graph-table__barchart--active"
                    :style="{ height: `${percentageRelative}%` }"
                  />
                </div>
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
            v-for="{ year } in years"
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
import { date, percent } from "lib/shared";

const formatValues = (arr, prop, transform = x => x) =>
  arr.reduce(
    (acc, item) => ({
      ...acc,
      [date(item.date, { year: "numeric" })]: transform(item[prop])
    }),
    {}
  );

export default {
  name: "WidgetIndicatorTable",
  filters: {
    percent
  },
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
      years: [{ year: "metric" }],
      metrics: [],
      dateLabel: "Fecha: ",
      valueLabel: "Alcanzado",
      objectiveLabel: "Objetivo",
      percentageLabel: "% consecución"
    };
  },
  created() {
    // filter the first four
    const [y1, y2, y3, y4] = this.values.sort(
      ({ date: a }, { date: b }) => new Date(a) < new Date(b)
    );
    const years = [...[y1, y2, y3, y4]];

    // add percentage absolutes and relative. And reverse array to show years ascendently
    const highestObjective = Math.max(
      ...years.map(({ objective }) => objective)
    );
    const valuesCalculated = years
      .map(x => ({
        ...x,
        percentageRelative: x.objective ? 100 * (x.value / x.objective) : 0,
        percentageAbsolute: highestObjective ? 100 * (x.objective / highestObjective) : 100,
      }))
      .reverse();

    this.years.push(
      ...valuesCalculated.map(({ date: d, percentageRelative, percentageAbsolute }) => ({
        year: date(d, { year: "numeric" }),
        percentageRelative,
        percentageAbsolute
      }))
    );
    this.metrics = [
      { metric: this.valueLabel, ...formatValues(valuesCalculated, "value") },
      {
        metric: this.objectiveLabel,
        ...formatValues(valuesCalculated, "objective")
      },
      {
        metric: this.percentageLabel,
        ...formatValues(valuesCalculated, "percentageRelative", percent)
      }
    ];
  }
};
</script>

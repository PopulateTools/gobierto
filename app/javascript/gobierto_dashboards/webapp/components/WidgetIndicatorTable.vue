<template>
  <div class="graph-table">
    <div class="graph-table__title">
      {{ title }}
    </div>
    <table class="graph-table__table">
      <thead>
        <th
          v-for="({ year, percentageRelative, percentageAbsolute }, ix) in years"
          :key="`${year}-${ix}`"
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
              <span>{{ year | date({ year: "numeric" }) }}</span>
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
            v-for="({ year }, ix) in years"
            :key="`${year}-${ix}`"
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
import { date, percent } from '../../../lib/vue/filters';

const formatValues = (arr, prop, transform = x => x) =>
  arr.reduce(
    (acc, item) => ({
      ...acc,
      [item.date]: transform(item[prop])
    }),
    {}
  );

export default {
  name: "WidgetIndicatorTable",
  filters: {
    percent,
    date
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
      dateLabel: I18n.t("gobierto_dashboards.date") || "",
      valueLabel: I18n.t("gobierto_dashboards.value") || "",
      objectiveLabel: I18n.t("gobierto_dashboards.objective") || "",
      percentageLabel: I18n.t("gobierto_dashboards.percentage_alt") || ""
    };
  },
  created() {
    // filter the first four
    const [y1, y2, y3, y4] = this.values.sort(
      ({ date: a }, { date: b }) => new Date(a) < new Date(b)
    );
    // remove null/undefined, if there were < 4 years
    const years = [...[y1, y2, y3, y4]].filter(Boolean);

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
        year: d,
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

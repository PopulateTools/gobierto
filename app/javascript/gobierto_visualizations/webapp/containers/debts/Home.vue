<template>
  <div>
    <div class="pure-g gutters m_b_4">
      <p>Debts</p>
    </div>
    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-md-12-24">
        <Table :data="creditorData" />
      </div>
      <div class="pure-u-1 pure-u-md-12-24">
        <div
          ref="treemap-creditor"
          style="height: 400px"
        />
      </div>
    </div>
    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-md-12-24">
        <Table :data="debtsData" />
      </div>
      <div class="pure-u-1 pure-u-md-12-24">
        <div
          ref="treemap-debts"
          style="height: 400px"
        />
      </div>
    </div>
    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-md-24-24">
        <div
          ref="bar-chart-stacked-debts"
        />
      </div>
    </div>
    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-md-24-24">
        <div
          ref="bar-chart-small-debts"
        />
      </div>
    </div>
  </div>
</template>
<script>
import { EventBus } from "../../lib/mixins/event_bus";
import { TreeMap, BarChartStacked, BarChartSplit } from "gobierto-vizzs";
import Table from './Table.vue';

export default {
  name: 'Home',
  components: {
    Table
  },
  data() {
    return {
      debtsData: this.$root.$data.debtsEntitat,
      creditorData: this.$root.$data.debtsTotal,
      evolutionDebtData: this.$root.$data.debtsEvolution,
      labelCategories: I18n.t('gobierto_visualizations.visualizations.contracts.categories') || "",
    }
  },
  mounted() {
    EventBus.$emit("mounted");
    this.initGobiertoVizzs()
    this.parseDataEvolution()
  },
  methods: {
    initGobiertoVizzs() {
      const treemapCreditor = this.$refs["treemap-creditor"]
      const treemapDebts = this.$refs["treemap-debts"]
      const barChartStackedDebts = this.$refs["bar-chart-stacked-debts"]
      const barChartMultipleDebts = this.$refs["bar-chart-small-debts"]
      if (treemapCreditor && treemapCreditor.offsetParent !== null) {
        this.treemapCreditor = new TreeMap(treemapCreditor, this.creditorData, {
          rootTitle: this.labelCategories,
          group: ["entitat"],
          value: "endeutament_a_31_12_2021"
        })
      }

      if (treemapDebts && treemapDebts.offsetParent !== null) {
        this.treemapDebts = new TreeMap(treemapDebts, this.debtsData, {
          rootTitle: this.labelCategories,
          group: ["entitat_creditora"],
          value: "endeutament_pendent_a_31_12_2021"
        })
      }

      if (barChartStackedDebts && barChartStackedDebts.offsetParent !== null) {
        this.barChartStackedDebts = new BarChartStacked(barChartStackedDebts, this.evolutionDebtData, {
          rootTitle: this.labelCategories,
          orientationLegend: "left",
          showLegend: true,
          excludeColumns: ["Total endeutament grup", "Deute viu", "Rati deute viu %"],
          extraLegends: ["Deute viu", "Rati deute viu %"],
          margin: { left: 240 },
          x: "any",
          value: "endeutament_pendent_a_31_12_2021"
        })
      }

      if (barChartMultipleDebts && barChartMultipleDebts.offsetParent !== null) {
        this.barChartMultipleDebts = new BarChartSplit(barChartMultipleDebts, this.parseDataEvolution(this.evolutionDebtData), {
          rootTitle: this.labelCategories,
          y: "any",
          x: "group",
          count: "value"
        })
      }
      this.isGobiertoVizzsLoaded = true
    },
    parseDataEvolution(rawData) {
      const data = [];
      const filteredData = rawData.map((d) => {
        return {
          any: d.any,
          "Ajuntament": d["Ajuntament"],
          "Mataro Audiovisual": d["Mataro Audiovisual"],
          "Digitial Mataro Maresme": d["Digitial Mataro Maresme"],
          "Consorci Residus": d["Consorci Residus"],
          PUMSA: d.PUMSA,
          "Grup Tecnocampus": d["Grup Tecnocampus"],
          AMSA: d.AMSA,
          "Deute FCC": d["Deute FCC"],
          "Porta Laietana": d["Porta Laietana"],
          "Altres pie messa": d["Altres pie messa"]
        }
      })
      const arrayOfYear = filteredData.map(({ any }) => any);
      for (let [index, value] of arrayOfYear.entries()) {
        for (let item in filteredData[index]) {
          console.log("item", item);
          if (item !== "any") {
            let elementArrayOfObjects = {
              any: value,
              group: item,
              value: filteredData[index][item]
            }
            data.push(elementArrayOfObjects);
          }
        }
      }
      return data
    }
  }
}

</script>

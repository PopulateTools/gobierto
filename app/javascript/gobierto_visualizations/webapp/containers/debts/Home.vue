<template>
  <div class="gobierto-visualizations gobierto-visualizations-debts">
    <div class="gobierto-visualizations-container-title block">
      <h2 class="pure-u-1 gobierto-visualizations-title gobierto-visualizations-title-select">
        {{ labelTitle }}
      </h2>
    </div>
    <div class="pure-g block header_block_inline m_b_1">
      <div class="pure-u-1 pure-u-md-24-24">
        <div class="pure-g gutters">
          <div class="pure-u-1 pure-u-md-12-24">
            <p class="gobierto-visualizations-description">
              {{ labelDescription }}
            </p>
            <p class="gobierto-visualizations-description">
              {{ labelDescriptionDate }}
            </p>
          </div>
          <div class="pure-u-1 pure-u-md-12-24">
            <div class="metric_boxes">
              <div class="pure-u-1-3 metric_box tipsit">
                <div class="inner">
                  <h3>{{ labelTitleTotalDebt }}</h3>
                  <div class="metric">
                    {{ totalDebt }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <h2 class="pure-u-1">
        {{ labelTitleDebtor }}
      </h2>
      <div class="pure-u-24-24">
        <div class="pure-g gutters">
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
      </div>
      <h2 class="pure-u-1 gobierto-visualizations-title">
        {{ labelTitleCreditor }}
      </h2>
      <div class="pure-u-24-24">
        <div class="pure-g  gutters">
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
      </div>
      <h2 class="pure-u-1 gobierto-visualizations-title">
        {{ labelTitleEvolutionDebt }}
      </h2>
      <span class="description">
        {{ labelTitleMillions }}
      </span>
      <div class="pure-u-24-24">
        <div class="pure-u-1 pure-u-md-24-24">
          <div
            ref="bar-chart-stacked-debts"
          />
        </div>
      </div>
      <h2 class="pure-u-1 gobierto-visualizations-title">
        {{ labelTitleBreakdownDebt }}
      </h2>
      <span class="description">
        {{ labelTitleMillions }}
      </span>
      <div class="pure-u-24-24">
        <div class="pure-u-1 pure-u-md-24-24">
          <div
            ref="bar-chart-small-debts"
            class="bar-chart-small-debts"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { EventBus } from "../../lib/mixins/event_bus";
import { TreeMap, BarChartStacked, BarChartSplit } from "gobierto-vizzs";
import { money } from "lib/vue/filters";
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
      labelTitle: I18n.t("gobierto_visualizations.visualizations.debts.title") || "",
      labelDescription: I18n.t("gobierto_visualizations.visualizations.debts.description") || "",
      labelDescriptionDate: I18n.t("gobierto_visualizations.visualizations.debts.date_debt") || "",
      labelTitleDebtor: I18n.t("gobierto_visualizations.visualizations.debts.debtor") || "",
      labelTitleCreditor: I18n.t("gobierto_visualizations.visualizations.debts.creditor") || "",
      labelTitleEvolutionDebt: I18n.t("gobierto_visualizations.visualizations.debts.evolution_debt") || "",
      labelTitleBreakdownDebt: I18n.t("gobierto_visualizations.visualizations.debts.breakdown_debt") || "",
      labelTitleTotalDebt: I18n.t("gobierto_visualizations.visualizations.debts.total_debt") || "",
      labelTitleMillions: I18n.t("gobierto_visualizations.visualizations.debts.millions") || "",
    }
  },
  computed: {
    totalDebt() {
      const [{ endeutament_a_31_12_2021 }] = this.creditorData.filter(({ entitat }) => entitat === "TOTAL GENERAL")
      return (endeutament_a_31_12_2021 / 1000000).toFixed(1).replace(/\./, ',') + ' M€';
    }
  },
  mounted() {
    EventBus.$emit("mounted");
    this.initGobiertoVizzs();
  },
  methods: {
    tooltipTreeMap(d) {
      return `
        <span class="beeswarm-tooltip-header">
          ${d.data.title}
        </span>
        <span class="beeswarm-tooltip-table-element-text">
            <b>${money(d.value)}</b>
        </span>
      `
    },
    tooltipBarChartStacked(d) {
      let tooltipContent = [];
      const titleIsDate = d.data.any && Object.prototype.toString.call(d.data.any) === "[object Date]" && !isNaN(d.data.any)
      const titleTooltip = titleIsDate ? d.data.any.getFullYear() : d.data.any
      const filteredDataByKey = Object.fromEntries(Object.entries(d.data).filter(([key]) => !["Total endeutament grup", "any", "Deute Viu Sector Administracions Públiques", "Rati deute viu %", "Deute Viu Grup Ajuntament"].includes(key)));
      for (const key in filteredDataByKey) {
        const valueContent = `
          <div class="tooltip-barchart-stacked-grid">
            <span class="tooltip-barchart-stacked-grid-key-color ${key.replace(/\s/g, '')}"></span>
            <span class="tooltip-barchart-stacked-grid-key">${key}:</span>
            <span class="tooltip-barchart-stacked-grid-value">${filteredDataByKey[key].toLocaleString()} M€</span>
          </div>`
        tooltipContent.push(valueContent);
      }
      return `
        <span class="tooltip-barchart-stacked-title">${titleTooltip}</span>
        ${tooltipContent.join("")}
      `;
    },
    initGobiertoVizzs() {
      const treemapCreditor = this.$refs["treemap-creditor"]
      const treemapDebts = this.$refs["treemap-debts"]
      const barChartStackedDebts = this.$refs["bar-chart-stacked-debts"]
      const barChartMultipleDebts = this.$refs["bar-chart-small-debts"]
      if (treemapCreditor && treemapCreditor.offsetParent !== null) {
        this.treemapCreditor = new TreeMap(treemapCreditor, this.creditorData.filter(({ entitat }) => entitat !== "TOTAL GENERAL"), {
          rootTitle: "test",
          id: "title",
          group: ["entitat"],
          value: "endeutament_a_31_12_2021",
          margin: { top: 0 },
          itemTemplate: this.treemapItemTemplate,
          tooltip: this.tooltipTreeMap
        })
      }

      if (treemapDebts && treemapDebts.offsetParent !== null) {
        this.treemapDebts = new TreeMap(treemapDebts, this.debtsData.filter(({ entitat_creditora }) => entitat_creditora !== "TOTAL GENERAL"), {
          rootTitle: "test",
          id: "title",
          group: ["entitat_creditora"],
          value: "endeutament_pendent_a_31_12_2021",
          margin: { top: 0 },
          itemTemplate: this.treemapItemTemplate,
          tooltip: this.tooltipTreeMap
        })
      }

      if (barChartStackedDebts && barChartStackedDebts.offsetParent !== null) {
        this.barChartStackedDebts = new BarChartStacked(barChartStackedDebts, this.evolutionDebtData, {
          rootTitle: this.labelCategories,
          orientationLegend: "left",
          showLegend: true,
          excludeColumns: ["Deute Viu Grup Ajuntament", "Deute Viu Sector Administracions Públiques", "Rati deute viu %"],
          extraLegends: ["Deute Viu Grup Ajuntament","Deute Viu Sector Administracions Públiques", "Rati deute viu %"],
          margin: { left: 340 },
          x: "any",
          locale: "es-ES",
          value: "endeutament_pendent_a_31_12_2021",
          tooltip: this.tooltipBarChartStacked
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
    treemapItemTemplate(d) {
      this.disableTreemapClick()
      return [
        `<p class="treemap-item-title">${d.data.title}</p>`,
        `<p class="treemap-item-text">${money(d.value)}</p>`
      ].join("")
    },
    parseDataEvolution(rawData) {
      const data = [];
      const filteredData = rawData.map(d => {
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
      const arrayOfYear = filteredData.map(({ any }, i) => [i, any]);
      for (let [index, value] of arrayOfYear) {
        for (let item in filteredData[index]) {
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
    },
    disableTreemapClick() {
      document.querySelectorAll(".treemap-item foreignObject").forEach(box =>{
        box.addEventListener("click", (e) => {
          e.stopPropagation();
          e.preventDefault();
        })
      })
    }
  }
}

</script>

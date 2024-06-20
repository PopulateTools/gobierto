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
            class="bar-chart-stacked-debts"
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
import { BarChartSplit, BarChartStacked as OriginalBarChartStacked, TreeMap } from 'gobierto-vizzs';
import { money } from '../../../../lib/vue/filters';
import { debtsEvolutionString } from '../../lib/config/debts.js';
import { EventBus } from '../../lib/mixins/event_bus';
import Table from './Table.vue';

let scaleColor = null

class BarChartStacked extends OriginalBarChartStacked {
  build() {
    // call to the original build
    super.build()
    // then, call to our custom function
    this.buildExtraAxis();

    // since the tooltip function cannot access the class scope ("this" context)
    // we store it in a helper variable
    scaleColor = this.scaleColor
  }

  buildExtraAxis() {
    const extraLegends = ["Deute Viu Grup Ajuntament","Deute Viu Sector Administracions Públiques", "Rati deute viu %"]

    const data = new Map()
    extraLegends.map(x => data.set(x, this.data.filter(y => y.group === x)))

    const extra = this.g
      .selectAll(".extra-legend")
      .data(data)
      .enter()
      .append("g")
      .attr("class", "extra-legend")
      .attr('transform', (_, i) => `translate(0,${this.height + ((i + 1) * 28)})`)

    extra
      .append("text")
      .attr("class", "extra-legend-text")
      .attr("text-anchor", "end")
      .attr("x", -60)
      .attr("y", (_, i) => this.margin.top + (i * 2) + 14)
      .text(([key]) => key);

    extra
      .selectAll("class", "extra-legend-value")
      .data(([_, values]) => values)
      .enter()
      .append("text")
      .attr("class", "extra-legend-value")
      .attr("x", d => this.scaleX(d[this.xAxisProp]))
      .attr("y", this.margin.top + 14)
      .text(d => d[this.countProp].toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }))
  }
}

export default {
  name: 'Home',
  inject: ['data'],
  components: {
    Table
  },
  data() {
    return {
      debtsData: this.data.debtsEntitat,
      debtsKey: this.data.debtsEntitatKey,
      creditorData: this.data.debtsTotal,
      creditorKey: this.data.debtsTotalKey,
      labelTitle: I18n.t("gobierto_visualizations.visualizations.debts.title") || "",
      labelDescription: I18n.t("gobierto_visualizations.visualizations.debts.description") || "",
      // NOTE: in case of updating data, this translation must be changed
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
      const getTotal = this.creditorData.filter(({ entitat }) => entitat === "TOTAL GENERAL")
      return (getTotal[0][this.creditorKey] / 1000000).toFixed(1).replace(/\./, ',') + ' M€';
    }
  },
  mounted() {
    EventBus.$emit("mounted");
    this.initGobiertoVizzs();
  },
  methods: {
    tooltipTreeMapCreditor(d) {
      return `
        <span class="beeswarm-tooltip-header">
          ${d.data.children[0].entitat_tooltip}
        </span>
        <span class="beeswarm-tooltip-table-element-text">
            <b>${money(d.value)}</b>
        </span>
      `
    },
    tooltipTreeMapDebts(d) {
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
      const [ titleTooltip ] = d.data

      const fieldsExcluded = ["Total endeutament grup", "any", "Deute Viu Sector Administracions Públiques", "Rati deute viu %", "Deute Viu Grup Ajuntament"]
      const filteredData = Array.from(d.data[1]).filter(([key]) => !fieldsExcluded.includes(key));

      const tooltipContent = filteredData.map(([key, values]) => (`
          <div class="tooltip-barchart-stacked-grid">
            <span class="tooltip-barchart-stacked-grid-key-color" style="background-color:${scaleColor(key)}"></span>
            <span class="tooltip-barchart-stacked-grid-key">${key}:</span>
            <span class="tooltip-barchart-stacked-grid-value">${values[0].count.toLocaleString()} M€</span>
          </div>`));

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
        this.treemapCreditor = new TreeMap(treemapCreditor, this.parseDataTotal(this.creditorData), {
          rootTitle: "test",
          id: "title",
          group: ["entitat"],
          value: this.creditorKey,
          margin: { top: 0 },
          itemTemplate: this.treemapItemTemplate,
          tooltip: this.tooltipTreeMapCreditor
        })
      }

      if (treemapDebts && treemapDebts.offsetParent !== null) {
        this.treemapDebts = new TreeMap(treemapDebts, this.debtsData.filter(({ entitat_creditora }) => entitat_creditora !== "TOTAL GENERAL"), {
          rootTitle: "test",
          id: "title",
          group: ["entitat_creditora"],
          value: this.debtsKey,
          margin: { top: 0 },
          itemTemplate: this.treemapItemTemplate,
          tooltip: this.tooltipTreeMapDebts
        })
      }

      if (barChartStackedDebts && barChartStackedDebts.offsetParent !== null) {
        const extraLegends = ["Deute Viu Grup Ajuntament","Deute Viu Sector Administracions Públiques", "Rati deute viu %"]
        const series = debtsEvolutionString.filter(x => !extraLegends.includes(x))

        // prepare the data according to the chart is expecting to
        const data = this.data.debtsEvolution.flatMap(x => debtsEvolutionString.map(y => ({ phase: x.any, count: x[y], group: y })))

        this.barChartStackedDebts = new BarChartStacked(barChartStackedDebts, data, {
          showLegend: true,
          series,
          margin: { left: 340, bottom: 160 },
          x: "phase",
          y: "group",
          count: "count",
          locale: "es-ES",
          tooltip: this.tooltipBarChartStacked
        })
      }

      if (barChartMultipleDebts && barChartMultipleDebts.offsetParent !== null) {
        this.barChartMultipleDebts = new BarChartSplit(barChartMultipleDebts, this.parseDataEvolution(this.data.debtsEvolution), {
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
    parseDataTotal(rawData) {
      const data = rawData.map(({ entitat, entitat_tooltip, ...rest }) => {
        entitat_tooltip = entitat
        if (entitat === "AJUNTAMENT - PENDENT RETORN PIE LIQ. NEGATIVA 2008 I 2009") {
          entitat = "AJUNTAMENT - PENDENT RETORN PIE"
        }
        if (entitat === "FUNDACIÓ TCM") {
          entitat = "FUND. TCM"
        }

        return {
          entitat,
          entitat_tooltip,
          ...rest
        }
      }).filter(({ entitat }) => entitat !== "TOTAL GENERAL")
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

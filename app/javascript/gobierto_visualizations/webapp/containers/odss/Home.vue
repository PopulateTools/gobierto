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
                  <h3>{{ labelTitleTotalAssigned }}</h3>
                  <div class="metric">
                    {{ totalAssigned }}
                  </div>
                </div>
              </div>
              <div class="pure-u-1-3 metric_box tipsit">
                <div class="inner">
                  <h3>{{ labelTitleTotalUnassigned }}</h3>
                  <div class="metric">
                    {{ totalUnassigned }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!--
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
      -->
    </div>
  </div>
</template>
<script>
import { TreeMap } from 'gobierto-vizzs';
import { money } from '../../../../lib/vue/filters';
import { EventBus } from '../../lib/mixins/event_bus';
import Table from './Table.vue';

let scaleColor = null

export default {
  name: 'Home',
  inject: ['data'],
  components: {
    Table
  },
  data() {
    return {
      odssBudgetsData: this.data.odssBudgets,
      odssFunctionalBudgetsData: this.data.odssFunctionalBudgets,
      odssBudgetsKey: this.data.odssBudgetsKey,
      odssFunctionalBudgetsKey: this.data.odssFunctionalBudgetsKey,
      labelTitle: I18n.t("gobierto_visualizations.visualizations.odss.title") || "",
      labelDescription: I18n.t("gobierto_visualizations.visualizations.odss.description") || "",
      labelDescriptionDate: I18n.t("gobierto_visualizations.visualizations.odss.updated_date") || "",
      labelTitleTotalAssigned: I18n.t("gobierto_visualizations.visualizations.odss.assigned") || "",
      labelTitleTotalUnassigned: I18n.t("gobierto_visualizations.visualizations.odss.unassigned") || "",
    }
  },
  computed: {
    totalAssigned() {
      const getTotal = this.odssBudgetsData.filter(({ ods_code }) => ods_code !== 0)
      return (getTotal.reduce((acc, curr) => acc + parseFloat(curr.amount), 0) / 1000000).toFixed(1).replace(/\./, ',') + ' M€'
    },
    totalUnassigned() {
      const getTotal = this.odssBudgetsData.filter(({ ods_code }) => ods_code === 0)
      return (getTotal.reduce((acc, curr) => acc + parseFloat(curr.amount), 0) / 1000000).toFixed(1).replace(/\./, ',') + ' M€'
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
    initGobiertoVizzs() {
      const treemapCreditor = this.$refs["treemap-creditor"]

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
      this.isGobiertoVizzsLoaded = true
    },
    treemapItemTemplate(d) {
      this.disableTreemapClick()
      return [
        `<p class="treemap-item-title">${d.data.title}</p>`,
        `<p class="treemap-item-text">${money(d.value)}</p>`
      ].join("")
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

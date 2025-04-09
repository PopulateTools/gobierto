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
            <div class="gobierto-visualizations-description" v-html="labelDescription"></div>
            <p class="gobierto-visualizations-description">
              {{ labelDescriptionDate }}
            </p>
          </div>
          <div class="pure-u-1 pure-u-md-12-24 metric_boxes">
            <!-- hack to display logo -->
            <div class="pure-g">
              <div id="taxes_receipt" class="pure-u-1-2">
                <img src="" style="width: 100%; "/>
              </div>
              <div class="pure-u-1-2">
                <div class="pure-g">
                  <div class="pure-u-1-1 metric_box tipsit">
                    <div class="inner">
                      <h3>{{ labelTitleTotalAssigned }}</h3>
                      <div class="metric">
                        {{ totalAssigned }} <span class="percentage">({{ totalAssignedPercentage }}%)</span>
                      </div>
                    </div>
                  </div>
                  <div class="pure-u-1-1 metric_box tipsit">
                    <div class="inner">
                      <h3>{{ labelTitleTotalUnassigned }}</h3>
                      <div class="metric">
                        {{ totalUnassigned }} <span class="percentage">({{ totalUnassignedPercentage }}%)</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <h2 class="pure-u-1">
        {{ labelTitleOds }}
      </h2>
      <div class="pure-u-24-24">
        <div class="pure-g gutters">
          <div class="pure-u-1 pure-u-md-12-24">
            <div
              ref="treemap-ods"
              style="height: 400px"
            />
          </div>
          <div class="pure-u-1 pure-u-md-12-24">
            <TableOds
              :data="odssBudgetsData"
              :odsCatalog="odsCatalog"
              :odsImages="odsImages"
              :locale="locale"
              :total="rawTotalAssigned + rawTotalUnassigned"
              :labelUnassigned="labelTitleTotalUnassigned"
            />
          </div>
        </div>
      </div>

      <h2 class="pure-u-1">
        {{ labelTitleBudgetsOds }}
      </h2>
      <div class="pure-u-24-24">
        <TableBudgetsOds
          :data="odssFunctionalBudgetsData"
          :odsCatalog="odsCatalog"
          :odsImages="odsImages"
          :locale="locale"
        />
      </div>
    </div>
  </div>
</template>
<style>
.percentage {
  font-size: 16px;
  color: #AAA;
}
</style>
<script>
import { TreeMap } from 'gobierto-vizzs';
import { money } from '../../../../lib/vue/filters';
import { EventBus } from '../../lib/mixins/event_bus';
import TableOds from './TableOds.vue';
import TableBudgetsOds from './TableBudgetsOds.vue';

let scaleColor = null

export default {
  name: 'Home',
  inject: ['data'],
  components: {
    TableOds,
    TableBudgetsOds
  },
  data() {
    return {
      locale: window.I18n.locale,
      odssBudgetsData: this.data.odssBudgets.sort((a, b) => {
        // Move items with ods_code 0 to the end
        if (a.ods_code === 0) return 1;
        if (b.ods_code === 0) return -1;
        // Keep normal ascending order for the rest
        return a.ods_code - b.ods_code;
      }),
      odssFunctionalBudgetsData: this.data.functionalBudgetsOdss,
      odssBudgetsKey: this.data.odssBudgetsKey,
      odssFunctionalBudgetsKey: this.data.functionalBudgetsOdssKey,
      labelTitle: I18n.t("gobierto_visualizations.visualizations.odss.title", { year: new Date().getFullYear() }) || "",
      labelDescription: I18n.t("gobierto_visualizations.visualizations.odss.description_html") || "",
      labelDescriptionDate: I18n.t("gobierto_visualizations.visualizations.odss.updated_date") || "",
      labelTitleTotalAssigned: I18n.t("gobierto_visualizations.visualizations.odss.assigned") || "",
      labelTitleTotalUnassigned: I18n.t("gobierto_visualizations.visualizations.odss.unassigned") || "",
      labelTitleOds: I18n.t("gobierto_visualizations.visualizations.odss.label_title_ods") || "",
      labelTitleBudgetsOds: I18n.t("gobierto_visualizations.visualizations.odss.label_title_budgets_ods") || "",
      odsImages: this.getOdsImages(this.data),
      odsCatalog: {
        1: {
          color: '#e5243b',
          title_es: 'Fin de la pobreza',
          title_ca: 'Fi de la pobresa',
          title_en: 'No Poverty',
        },
        2: {
          color: '#DDA63A',
          title_es: 'Hambre cero',
          title_ca: 'Fam zero',
          title_en: 'Zero Hunger',
        },
        3: {
          color: '#4C9F38',
          title_es: 'Salud y bienestar',
          title_ca: 'Salut i benestar',
          title_en: 'Good Health and Well-being',
        },
        4: {
          color: '#C5192D',
          title_es: 'Educación de calidad',
          title_ca: 'Educació de qualitat',
          title_en: 'Quality Education',
        },
        5: {
          color: '#FF3A21',
          title_es: 'Igualdad de género',
          title_ca: 'Igualtat de gènere',
          title_en: 'Gender Equality',
        },
        6: {
          color: '#26BDE2',
          title_es: 'Agua limpia y saneamiento',
          title_ca: 'Aigua neta i sanejament',
          title_en: 'Clean Water and Sanitation',
        },
        7: {
          color: '#FCC30B',
          title_es: 'Energía asequible y no contaminante',
          title_ca: 'Energia assequible i no contaminant',
          title_en: 'Affordable and Clean Energy',
        },
        8: {
          color: '#A21942',
          title_es: 'Trabajo decente y crecimiento económico',
          title_ca: 'Treball digne i creixement econòmic',
          title_en: 'Decent Work and Economic Growth',
        },
        9: {
          color: '#FD6925',
          title_es: 'Industria, innovación e infraestructura',
          title_ca: 'Indústria, innovació i infraestructura',
          title_en: 'Industry, Innovation and Infrastructure',
        },
        10: {
          color: '#DD1367',
          title_es: 'Reducción de las desigualdades',
          title_ca: 'Reducció de les desigualtats',
          title_en: 'Reduced Inequalities',
        },
        11: {
          color: '#FD9D24',
          title_es: 'Ciudades y comunidades sostenibles',
          title_ca: 'Ciutats i comunitats sostenibles',
          title_en: 'Sustainable Cities and Communities',
        },
        12: {
          color: '#BF8B2E',
          title_es: 'Producción y consumo responsables',
          title_ca: 'Producció i consum responsables',
          title_en: 'Responsible Consumption and Production',
        },
        13: {
          color: '#3F7E44',
          title_es: 'Acción por el clima',
          title_ca: 'Acció pel clima',
          title_en: 'Climate Action',
        },
        14: {
          color: '#0A97D9',
          title_es: 'Vida submarina',
          title_ca: 'Vida submarina',
          title_en: 'Life Below Water',
        },
        15: {
          color: '#56C02B',
          title_es: 'Vida de ecosistemas terrestres',
          title_ca: 'Vida d\'ecosistemes terrestres',
          title_en: 'Life on Land',
        },
        16: {
          color: '#00689D',
          title_es: 'Paz, justicia e instituciones sólidas',
          title_ca: 'Pau, justícia i institucions sòlides',
          title_en: 'Peace, Justice and Strong Institutions',
        },
        17: {
          color: '#19486A',
          title_es: 'Alianzas para lograr los objetivos',
          title_ca: 'Aliances per a assolir els objectius',
          title_en: 'Partnerships for the Goals',
        }
      }
    }
  },
  computed: {
    rawTotalAssigned() {
      return this.odssBudgetsData.filter(({ ods_code }) => ods_code !== 0).reduce((acc, curr) => acc + parseFloat(curr.amount), 0)
    },
    rawTotalUnassigned() {
      return this.odssBudgetsData.filter(({ ods_code }) => ods_code === 0).reduce((acc, curr) => acc + parseFloat(curr.amount), 0)
    },
    totalAssigned() {
      return (this.rawTotalAssigned / 1000000).toFixed(1).replace(/\./, ',') + ' M€'
    },
    totalAssignedPercentage() {
      return ((this.rawTotalAssigned / (this.rawTotalAssigned + this.rawTotalUnassigned)) * 100).toFixed(1)
    },
    totalUnassigned() {
      const getTotal = this.odssBudgetsData.filter(({ ods_code }) => ods_code === 0)
      return (getTotal.reduce((acc, curr) => acc + parseFloat(curr.amount), 0) / 1000000).toFixed(1).replace(/\./, ',') + ' M€'
    },
    totalUnassignedPercentage() {
      return ((this.rawTotalUnassigned / (this.rawTotalAssigned + this.rawTotalUnassigned)) * 100).toFixed(1)
    }
  },
  mounted() {
    EventBus.$emit("mounted");
    this.initGobiertoVizzs();
    setTimeout(() => {
      this.updateTreemapOdsColors();
      // Emit ajaxSuccess event to trigger any handlers that might be listening
      // This is commonly used to initialize components after AJAX operations
      $(document).trigger('ajaxSuccess');
    }, 1000)
    window.onresize = this.updateTreemapOdsColors;
  },
  methods: {
    tooltipTreeMapOds(d) {
      const ods_code = d.data.children[0].id
      const ods = this.odssTable(ods_code)
      const amount = parseFloat(d.data.children[0].value)
      const percentage = ((amount / this.rawTotalAssigned) * 100).toFixed(1)
      const ods_title = ods !== undefined ? `${ods_code}. ${ods[`title_${I18n.locale}`]}` : I18n.t("gobierto_visualizations.visualizations.odss.unassigned")
      const ods_color = ods !== undefined ? ods.color : "#000000"
      const ods_image = ods !== undefined ? `<img src="${this.odsImages[ods_code]}" width="48" height="48" alt="ODS ${ods_code}" />` : ""
      return `
        <div class="ods-tooltip-icon" style="display: flex; align-items: center; margin-bottom: 8px;">
          <div style="width: 48px; height: 48px; margin-right: 10px; display: flex; align-items: center; justify-content: center; background-color: ${ods_color}; border-radius: 4px;">
            ${ods_image}
          </div>
          <span class="beeswarm-tooltip-header">
            ${ods_title}
          </span>
        </div>
        <span class="beeswarm-tooltip-table-element-text">
          <b>${money(amount)}</b>
          <br>
          <b>(${percentage}%)</b>
        </span>
      `
    },
    initGobiertoVizzs() {
      const treemapOds = this.$refs["treemap-ods"]

      if (treemapOds && treemapOds.offsetParent !== null) {
        this.treemapOds = new TreeMap(treemapOds, this.parseDataTotal(this.odssBudgetsData), {
          margin: { top: 0 },
          group: ["id"],
          value: "value",
          itemTemplate: this.treemapItemTemplate,
          tooltip: this.tooltipTreeMapOds
        })
      }
      this.isGobiertoVizzsLoaded = true
    },
    treemapItemTemplate(d) {
      const ods_code = d.data.children[0].id
      const ods = this.odssTable(ods_code)
      const amount = parseFloat(d.data.children[0].value)
      const ods_title = ods !== undefined ? `${ods_code}. ${ods[`title_${I18n.locale}`]}` : I18n.t("gobierto_visualizations.visualizations.odss.unassigned")

      this.disableTreemapClick()

      return [
        `<p class="treemap-item-title">${ods_title}</p>`,
        `<p class="treemap-item-text">${money(amount)}</p>`
      ].join("")
    },
    parseDataTotal(rawData) {
      const data = rawData.map(({ ods_code, amount, ...rest }) => {
        return {
          id: ods_code,
          value: parseFloat(amount)
        }
      })
      return data
    },
    disableTreemapClick() {
      document.querySelectorAll(".treemap-item foreignObject").forEach(box =>{
        box.addEventListener("click", (e) => {
          e.stopPropagation();
          e.preventDefault();
        })
      })
    },
    odssTable(ods_code) {
      return this.odsCatalog[ods_code]
    },
    getOdsImages(data) {
      // Extract ODS image URLs from data attributes
      const odsImages = {};

      // Iterate from 1 to 17 to get all ODS image URLs
      for (let i = 0; i <= 17; i++) {
        const key = `odsImage-${i}`;
        if (this.$root.$options.provide.data[key]) {
          odsImages[i] = this.$root.$options.provide.data[key];
        }
      }

      return odsImages;
    },
    updateTreemapOdsColors() {
      const treemapOds = this.$refs["treemap-ods"]
      const rects = treemapOds.querySelectorAll('rect')
      for (let i = 0; i < rects.length; i++) {
        const rect = rects[i]
        const odsCode = rect.getAttribute('data-id')
        const ods = this.odssTable(odsCode)
        const color = ods !== undefined ? ods.color : "#AAAAAA"
        rect.setAttribute('fill', color)
      }
    }
  }
}
</script>

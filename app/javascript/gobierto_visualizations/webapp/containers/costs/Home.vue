<template>
  <div class="gobierto-visualizations">
    <div class="pure-g block header_block_inline m_b_1">
      <div class="pure-u-1 pure-u-md-12-24">
        <div class="gobierto-visualizations-container-title">
          <h2 class="pure-u-1 gobierto-visualizations-title gobierto-visualizations-title-select">
            {{ labelTittle }}
          </h2>
          <template v-if="yearsMultiple">
            <select
              v-model="yearFiltered"
              class="form-control gobierto-visualizations-select"
              @change="onChangeFilterYear"
            >
              <option
                v-for="year in years"
                :key="year"
                :value="year"
                :index="year"
                class="gobierto-visualizations-select-option"
              >
                {{ year }}
              </option>
            </select>
          </template>
        </div>
        <p class="gobierto-visualizations-description">
          {{ labelDescription }}
        </p>
        <p class="gobierto-visualizations-description">
          {{ labelDescription2 }}
        </p>
        <p class="gobierto-visualizations-description">
          {{ labelDescription3 }}
        </p>
        <p class="gobierto-visualizations-description-color-base">
          {{ labelDescriptionCovid }}
        </p>
      </div>
      <Distribution
        :data="groupData"
        :year="yearFiltered"
        :years="years"
        :years-multiple="yearsMultiple"
        @preventReload="injectRouter"
        @updateYear="updateData"
      />
      <Table
        :items-filter="groupDataFilter"
        :items="costDataFilter"
        :year="yearFiltered"
        :base-title="baseTitle"
      />
    </div>
  </div>
</template>
<script>
import Distribution from './Distribution.vue'
import Table from './table/Table.vue'
import { EventBus } from "../../lib/mixins/event_bus";

export default {
  name: 'Home',
  components: {
    Distribution,
    Table
  },
  data() {
    return {
      costData: this.$root.$data.costData,
      groupData: this.$root.$data.groupData,
      getSiteName: document.querySelector('[data-site-name]').getAttribute('data-site-name'),
      labelTittle: I18n.t("gobierto_visualizations.visualizations.costs.title") || "",
      labelDescription: '',
      labelDescription2: I18n.t("gobierto_visualizations.visualizations.costs.description_2") || "",
      labelDescription3: I18n.t("gobierto_visualizations.visualizations.costs.description_3") || "",
      labelDescriptionCovid: I18n.t("gobierto_visualizations.visualizations.costs.description_covid") || "",
      yearFiltered: this.$root.$data.yearsCosts[this.$root.$data.yearsCosts.length - 1],
      years: this.$root.$data.yearsCosts,
      costDataFilter: [],
      groupDataFilter: []
    }
  },
  computed: {
    yearsMultiple() {
      return this.years.length > 1
    }
  },
  watch: {
    $route(to) {
      if (to.name) {
        this.injectRouter()
      }
    }
  },
  created() {
    this.labelDescription = I18n.t("gobierto_visualizations.visualizations.costs.description", { entity_name: this.getSiteName }) || "";
    const {
      params: {
        year: year
      }
    } = this.$route
    this.yearFiltered = year ? year : this.yearFiltered
    this.costDataFilter = this.costData.filter(({ any_ }) => any_ === this.yearFiltered).sort(({ costtotal: a }, { costtotal: b }) => (a > b ? -1 : 1))
    this.groupDataFilter = this.groupData.filter(({ any_ }) => any_ === this.yearFiltered).sort(({ costtotal: a }, { costtotal: b }) => (a > b ? -1 : 1))

    this.baseTitle = document.title;
  },
  mounted() {
    this.injectRouter()
    EventBus.$emit("mounted");
  },
  methods: {
    onChangeFilterYear(value) {
      const {
        params: {
          year: year
        }
      } = this.$route
      this.yearFiltered = value.target ? value.target.value : year

      this.updateData(this.yearFiltered)
    },
    updateData(year) {
      this.yearFiltered = year
      this.costDataFilter = this.costData.filter(({ any_ }) => any_ === this.yearFiltered)
      this.groupDataFilter = this.groupData.filter(({ any_ }) => any_ === this.yearFiltered)

      // eslint-disable-next-line no-unused-vars
      this.$router.push(`/visualizaciones/costes/${this.yearFiltered}`).catch(err => {})
    },
    injectRouter() {
      const bubbleLinks = document.querySelectorAll('.bubbles-links')
      bubbleLinks.forEach(bubble => bubble.addEventListener('click', (e) => {
        const {
          target: {
            __data__: {
              ordreagrup: order,
              year: year
            }
          }
        } = e
        e.preventDefault()
        // eslint-disable-next-line no-unused-vars
        this.$router.push(`/visualizaciones/costes/${year}/${order}`).catch(err => {})
      }))
    }
  }
}

</script>

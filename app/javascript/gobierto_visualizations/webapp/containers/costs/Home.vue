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
      </div>
      <Distribution
        :data="groupData"
        :year="yearFiltered"
        :years="years"
        :years-multiple="yearsMultiple"
        @preventReload="injectRouter"
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
import { EventBus } from "../../mixins/event_bus";

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
      yearFiltered: this.$root.$data.yearsCosts[0],
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
    let yearFiltered = year
    if (!year) yearFiltered = '2019'
    this.yearFiltered = yearFiltered

    const costDataFilter = this.costData.filter(element => element.any_ === yearFiltered).sort((a, b) => (a.costtotal > b.costtotal) ? -1 : 1)
    const groupDataFilter = this.groupData.filter(element => element.any_ === yearFiltered).sort((a, b) => (a.costtotal > b.costtotal) ? -1 : 1)

    this.costDataFilter = costDataFilter
    this.groupDataFilter = groupDataFilter

    this.baseTitle = document.title;
  },
  mounted() {
    this.injectRouter()
    EventBus.$emit("mounted");
  },
  methods: {
    onChangeFilterYear(value) {
      this.injectRouter()
      let year
      if (value === '2019') {
        year = value
      } else {
        year = value.target.value
        this.yearFiltered = value.target.value
      }
      const costDataFilter = this.costData.filter(element => element.any_ === year)
      const groupDataFilter = this.groupData.filter(element => element.any_ === year)

      this.costDataFilter = costDataFilter
      this.groupDataFilter = groupDataFilter

      // eslint-disable-next-line no-unused-vars
      this.$router.push(`/visualizaciones/costes/${year}`).catch(err => {})
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

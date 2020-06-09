<template>
  <main class="gobierto-dashboards">
    <div class="pure-g block header_block_inline m_b_1">
      <div class="pure-u-1 pure-u-md-12-24">
        <div class="gobierto-dashboards-container-title">
          <h2 class="pure-u-1 gobierto-dashboards-title gobierto-dashboards-title-select">
            {{ labelTittle }}
          </h2>
          <select
            v-model="yearFiltered"
            class="form-control gobierto-dashboards-select"
            @change="onChangeFilterYear"
          >
            <option
              v-for="year in years"
              :key="year"
              :value="year"
              :index="year"
              class="gobierto-dashboards-select-option"
            >
              {{ year }}
            </option>
          </select>
        </div>
        <p class="gobierto-dashboards-description">
          {{ labelDescription }}
        </p>
      </div>
      <Distribution
        :data="groupData"
        :year="yearFiltered"
      />
      <Table
        :items-filter="groupDataFilter"
        :items="costDataFilter"
        :year="yearFiltered"
      />
    </div>
  </main>
</template>
<script>
import Distribution from './Distribution.vue'
import Table from './table/Table.vue'
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
      labelTittle: I18n.t("gobierto_dashboards.dashboards.costs.title") || "",
      labelDescription: '',
      yearFiltered: "2018",
      years: ['2018', '2019'],
      costDataFilter: [],
      groupDataFilter: []
    }
  },
  created() {
    this.labelDescription = I18n.t("gobierto_dashboards.dashboards.costs.description", { entity_name: this.getSiteName }) || "";
    const {
      params: {
        year: year
      }
    } = this.$route
    let yearFiltered = year
    if (!year) yearFiltered = '2018'
    this.yearFiltered = yearFiltered

    this.costDataFilter = this.costData.filter(element => element.year === yearFiltered)
    this.groupDataFilter = this.groupData.filter(element => element.year === yearFiltered)
  },
  methods: {
    onChangeFilterYear(value) {
      let year
      if (value === '2018') {
        year = value
      } else {
        year = value.target.value
        this.yearFiltered = value.target.value
      }
      this.costDataFilter = this.costData.filter(element => element.year === year)
      this.groupDataFilter = this.groupData.filter(element => element.year === year)
      // eslint-disable-next-line no-unused-vars
      this.$router.push(`/dashboards/costes/${year}`).catch(err => {})
    },
  }
}

</script>

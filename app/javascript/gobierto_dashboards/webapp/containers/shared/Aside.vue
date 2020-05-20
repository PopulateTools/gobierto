<template>
  <div class="pure-u-1 pure-u-lg-1-4">
    <aside class="dashboards-home-aside--gap">
      <div
        v-for="filter in filters"
        :key="filter.id"
        class="dashboards-home-aside--block"
      >
        <BlockHeader
          :title="filter.title"
          class="dashboards-home-aside--block-header"
          see-link
          @select-all="e => handleIsEverythingChecked({ ...e, filter })"
        />
        <Checkbox
          v-for="option in filter.options"
          :id="option.id"
          :key="option.id"
          :title="option.title"
          :checked="option.isOptionChecked"
          :counter="option.counter"
          class="dashboards-home-aside--checkbox"
          @checkbox-change="e => handleCheckboxStatus({ ...e, filter })"
        />
      </div>
    </aside>
  </div>
</template>

<script>
import { BlockHeader, Checkbox } from "lib/vue-components";
import { EventBus } from "../../mixins/event_bus";
import { filtersConfig } from "../../lib/config.js";

export default {
  name: 'Aside',
  components: {
    BlockHeader,
    Checkbox,
  },
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      filters: filtersConfig
    }
  },
  created(){
    this.initDateFilterOptions();
    this.updateCounters(true);

    EventBus.$on('refresh_summary_data', () => {
      this.contractsData = this.$root.$data.contractsData;
      this.updateCounters();
    });

    EventBus.$on('dc_filter_selected', ({title, id}) => {
      const filter = this.filters.find(filter => filter.id === id)

      filter.options.forEach(option => {
        if (option.title === title) {
          option.isOptionChecked = !option.isOptionChecked;
        }
      })
    });
  },
  methods: {
    initDateFilterOptions(){
      const options = [];
      let years = new Set( this.contractsData.map(({start_date_year}) => start_date_year) );

      [...years]
        .sort((a, b) => a < b ? 1 : -1)
        .forEach(year => {
        if (year != '') {
          options.push({id: year, title: year.toString(), counter: 0, isOptionChecked: false })
        }
      });

      this.filters.forEach((filter) => {
        if (filter.id == 'dates') {
          filter.options = options;
        }
      })
    },
    updateCounters(firstUpdate=false) {
      const counter = {process_types: {}, contract_types: {}, dates: {}};

      this.contractsData.forEach((contract) => {
        counter.process_types[contract.process_type] = counter.process_types[contract.process_type] || 0
        counter.process_types[contract.process_type]++

        counter.contract_types[contract.contract_type] = counter.contract_types[contract.contract_type] || 0
        counter.contract_types[contract.contract_type]++

        counter.dates[contract.start_date_year] = counter.dates[contract.start_date_year] || 0
        counter.dates[contract.start_date_year]++
      })

      this.filters.forEach((filter) => {
        const { id } = filter;
        for (let i = 0; i < filter.options.length; i++) {
          filter.options[i].counter = counter[id][filter.options[i].title];
        }

        if (firstUpdate && filter.id != 'dates') {
          // Sorting from highest to lowest, just like the chart bars.
          filter.options = filter.options.sort((a, b) => a.counter > b.counter ? -1 : 1)
        }
      })

    },
    handleIsEverythingChecked({ filter }) {
      const titles = filter.options.map(option => option.title);
      filter.options.forEach(option => option.isOptionChecked = true)

      EventBus.$emit('filter_changed', {all: true, titles: titles, id: filter.id});
    },
    handleCheckboxStatus({ id, value, filter }) {
      const option = filter.options.find(option => option.id === id)
      EventBus.$emit('filter_changed', {all: false, title: option.title, id: filter.id});
    },
  }
}
</script>

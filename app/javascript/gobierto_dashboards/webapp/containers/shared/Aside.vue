<template>
  <div class="pure-u-1 pure-u-lg-1-4">
    <aside class="dashboards-home-aside--gap">
      <div
        v-for="filter in filters"
        :key="filter.id"
        class="dashboards-home-aside--block"
      >
        <Dropdown @is-content-visible="toggle(filter)">
          <template v-slot:trigger>
            <BlockHeader
              :title="filter.title"
              class="dashboards-home-aside--block-header"
              see-link
              @select-all="e => handleIsEverythingChecked({ ...e, filter })"
              @toggle="toggle(filter)"
            />
          </template>
          <div>
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
        </Dropdown>
      </div>

      <div
        v-if="isShowDownloadDatalinkShown"
        class="dashboards-home-aside--download-open-data"
      >
        <i class="fas fa-table"></i>
        <a :href="dataDownloadEndpoint" target="_blank">
          {{ labelDownloadData }}
        </a>
      </div>

    </aside>
  </div>
</template>

<script>
import { BlockHeader, Checkbox, Dropdown } from "lib/vue-components";
import { EventBus } from "../../mixins/event_bus";
import { filtersConfig } from "../../lib/config.js";

export default {
  name: 'Aside',
  components: {
    Dropdown,
    BlockHeader,
    Checkbox,
  },
  data() {
    return {
      labelDownloadData: I18n.t('gobierto_dashboards.dashboards.contracts.download_data'),
      filters: filtersConfig
    }
  },
  props: {
    contractsData: {
      type: Array,
      default: {}
    },
    dataDownloadEndpoint: {
      type: String,
      default: ''
    }
  },
  created(){
    this.initFilterOptions();
    this.updateCounters(true);

    this.isShowDownloadDatalinkShown = !!this.dataDownloadEndpoint

    EventBus.$on('dc_filter_selected', ({title, id}) => {
      const { options = [] } = this.filters.find(( { id: i } ) => id === i) || {};

      options.forEach(option => {
        if (option.title === title) {
          option.isOptionChecked = !option.isOptionChecked;
        }
      })
    });
  },
  watch: {
    contractsData: function (newContractsData, oldContractsData) {
      this.updateCounters();
    }
  },
  methods: {
    initFilterOptions(){
      const contractTypesOptions = [];
      const processTypesOptions = [];
      const dateOptions = [];
      const years = new Set( this.contractsData.map(({start_date_year}) => start_date_year) );
      const contractTypes = new Set( this.contractsData.map(({contract_type}) => contract_type) );
      const processTypes = new Set( this.contractsData.map(({process_type}) => process_type) );


      // Contract Types
      [...contractTypes]
        .forEach((contractType, index) => {
          if (contractType) {
            contractTypesOptions.push({id: index, title: contractType, counter: 0, isOptionChecked: false })
          }
        });

      // Process Types
      [...processTypes]
        .forEach((processType, index) => {
          if (processType) {
            processTypesOptions.push({id: index, title: processType, counter: 0, isOptionChecked: false })
          }
        });

      // Dates
      [...years]
        .sort((a, b) => a < b ? 1 : -1)
        .forEach(year => {
          if (year) {
            dateOptions.push({id: year, title: year.toString(), counter: 0, isOptionChecked: false })
          }
        });

      this.filters.forEach((filter) => {
        if (filter.id === 'dates') {
          filter.options = dateOptions;
        } else if (filter.id === 'contract_types') {
          filter.options = contractTypesOptions;
        } else if (filter.id === 'process_types') {
          filter.options = processTypesOptions;
        }
      })
    },
    updateCounters(firstUpdate=false) {
      const counter = {process_types: {}, contract_types: {}, dates: {}};

      // It iterates over the contracts to get the number of items for each year, process type and contract type
      // In the end, it populates counter with something like:
      // {process_types: {'Abierto': 12, 'Abierto Simplificado': 43,...}, dates: {2020: '12'...}}
      this.contractsData.forEach(({process_type, contract_type, start_date_year}) => {
        counter.process_types[process_type] = counter.process_types[process_type] || 0
        counter.process_types[process_type]++

        counter.contract_types[contract_type] = counter.contract_types[contract_type] || 0
        counter.contract_types[contract_type]++

        counter.dates[start_date_year] = counter.dates[start_date_year] || 0
        counter.dates[start_date_year]++
      })

      // This loop fills the filters data attribute with the counter result we populated in the previous loop
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
    toggle(filter){
      this.filters.forEach(_filter => {
        if (_filter.id === filter.id) {
          _filter.isToggle = !_filter.isToggle;
        }
      })
    }
  }
}
</script>

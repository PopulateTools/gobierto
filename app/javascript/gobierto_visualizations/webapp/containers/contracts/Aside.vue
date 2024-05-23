<template>
  <div class="pure-u-1 pure-u-md-1-4 visualizations-home-aside--gap">
    <SearchFilter
      :data="contractsData"
      :search-type="type"
    />
    <aside>
      <div
        v-for="filter in filters"
        :id="createIdBlockHeader(filter.title)"
        :key="filter.id"
        class="visualizations-home-aside--block"
      >
        <Dropdown @is-content-visible="toggle(filter)">
          <template v-slot:trigger>
            <BlockHeader
              :title="filter.title"
              class="visualizations-home-aside--block-header"
              see-link
              :rotate="!filter.isToggle"
              :label-alt="filter.isEverythingChecked"
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
              :category="filter.title"
              :checked="option.isOptionChecked"
              :counter="option.counter"
              class="visualizations-home-aside--checkbox"
              @checkbox-change="e => handleCheckboxStatus({ ...e, filter })"
            />
          </div>
        </Dropdown>
      </div>

      <DownloadButton
        :data-download-endpoint="dataDownloadEndpoint"
      />
    </aside>
  </div>
</template>

<script>
import { slugString } from '../../../../lib/shared';
import { BlockHeader, Checkbox, Dropdown } from '../../../../lib/vue/components';
import DownloadButton from '../../components/DownloadButton.vue';
import SearchFilter from '../../components/SearchFilter.vue';
import { contractsFiltersConfig } from '../../lib/config/contracts.js';
import { EventBus } from '../../lib/mixins/event_bus';

export default {
  name: 'Aside',
  components: {
    Dropdown,
    BlockHeader,
    Checkbox,
    DownloadButton,
    SearchFilter
  },
  props: {
    contractsData: {
      type: Array,
      default: () => []
    },
    dataDownloadEndpoint: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      filters: contractsFiltersConfig,
      type: 'Contracts'
    }
  },
  watch: {
    contractsData() {
      this.updateCounters();
    }
  },
  created(){
    this.initFilterOptions();
    this.updateCounters(true);

    EventBus.$on('treemap-filter', ({ category, id }) => {
      let filters = this.filters.find(( { id: i } ) => category === i) || {};
      this.handleCheckboxStatus( { id: id, filter: filters })
    })
    EventBus.$on('dc-filter-selected', ({ title, id }) => {
      const { options = [] } = this.filters.find(( { id: i } ) => id === i) || {};

      options.forEach(option => {
        if (option.title === title) {
          option.isOptionChecked = !option.isOptionChecked;
        }
      })
    });
  },
  beforeDestroy(){
    EventBus.$off('dc-filter-selected');
  },
  methods: {
    createIdBlockHeader(filterName) {
      const parseFilterName = slugString(filterName)
      return `filters-${parseFilterName}`
    },
    initFilterOptions(){
      const contractTypesOptions = [];
      const processTypesOptions = [];
      const dateOptions = [];
      const categoryTypesOptions = [];
      const contractorTypesOptions = [];
      const years = new Set(this.contractsData.map(({ gobierto_start_date_year }) => gobierto_start_date_year));
      const contractTypes = new Set(this.contractsData.map(({ contract_type }) => contract_type));
      const processTypes = new Set(this.contractsData.map(({ process_type }) => process_type));
      const categoryTypes = new Set(this.contractsData.map(({ category_title }) => category_title));
      const contractorTypes = new Set(this.contractsData.map(({ contractor }) => contractor));

      // Contract Types
      [...contractTypes]
        .forEach((contractType, index) => {
          if (contractType) {
            contractTypesOptions.push({ id: index, title: contractType, counter: 0, isOptionChecked: false })
          }
        });

      // Process Types
      [...processTypes]
        .forEach((processType, index) => {
          if (processType) {
            processTypesOptions.push({ id: index, title: processType, counter: 0, isOptionChecked: false })
          }
        });

      // Dates
      [...years]
        .sort((a, b) => a < b ? 1 : -1)
        .forEach(year => {
          if (year) {
            dateOptions.push({ id: year, title: year.toString(), counter: 0, isOptionChecked: false })
          }
        });

      // Categories
      [...categoryTypes]
        .forEach((categoryType, index) => {
          if (categoryType) {
            categoryTypesOptions.push({ id: index, title: categoryType, counter: 0, isOptionChecked: false })
          }
        });

      // Contractor
      [...contractorTypes]
        .forEach((contractorType, index) => {
          if (contractorType) {
            contractorTypesOptions.push({ id: index, title: contractorType, counter: 0, isOptionChecked: false })
          }
        });

      this.filters.forEach((filter) => {
        if (filter.id === 'dates') {
          filter.options = dateOptions;
        } else if (filter.id === 'contract_types') {
          filter.options = contractTypesOptions;
        } else if (filter.id === 'process_types') {
          filter.options = processTypesOptions;
        } else if (filter.id === 'category_title') {
          filter.options = categoryTypesOptions;
        } else if (filter.id === 'contractor') {
          filter.options = contractorTypesOptions;
        }
      })

      this.filters = this.filters.filter(({ options }) => options.length > 1)
    },
    updateCounters(firstUpdate=false) {
      const counter = { process_types: {}, contract_types: {}, dates: {}, category_title: {}, contractor: {} };

      // It iterates over the contracts to get the number of items for each year, process type and contract type
      // In the end, it populates counter with something like:
      // {process_types: {'Abierto': 12, 'Abierto Simplificado': 43,...}, dates: {2020: '12'...}}
      this.contractsData.forEach(({ process_type, contract_type, gobierto_start_date_year, category_title, contractor }) => {
        counter.process_types[process_type] = counter.process_types[process_type] || 0
        counter.process_types[process_type]++

        counter.contract_types[contract_type] = counter.contract_types[contract_type] || 0
        counter.contract_types[contract_type]++

        counter.dates[gobierto_start_date_year] = counter.dates[gobierto_start_date_year] || 0
        counter.dates[gobierto_start_date_year]++

        counter.category_title[category_title] = counter.category_title[category_title] || 0
        counter.category_title[category_title]++

        counter.contractor[contractor] = counter.contractor[contractor] || 0
        counter.contractor[contractor]++
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

      filter.isEverythingChecked = !filter.isEverythingChecked;
      filter.options.map(d => (d.isOptionChecked = filter.isEverythingChecked));

      EventBus.$emit('filter-changed', { all: true, titles: titles, id: filter.id });
      EventBus.$emit("update-filters");
    },
    handleCheckboxStatus({ id, filter }) {
      const option = filter.options.find(option => option.id === id)
      EventBus.$emit('filter-changed', { all: false, title: option.title, id: filter.id });
      EventBus.$emit("update-filters");
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

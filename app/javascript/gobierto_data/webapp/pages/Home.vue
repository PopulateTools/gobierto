<template>
  <div class="gobierto-data">
    <LayoutTabs>
      <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
        <div style="background-color: rgba(113, 184, 193, .1); color: #71B8C1; height: 40vh; widht: 100%; padding: 1rem; font-weight: bold;">
          Promo - Intro al módulo
        </div>
        <InfoList :items="datasets" />
      </div>
    </LayoutTabs>
  </div>
</template>

<script>
import LayoutTabs from "./../layouts/LayoutTabs.vue";
import InfoList from "./../components/commons/InfoList.vue";
import { Middleware } from "lib/shared";
import { categoriesMixin, baseUrl } from "./../../lib/commons"
import { store } from "./../../lib/store";
import CONFIGURATION from "./../../lib/mataro.conf.js";
import axios from "axios";


export default {
  name: "Home",
  components: {
    LayoutTabs,
    InfoList
  },
  mixins: [categoriesMixin],
  data() {
    return {
      activeTabIndex: 0,
      items: store.state.items || [],
      subsetItems: [],
      filters: store.state.filters || [],
      activeFilters: store.state.activeFilters || new Map(),
      defaultFilters: store.state.defaultFilters || new Map(),
      isFetchingData: false,
      datasets: [{
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      }
      ]
    }
  },
  async created() {
    if (this.items.length) {
      this.updateDOM();
    } else {
      this.isFetchingData = true;

      const { items, filters } = await this.getItems();

      this.isFetchingData = false;

      this.items = items;
      this.defaultFilters = filters
      this.filters = filters;

      this.updateDOM();
    }
  },
  methods: {
    async getItems() {
      const [
        {
          data: { data: __items__ = [] }
        },
        {
          data: {
            data: attributesDictionary = [],
            meta: filtersFromConfiguration
          }
        }
      ] = await axios.all([
        axios.get(`${baseUrl}/datasets`),
        axios.get(`${baseUrl}/datasets/meta?stats=true`)
      ]);

      const { availableFilters } = CONFIGURATION
      // Middleware receives both the dictionary of all possible attributes, and the selected filters for the site
      this.middleware = new Middleware({
        dictionary: attributesDictionary,
        filters: availableFilters
      });

      let items = this.setData(__items__);
      let filters = [];

      if (filtersFromConfiguration) {

        items = items.map(item => ({ ...item }));

        filters = this.middleware.getFilters(filtersFromConfiguration) || [];

        if (filters.length) {
          this.activeFilters = new Map();

          // initialize active filters
          filters.forEach(filter =>
            this.activeFilters.set(filter.key, undefined)
          );

          // save the filters
          store.addFilters(filters);
          store.addDefaultFilters(filters);
        }
      }

      // Assign this object BEFORE next function for better performance
      this.subsetItems = items;

      // Optional callback to update data in background, setup in CONFIGURATION object
      const itemsUpdated = await this.alterDataObjectOptional(items);

      // Once items is updated, assign again the result
      this.subsetItems = itemsUpdated;

      // save the items
      store.addItems(itemsUpdated);
      store.addDatasets(itemsUpdated);
      console.log("store", store);

      return {
        filters,
        items: itemsUpdated
      };
    },
    filterItems(filter, key) {
      this.activeFilters.set(key, filter);
      this.updateDOM();
      // save the selected filters
      store.addActiveFilters(this.activeFilters);
    },
    updateDOM() {
      this.subsetItems = this.applyFiltersCallbacks(this.activeFilters);
      this.filters.forEach(filter => this.calculateOptionCounters(filter));
      this.isFiltering =
        [...this.activeFilters.values()].filter(Boolean).length > 0;
    },
    applyFiltersCallbacks(activeFilters) {
      let results = this.items;
      activeFilters.forEach(activeFn => {
        if (activeFn) {
          results = results.filter(d => activeFn(d.attributes));
        }
      });

      return results;
    },
    cleanFilters() {
      this.filters.splice(
        0,
        this.filters.length,
        ...this.clone(this.defaultFilters)
      );
      this.activeFilters.clear();
      this.updateDOM();
    },
    handleIsEverythingChecked({ filter }) {
      filter.isEverythingChecked = !filter.isEverythingChecked;
      filter.options.map(d => (d.isOptionChecked = filter.isEverythingChecked));
      this.handleCheckboxFilter(filter);
    },
    handleCheckboxStatus({ id, value, filter }) {
      const index = filter.options.findIndex(d => d.id === id);
      filter.options[index].isOptionChecked = value;
      this.handleCheckboxFilter(filter);
    },
    handleCheckboxFilter(filter) {
      const { key, options } = filter;
      const checkboxesSelected = new Map();
      options.forEach(({ id, isOptionChecked }) =>
        checkboxesSelected.set(id, isOptionChecked)
      );

      const size = [...checkboxesSelected.values()].filter(Boolean).length;
      // Update the property when all isEverythingChecked
      if (size === options.length) {
        filter.isEverythingChecked = true;
      }

      // Update the property when none isEverythingChecked
      if (size === 0) {
        filter.isEverythingChecked = false;
      }

      const index = this.filters.findIndex(d => d.key === key);
      this.filters.splice(index, 1, filter); // To detect array mutations

      const checkboxFilterFn = attrs =>
        attrs[key].find(d => checkboxesSelected.get(+d.id));

      const callback = size ? checkboxFilterFn : undefined;
      this.filterItems(callback, key);
    },
    calculateOptionCounters(filter) {
      const counter = ({ key, id }) => {
        // Clone current filters
        const __activeFilters__ = new Map(this.activeFilters);
        // Ignore same key callbacks (as if none of the same category are selected)
        __activeFilters__.set(key, undefined);
        // Get the items based on these new active filters
        const __items__ = this.applyFiltersCallbacks(__activeFilters__);

        return __items__.filter(({ attributes }) =>
          attributes[key].map(g => g.id).includes(id)
        ).length;
      };
      const { key, options = [] } = filter;
      if (options.length) {
        filter.options = options.map(o => ({
          ...o,
          counter: counter({ id: o.id, key })
        }));
        const index = this.filters.findIndex(d => d.key === key);
        this.filters.splice(index, 1, filter);
      }
    }
  }
}
</script>

import { VueFiltersMixin } from "lib/shared";
import axios from "axios";

const CONFIGURATION = {
  title: {
    id: "title_translations"
  },
  description: {
    id: "descripcio-projecte"
  },
  phases: {
    id: "estat"
  },
  location: {
    id: "wkt",
    center: [41.536908, 2.4418503],
    minZoom: 13,
    maxZoom: 16
  },
  availableFilters: [
    {
      id: "range",
      startKey: "data-inici",
      endKey: "data-fin"
    },
    {
      id: "estat",
      multiple: true
    },
    {
      id: "nom-servei-responsable",
      multiple: true
    },
    {
      id: "tipus-projecte"
    },
    {
      id: "import"
    }
  ],
  availableGalleryFields: [
    {
      id: "data-inici"
    },
    {
      id: "data-final"
    },
    {
      id: "import",
      filter: "money"
    },
    {
      id: "adjudicatari"
    }
  ],
  availableTableFields: [
    {
      id: "nom-projecte"
    },
    {
      id: "estat",
      multiple: true
    },
    {
      id: "import",
      filter: "money"
    }
  ],
  availableProjectFields: [
    {
      id: "nom-projecte"
    },
    {
      id: "nom-servei-responsable",
      multiple: true
    },
    {
      id: "tipus-projecte",
      multiple: true
    },
    {
      id: "descripcio-projecte"
    },
    {
      id: "notes"
    },
    {
      id: "adreca"
    },
    {
      id: "adjudicatari"
    },
    {
      id: "estat",
      multiple: true
    },
    {
      id: "data-inici",
      filter: "date"
    },
    {
      id: "data-adjudicacio",
      filter: "date"
    },
    {
      id: "data-inici-redaccio",
      filter: "date"
    },
    {
      id: "data-fi-redaccio",
      filter: "date"
    },
    {
      id: "data-final",
      type: "icon",
      icon: {
        href: "https://twitter.com",
        name: "file"
      }
    },
    {
      id: "partida",
      filter: "money",
      type: "highlight"
    },
    {
      id: "import",
      filter: "money"
    },
    {
      id: "import-adjudicacio",
      filter: "money"
    },
    {
      id: "import-liquidacio",
      filter: "money"
    },
    {
      id: "tasques",
      type: "table",
      table: {
        columns: ["nomactuacio", "nimport"]
      }
    }
  ],
  itemSpecialConfiguration: {
    fn: async data => {
      const dataArr = Array.isArray(data) ? data : [data];
      const filterArr = dataArr.filter(d => d.attributes.partida && d.attributes["any-partida"]);
      const allIds = filterArr.map(d => `'${d.attributes.partida}'`).join(",");
      const endpoint = `http://mataro.gobify.net/api/v1/data`;
      const query = `
        SELECT code_with_zone as partida, paranyprs as year, sum(parimport) as budget
        FROM mataro_budgets
        WHERE "parimport" IS NOT NULL
        AND "code_with_zone" IN (${allIds})
        GROUP BY code_with_zone, paranyprs
      `;

      const { data: { data: sql } } = await axios.get(endpoint, {
        params: {
          sql: query.trim()
        }
      })

      for (let index = 0; index < dataArr.length; index++) {
        const { attributes: { partida, "any-partida": year } } = dataArr[index];
        const { budget } = sql.find(d => d.partida === partida && d.year === year) || {};

        dataArr[index].attributes.old_partida = partida
        dataArr[index].attributes.partida = budget ? budget : null
      }

      return Array.isArray(data) ? dataArr : dataArr[0];
    }
  }
};

export const baseUrl = `${location.origin}/gobierto_investments/api/v1/projects`;

export const CommonsMixin = {
  mixins: [VueFiltersMixin],
  methods: {
    nav(item) {
      this.$router.push({ name: "project", params: { id: item.id, item } });
    },
    getFilters(stats) {
      const { availableFilters } = CONFIGURATION;
      const filters = [];
      for (let index = 0; index < availableFilters.length; index++) {
        const { id: key, ...rest } = availableFilters[index];
        const element = stats[key];
        const { field_type: type, vocabulary_terms: options = [], name_translations: title = {} } = this.getAttributesByKey(key);

        filters.push({
          ...element,
          ...rest,
          title: this.translate(title),
          options: Array.isArray(options) ? options.map(opt => ({ ...opt, title: this.translate(opt.name_translations) })) : [],
          type: type ? type : key,
          key
        });
      }

      return filters;
    },
    getPhases(stats) {
      const {
        phases: { id }
      } = CONFIGURATION;
      const { vocabulary_terms = [] } = this.getAttributesByKey(id);
      const { distribution = [] } = stats[id];
      return vocabulary_terms.map(term => {
        const { name_translations: title = {} } = term;
        const { count = 0 } = distribution.find(el => parseFloat(JSON.parse(el.value)) === parseFloat(term.id)) || {};

        return {
          ...term,
          title: this.translate(title),
          count
        };
      });
    },
    getItem(element, attributes) {
      const attr = this.getAttributesByKey(element.id);

      let value = attributes[element.id];

      if (element.multiple) {
        value = this.translate(attributes[element.id][0].name_translations);
      }

      return {
        ...attr,
        ...element,
        name: this.translate(attr.name_translations),
        value: value
      };
    },
    setItem(element) {
      const { attributes = {} } = element;
      const { title, description, phases, location, availableGalleryFields, availableTableFields, availableProjectFields } = CONFIGURATION;
      const { id: locationId, ...restLocationOptions } = location;

      return {
        ...element,
        title: this.translate(attributes[title.id]),
        description: attributes[description.id] || "",
        photo: Array.isArray(attributes.gallery) ? attributes.gallery[0] : "",
        gallery: attributes.gallery || [],
        location: attributes[locationId],
        locationOptions: restLocationOptions || {},
        phases: attributes[phases.id].map(element => ({ ...element, title: this.translate(element.name_translations) })),
        phasesFieldName: this.translate(this.getItem(phases, attributes).name_translations),
        availableGalleryFields: availableGalleryFields.map(element => this.getItem(element, attributes)),
        availableTableFields: availableTableFields.map(element => this.getItem(element, attributes)),
        availableProjectFields: availableProjectFields.map(element => this.getItem(element, attributes))
      };
    },
    setData(data) {
      return data.map(element => this.setItem(element));
    },
    async alterDataObjectOptional(data) {
      const { itemSpecialConfiguration } = CONFIGURATION;

      let spreadData = data;
      if (itemSpecialConfiguration) {
        const { fn = () => data } = itemSpecialConfiguration;
        spreadData = await fn(data);
      }

      return Array.isArray(spreadData) ? this.setData(spreadData) : this.setItem(spreadData);
    },
    getAttributesByKey(prop) {
      const { attributes = {} } =
        this.dictionary.find(entry => {
          const { attributes: { uid = "" } = {} } = entry;
          return uid === prop;
        }) || {};

      return attributes;
    }
  }
};

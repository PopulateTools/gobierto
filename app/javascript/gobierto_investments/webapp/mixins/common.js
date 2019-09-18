import { VueFiltersMixin } from "lib/shared";

const CONFIGURATION = {
  title: {
    id: "title_translations",
    filter: "translate"
  },
  description: {
    id: "descripcio-projecte"
  },
  gallery: {
    id: "imagen-principal"
  },
  phases: {
    id: "estat",
    filter: "translate"
  },
  availableGalleryFields: [
    {
      id: "wkt"
    }, {
      id: "import",
      filter: "money"
    }, {
      id: "adjudicatari"
    }
  ],
  availableTableFields: [
    {
      id: "nom-projecte"
    },
    {
      id: "estat",
      filter: "translate"
    },
    {
      id: "import",
      filter: "money"
    }
  ]
}

export const CommonsMixin = {
  mixins: [VueFiltersMixin],
  methods: {
    nav(id) {
      this.$router.push({ name: "project", params: { id, item: this.item } });
    },
    getPhases(stats) {
      const { phases: { id } } = CONFIGURATION
      const { vocabulary_terms = [] } = this.getAttributesByKey(id)
      const { distribution = [] } = stats[id];
      return vocabulary_terms.map(term => {
        const { count = 0 } = distribution.find(el => parseFloat(JSON.parse(el.value)) === parseFloat(term.id)) || {}
        return {
          ...term,
          count
        }
      })
    },
    getItem(element, attributes) {
      const attr = this.getAttributesByKey(element.id)

      return ({
        ...attr,
        ...element,
        name: attr.name_translations,
        value: Array.isArray(attributes[element.id]) ? attributes[element.id].length ? attributes[element.id][0].name_translations : null : attributes[element.id]
      })
    },
    setItem(element) {
      const { attributes = {} } = element;
      const { title, description, gallery, phases, availableGalleryFields, availableTableFields } = CONFIGURATION;

      return ({
        ...element,
        title: attributes[title.id],
        description: attributes[description.id],
        photo: attributes[gallery.id][0],
        gallery: attributes[gallery.id],
        phases: attributes[phases.id].map(element => ({ ...element, title: element.name_translations })),
        availableGalleryFields: availableGalleryFields.map(element => this.getItem(element, attributes)),
        availableTableFields: availableTableFields.map(element => this.getItem(element, attributes))
      })
    },
    setData(data) {
      return data.map(element => this.setItem(element));
    },
    getAttributesByKey(prop) {
      const { attributes = {} } = this.dictionary.find(
        entry => {
          const { attributes: { uid = "" } = {} } = entry;
          return uid === prop;
        }
      ) || {};

      return attributes;
    }
  }
};
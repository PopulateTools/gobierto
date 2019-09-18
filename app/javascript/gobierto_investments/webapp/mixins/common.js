import { VueFiltersMixin } from "lib/shared";

const CONFIG = {
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
    getItem(element, attributes) {
      const attr = this.getAttributesByKey(element.id)

      return ({
        ...attr,
        ...element,
        name: attr.name_translations,
        value: Array.isArray(attributes[element.id]) ? attributes[element.id][0].name_translations : attributes[element.id]
      })
    },
    parseItem(element) {
      const { attributes = {} } = element;
      const { title, description, gallery, phases, availableGalleryFields, availableTableFields } = CONFIG;

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
    parseData(data) {
      return data.map(element => this.parseItem(element));
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
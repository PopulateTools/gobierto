import { VueFiltersMixin } from "lib/shared";

// TODO: This configuration should come from API request, not from file
import CONFIGURATION from "../conf/mataro.conf.js";

export const baseUrl = `${location.origin}/gobierto_investments/api/v1/projects`;

export const CommonsMixin = {
  mixins: [VueFiltersMixin],
  methods: {
    nav(item) {
      this.$router.push({ name: "project", params: { id: item.id, item } });
    },
    getPhases(stats) {
      const {
        phases: { id }
      } = CONFIGURATION;
      const { vocabulary_terms = [] } = this.middleware.getAttributesByKey(id);
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
      const attr = this.middleware.getAttributesByKey(element.id);

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
    }
  }
};

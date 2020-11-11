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
        const { count = 0 } =
          distribution.find(
            el => parseFloat(JSON.parse(el.value)) === parseFloat(term.id)
          ) || {};

        return {
          ...term,
          title: this.translate(title),
          count
        };
      });
    },
    getItem(element, attributes) {
      const { id, flat, composite } = element;
      const attr = this.middleware.getAttributesByKey(id);

      let value = attributes[id];

      if (flat) {
        value = this.translate(attributes[id][0].name_translations);
      }

      if (composite) {
        const { template, params } = element;
        // pattern matches:  :PARAM   :PARAM-NAME
        const paramsPattern = new RegExp(/:(\w+[-\w+]*)/, "gi");
        const paramsReplaced = template.replace(paramsPattern, (match, ...args) => {
          let replaceStr = match
          // get the matching group
          const [group] = args;
          // get the value from parameters (that will be the field_name)
          const { value = "", pattern } = params.find(({ key }) => key === group);

          replaceStr = attributes[value]

          // If the param has a pattern, then, extract such part from the field
          // If there's no replaceStr, ignore this step
          if (replaceStr && pattern) {
            const fieldPattern = new RegExp(pattern, "gi")
            replaceStr = replaceStr.replace(fieldPattern, (match, ...args) => {
              const [group] = args
              return group
            })
          }

          return replaceStr
        });

        value = `${location.origin}${paramsReplaced}`;
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
      const {
        title,
        description,
        phases,
        location,
        availableGalleryFields,
        availableTableFields,
        availableProjectFields
      } = CONFIGURATION;
      const { id: locationId, ...restLocationOptions } = location;
      const phase_terms = this.convertToArrayOfIds(attributes[phases.id]).map(phase_id => {
        const { vocabulary_terms= [] } = this.middleware.getAttributesByKey(phases.id) || {}
        return vocabulary_terms.find(({ id }) => id === phase_id) || attributes[phases.id]
      }) || [];

      return {
        ...element,
        title: this.translate(attributes[title.id]),
        description: attributes[description.id] || "",
        photo: Array.isArray(attributes.gallery) ? attributes.gallery[0] : "",
        gallery: attributes.gallery || [],
        location: attributes[locationId],
        locationOptions: restLocationOptions || {},
        phases: phase_terms.map(element => ({
          ...element,
          title: this.translate(element.name_translations)
        })),
        phasesFieldName: this.translate(
          this.getItem(phases, attributes).name_translations
        ),
        availableGalleryFields: availableGalleryFields.map(element =>
          this.getItem(element, attributes)
        ),
        availableTableFields: availableTableFields.map(element =>
          this.getItem(element, attributes)
        ),
        availableProjectFields: availableProjectFields.map(element =>
          this.getItem(element, attributes)
        )
      };
    },
    setData(data) {
      return data.map(element => this.setItem(element));
    },
    convertToArrayOfIds(items) {
      return Array.isArray(items) ? items.map(item => (+item)) : [+items]
    }
  }
};

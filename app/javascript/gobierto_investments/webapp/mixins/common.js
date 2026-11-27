import { VueFiltersMixin } from '../../../lib/vue/filters';

// TODO: This configuration should come from API request, not from file
import CONFIGURATION from '../conf/mataro.conf.js';

export const baseUrl = `${location.origin}/gobierto_investments/api/v1/projects`;

function getAttributesByKey(prop, dictionary) {
  const { attributes = {} } =
    dictionary.find(entry => {
      const { attributes: { uid = "" } = {} } = entry;
      return uid === prop;
    }) || {};

  return attributes;
}

export const CommonsMixin = {
  mixins: [VueFiltersMixin],
  methods: {
    nav(item) {
      this.$router.push({ name: "project", params: { id: item.id, item } });
    },
    getPhases(stats, metadata) {
      const {
        phases: { id }
      } = CONFIGURATION;
      const { vocabulary_terms = [] } = getAttributesByKey(id, metadata);
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
    getItem(element, attributes, metadata) {
      const { id, composite } = element;
      const attr = getAttributesByKey(id, metadata);

      // by default
      let value = attributes[id];

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

      if (attr.field_type === "vocabulary_options") {
        // this field_type must search which term is using
        const { name_translations } = attr.vocabulary_terms?.find(term => +term?.id === +attributes[id]) || {}
        value = this.translate(name_translations)
      }

      if (attr.field_type === "numeric" && attr.options?.configuration?.unit_type === "currency") {
        attr.field_type = "money"
      }

      // Extract table configuration from plugin_configuration if type is table
      let table = element.table;
      if (element.type === "table" && attr.options?.configuration?.plugin_configuration) {
        table = attr.options.configuration.plugin_configuration;

        // Add vocabulary_terms from metadata to table configuration
        // The metadata provides vocabulary_terms for all vocabularies in vocabulary_ids
        if (table && attr.vocabulary_terms) {
          table.vocabulary_terms = attr.vocabulary_terms;
        }
      }

      return {
        ...attr,
        ...element,
        name: this.translate(attr.name_translations),
        value: value,
        table: table
      };
    },
    setItem(element, metadata) {
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
        const { vocabulary_terms= [] } = getAttributesByKey(phases.id, metadata) || {}
        return vocabulary_terms.find(({ id }) => id === phase_id) || attributes[phases.id]
      }) || [];

      return {
        ...CONFIGURATION,
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
          this.getItem(phases, attributes, metadata).name_translations
        ),
        availableGalleryFields: availableGalleryFields.map(element =>
          this.getItem(element, attributes, metadata)
        ),
        availableTableFields: availableTableFields.map(element =>
          this.getItem(element, attributes, metadata)
        ),
        availableProjectFields: availableProjectFields.map(element =>
          this.getItem(element, attributes, metadata)
        )
      };
    },
    setData(data, metadata) {
      return data.map(element => this.setItem(element, metadata));
    },
    convertToArrayOfIds(items) {
      return Array.isArray(items) ? items.map(item => (+item)) : [+items]
    }
  }
};

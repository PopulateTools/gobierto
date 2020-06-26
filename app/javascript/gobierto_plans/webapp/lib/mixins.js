import { findRecursive } from "./helpers";

export const ActiveNodeMixin = {
  data() {
    return {
      activeNode: {},
      customFields: [],
      availablePlugins: {},
      rootid: 0
    }
  },
  watch: {
    $route(to) {
      const {
        params: { id }
      } = to;
      this.setActiveNode(id);
    }
  },
  computed: {
    color() {
      return (this.rootid % this.json.length) + 1;
    }
  },
  created() {
    const {
      params: { id }
    } = this.$route;
    this.setActiveNode(id);
  },
  methods: {
    setActiveNode(id) {
      this.activeNode = findRecursive(this.json, id);

      if (this.activeNode) {
        const {
          level,
          attributes: { custom_field_records = [], plugins_data = {} } = {}
        } = this.activeNode;

        // if the activeNode is level zero, it sets the children colors
        if (level === 0) {
          this.rootid = this.json.findIndex(d => d.id === id);
        }

        // Preprocess custom fields
        if (custom_field_records.length > 0) {
          this.customFields = custom_field_records;
        }

        // Activate plugins
        if (Object.keys(plugins_data).length) {
          this.availablePlugins = plugins_data;
        }
      }
    },
  }
}
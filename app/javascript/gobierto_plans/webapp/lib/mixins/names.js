import { translate } from '../../../../lib/vue/filters';
import { PlansStore } from '../store';

export const NamesMixin = {
  data() {
    return {
      natives: new Map(),
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || "",
      labelEnds: I18n.t("gobierto_plans.plan_types.show.ends") || "",
      labelStatus: I18n.t("gobierto_plans.plan_types.show.status") || "",
      labelProgress:
        I18n.t("gobierto_plans.plan_types.show.progress").toLowerCase() || ""
    };
  },
  created() {
    this.meta = PlansStore.state.meta;

    const { last_level = 0 } = this.options || {}

    // initialize static fields
    this.natives.set("name", translate(this.getLabel(last_level)));
    this.natives.set("progress", this.labelProgress);
    this.natives.set("starts_at", this.labelStarts);
    this.natives.set("ends_at", this.labelEnds);
    this.natives.set("status_id", this.labelStatus);
  },
  methods: {
    // helper to extract the name from the uid
    getName(id) {
      let name;

      if (this.natives.has(id)) {
        // native fields
        name = this.natives.get(id);
      } else {
        // custom fields
        const { name_translations = {} } = this.getAttributes(id)
        name = translate(name_translations);
      }

      return name;
    },
    // helper to extract the attributes from the uid
    getAttributes(id) {
      const { attributes = {} } =
        this.meta.find(
          ({ attributes: { uid } = {} }) =>
            uid === (id === "status_id" ? "status" : id)
        ) || {};
      return attributes
    },
    // helper to extract the label from the configuration
    getLabel(level, number_of_elements) {
      const KEYS = PlansStore.state.options
      const key = KEYS[`level${level}`];
      return number_of_elements === 1 ? key["one"] : key["other"];
    },
    // helper to extract the status text from the id
    getStatus(value) {
      const { status } = PlansStore.state
      const { attributes: { name } = {} } = status.find(({ id }) => +id === +value) || {};
      return name
    }
  }
};

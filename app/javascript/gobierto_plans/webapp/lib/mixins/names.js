import { translate } from "lib/shared";
import { PlansStore } from "../store";

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

    // initialize static fields
    this.natives.set("progress", this.labelProgress);
    this.natives.set("starts_at", this.labelStarts);
    this.natives.set("ends_at", this.labelEnds);
    this.natives.set("status", this.labelStatus);
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
        const { attributes: { name_translations = {} } = {} } =
          this.meta.find(({ attributes: { uid } = {} }) => uid === id) || {};
        name = translate(name_translations);
      }

      return name;
    }
  }
};

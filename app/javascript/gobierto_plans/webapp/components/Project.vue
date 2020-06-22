<template>
  <div class="node-action-line">
    <div class="action-line--header node-list cat--negative">
      <h3>{{ title | translate }}</h3>
    </div>

    <div class="node-project-detail">
      <!-- Native fields -->
      <div class="project-mandatory">
        <div>
          <div class="mandatory-list">
            <div class="mandatory-title">
              {{ labelProgress }}
            </div>
            <div class="mandatory-desc">
              {{ progress | percent }}
            </div>
          </div>
          <div class="mandatory-progress">
            <div :style="{ width: roundedWidth }" />
          </div>
        </div>
        <div>
          <div class="mandatory-list">
            <div class="mandatory-title">
              {{ labelStarts }} - {{ labelEnds }}
            </div>
            <div class="mandatory-desc">
              {{ startsAt | date }} -
              {{ endsAt | date }}
            </div>
          </div>
          <div class="mandatory-list">
            <div class="mandatory-title">
              {{ labelStatus }}
            </div>
            <div class="mandatory-desc">
              {{ status | translate }}
            </div>
          </div>
        </div>
      </div>

      <CustomFields
        v-if="Object.keys(customFields).length"
        :custom-fields="customFields"
      />

      <Plugins :plugins="plugins" />
    </div>
  </div>
</template>

<script>
import CustomFields from "./CustomFields";
import Plugins from "./Plugins";
import { translate, percent, date } from "lib/shared";

export default {
  name: "ActionLine",
  components: {
    CustomFields,
    Plugins
  },
  filters: {
    translate,
    percent,
    date
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    customFields: {
      type: Object,
      default: () => {}
    },
    plugins: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || "",
      labelEnds: I18n.t("gobierto_plans.plan_types.show.ends") || "",
      labelStatus: I18n.t("gobierto_plans.plan_types.show.status") || "",
      labelProgress:
        I18n.t("gobierto_plans.plan_types.show.progress").toLowerCase() || "",
      title: "",
      progress: "",
      startsAt: null,
      endsAt: null,
      status: ""
    };
  },
  computed: {
    roundedWidth() {
      return `${Math.round(this.progress)}%`
    }
  },
  created() {
    const {
      attributes: { title, progress, starts_at, ends_at, status }
    } = this.model;

    this.title = title;
    this.progress = progress;
    this.startsAt = starts_at;
    this.endsAt = ends_at;
    this.status = status;
  }
};
</script>

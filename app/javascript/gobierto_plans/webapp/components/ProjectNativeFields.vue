<template>
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
    </div>
  </div>
</template>

<script>
import { date, percent } from '../../../lib/vue/filters';
import { NamesMixin } from '../lib/mixins/names';

export default {
  name: "ProjectNativeFields",
  filters: {
    date,
    percent
  },
  mixins: [NamesMixin],
  props: {
    model: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      labelStarts: I18n.t("gobierto_plans.plan_types.show.starts") || "",
      labelEnds: I18n.t("gobierto_plans.plan_types.show.ends") || "",
      labelProgress:
        I18n.t("gobierto_plans.plan_types.show.progress").toLowerCase() || "",
      progress: "",
      startsAt: null,
      endsAt: null
    };
  },
  computed: {
    roundedWidth() {
      return `${Math.round(this.progress)}%`;
    }
  },
  created() {
    const {
      attributes: { progress, starts_at, ends_at }
    } = this.model;

    this.progress = progress;
    this.startsAt = starts_at;
    this.endsAt = ends_at;
  }
};
</script>

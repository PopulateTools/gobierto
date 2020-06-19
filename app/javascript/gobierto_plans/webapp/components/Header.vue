<template>
  <div class="planification-header m_v_3">
    <div class="header-resume">
      <h3>{{ labelGlobalExecution }}</h3>
      <span>{{ progress | percent }}</span>
    </div>

    <div class="header-detail">
      <slot />
    </div>
  </div>
</template>

<script>
import { percent } from "lib/shared"

export default {
  name: "Header",
  filters: {
    percent
  },
  props: {
    options: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      labelGlobalExecution: I18n.t("gobierto_plans.plan_types.show.global_execution") || '',
      progress: 0
    }
  },
  created() {
    const { global_progress } = this.options
    this.progress = global_progress
  }
}
</script>
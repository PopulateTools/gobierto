<template>
  <div class="planification-header">
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
import { percent } from "lib/vue/filters"

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
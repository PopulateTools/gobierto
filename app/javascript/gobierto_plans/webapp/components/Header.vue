<template>
  <div class="planification-header m_v_3">
    <div class="header-resume">
      <h3>{{ labelGlobalExecution }}</h3>
      <span>{{ progress | percent }}</span>
    </div>

    <div class="header-detail">
      <!-- TODO -->
      <i>TODO: Complete via Vue once endpoint available</i>
      <!-- <% for i in 0..(@levels + 1) %>
      <div>
        <%= level_name_pluralize(@plan, i) %>
      </div>
      <% end %> -->
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
    progress: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelGlobalExecution: I18n.t("gobierto_plans.plan_types.show.global_execution") || ''
    }
  }
}
</script>
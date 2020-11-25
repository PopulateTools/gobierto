<template>
  <div class="widget">
    <component
      :is="indicator"
      v-if="!edit"
    />
    <form v-else />
  </div>
</template>

<script>
import { Widgets } from "../lib/widgets"

export default {
  name: "WidgetIndicator",
  props: {
    template: {
      type: String,
      default: null
    },
    edit: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      indicator: null
    }
  },
  created() {
    this.indicator = Widgets.INDICATOR.subtypes[this.template]
  }
}
</script>
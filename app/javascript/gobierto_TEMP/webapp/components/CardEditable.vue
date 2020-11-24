<template>
  <div
    :class="{'dashboards-maker--card__editing': !disabled && isEditing}"
    class="dashboards-maker--card"
    @mouseenter="handleMouseoverCard"
    @mouseleave="handleMouseoutCard"
  >
    <slot />
    <CardToolbox v-if="!disabled && isEditing" />
  </div>
</template>

<script>
import CardToolbox from "./CardToolbox"

export default {
  name: "CardEditable",
  components: {
    CardToolbox
  },
  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      isEditing: false
    }
  },
  methods: {
    handleMouseoverCard() {
      this.isEditing = true
    },
    handleMouseoutCard() {
      this.isEditing = false
    },
  }
};
</script>

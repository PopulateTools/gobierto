<template>
  <button
    class="dashboards-maker--button"
    :class="{ [`dashboards-maker--button__${template}`]: !!template }"
  >
    <i
      v-if="icon"
      :class="`fas fa-${icon}`"
    />
    <div>
      <slot />
    </div>
  </button>
</template>

<script>
export default {
  name: "Button",
  props: {
    icon: {
      type: String,
      default: null
    },
    template: {
      type: String,
      default: null
    },
  },
}
</script>
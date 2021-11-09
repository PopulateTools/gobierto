<template>
  <div class="treemap-nav-container">
    <div class="treemap-nav-buttons button-group">
      <template
        v-for="[key, value] in buttons"
      >
        <button
          :key="key"
          :class="{ 'active' : active === key }"
          class="button-grouped sort-G"
          @click="$emit('active-button', key)"
        >
          {{ value }}
        </button>
      </template>
    </div>

    <slot />
  </div>
</template>

<script>
export default {
  name: "TreeMapButtons",
  props: {
    buttons: {
      type: Array,
      default: () => []
    },
    active: {
      type: String,
      default: ""
    }
  },
}
</script>

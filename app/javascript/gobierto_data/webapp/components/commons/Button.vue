<template>
  <button
    :style="{ 'color': color, 'background-color': background }"
    class="gobierto-data-btn-blue"
  >
    <i
      v-if="icon"
      :class="'fa-' + icon"
      :style="{'color': iconColor}"
      style="color: inherit; margin: 0;"
      class="fas"
    />
    {{ text }}
    <slot />
  </button>
</template>
<script>

export default {
  name: 'Button',
  props: {
    text: {
      type: String,
      default: ''
    },
    icon: {
      type: String,
      default: ''
    },
    color: {
      type: String,
      required: true
    },
    background: {
      type: String,
      required: true
    },
    iconColor: {
      type: String,
      default: 'inherit'
    }
  }
}
</script>

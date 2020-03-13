<template>
  <button
    :style="{ 'color': color, 'background-color': background }"
    class="gobierto-data-btn-blue"
  >
    <i
      :class="'fa-' + icon"
      style="color: inherit;"
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
      required: true
    },
    icon: {
      type: String,
      required: true,
      default: ''
    },
    color: {
      type: String,
      required: true
    },
    background: {
      type: String,
      required: true
    }
  }
}
</script>

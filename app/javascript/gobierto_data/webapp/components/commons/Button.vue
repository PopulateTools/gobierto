<template>
  <button
    :style="{ 'color': color, 'background-color': background }"
    class="gobierto-data-btn-blue"
  >
    <i
      style="color: inherit;"
      :class="'fa-' + icon"
      class="fas"
    />
    {{ text }}
  </button>
</template>
<script>

export default {
  name: 'Button',
  props: {
    text: {
      type: String,
      required: true,
      default: ''
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

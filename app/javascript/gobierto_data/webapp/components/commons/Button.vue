<template>
  <button
    :style="{ 'color': color, 'background-color': background }"
    class="gobierto-data-btn-blue"
  >
    <i
      :style="{ 'color': iconColor }"
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
      required: true
    },
    icon: {
      type: String,
      required: true
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
      required: true
    }
  }
}

</script>

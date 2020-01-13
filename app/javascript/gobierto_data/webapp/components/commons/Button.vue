<template>
  <button
    class="gobierto-data-btn-blue"
    :style="{ 'color': color }"
  >
    <i
      class="fas"
      :class="'fa-' + icon"
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
    }
  }
}

</script>

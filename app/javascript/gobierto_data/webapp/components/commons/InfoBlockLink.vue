<template>
  <div class="gobierto-data-summary-header-container">
    <i
      v-if="icon"
      :class="'fa fa-' + icon"
      :style="{'color': iconColor, 'opacity': opacity}"
    />
    <span class="gobierto-data-summary-header-container-label">
      {{ label }}
    </span>
    <span class="gobierto-data-summary-header-container-text">
      <a
        :href="url"
        target="_blank"
      >{{ text }}</a>
    </span>
  </div>
</template>
<script>

export default {
  name: "InfoBlockText",
  props: {
    icon: {
      type: String,
      default: ''
    },
    text: {
      type: String,
      default: ''
    },
    url: {
      type: String,
      default: ''
    },
    label: {
      type: String,
      default: ''
    },
    opacity: {
      type: String,
      default: ''
    },
    iconColor: {
      type: String,
      default: 'inherit'
    }
  }
}
</script>

<template>
  <div class="gobierto-data-summary-header-container">
    <i
      v-if="icon"
      :class="'fa fa-' + icon"
      :style="{'color': iconColor, 'opacity': opacity}"
      style="margin-right: .25rem;"
    />
    <span
      v-if="label"
      class="gobierto-data-summary-header-container-label"
    >
      {{ label }}
    </span>
    <span class="gobierto-data-summary-header-container-text">
      <LinkableText
        :text="text"
        :url="url"
      />
    </span>
  </div>
</template>
<script>
import LinkableText from './../commons/LinkableText.vue'

export default {
  name: "InfoBlockText",
  components: { LinkableText },
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
      default: ""
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

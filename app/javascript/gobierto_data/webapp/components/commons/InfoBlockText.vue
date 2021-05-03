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
    <template v-if="isAnObject">
      <template v-if="hasUrl">
        <a
          :href="url"
          class="gobierto-data-summary-header-container-text"
        >
          {{ license | translate }}
        </a>
      </template>
      <template v-else>
        <span class="gobierto-data-summary-header-container-text">
          {{ license | translate }}
        </span>
      </template>
    </template>
    <template v-else>
      <span class="gobierto-data-summary-header-container-text">
        {{ text }}
      </span>
    </template>
  </div>
</template>
<script>
import { translate } from "lib/vue/filters"

export default {
  name: "InfoBlockText",
  filters: {
    translate
  },
  props: {
    icon: {
      type: String,
      default: ''
    },
    text: {
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
    },
    license: {
      type: [String, Object],
      default: ''
    }
  },
  data() {
    return {
      url: null
    }
  },
  computed: {
    isAnObject(){
      return typeof this.license === 'object'
    },
    hasUrl(){
      return this.license.url !== ''
    }
  },
  created() {
    ({
      url: this.url
    } = this.license)
  }
}
</script>

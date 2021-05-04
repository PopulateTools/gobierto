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
    <template v-if="hasLicense">
      <a
        :href="licenseUrl | translate"
        target="_blank"
        class="gobierto-data-summary-header-container-text"
      >
        {{ licenseText | translate }}
      </a>
    </template>
    <template v-else-if="hasSource">
      <template v-if="hasSourceUrl">
        <a
          :href="sourceUrl"
          target="_blank"
          class="gobierto-data-summary-header-container-text"
        >
          {{ sourceText }}
        </a>
      </template>
      <template v-else>
        <span class="gobierto-data-summary-header-container-text">
          {{ sourceText }}
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
      type: Object,
      default: () => {}
    },
    source: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      licenseText: '',
      licenseUrl: '',
      sourceText: '',
      sourceUrl: '',
    }
  },
  computed: {
    hasLicense(){
      return this.license !== undefined
    },
    hasSource(){
      return this.source !== undefined
    },
    hasSourceUrl() {
      return this.source.url !== undefined && this.source.url !== ""
    }
  },
  created() {
    if (this.license) {
      ({
        text: this.licenseText,
        url: this.licenseUrl,
      } = this.license )
    }

    if (this.source) {
      ({
        text: this.sourceText,
        url: this.sourceUrl,
      } = this.source)
    }
  }
}
</script>

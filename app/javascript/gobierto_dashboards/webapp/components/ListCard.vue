<template>
  <div class="dashboards-viewer__card-container">
    <div class="dashboards-viewer__card">
      <h2 class="dashboards-viewer__card-title">
        {{ title }}
      </h2>
      <span class="dashboards-viewer__card-subtitle">{{ indicatorsLabel }}</span>
    </div>
  </div>
</template>

<script>
export default {
  name: "ListCard",
  props: {
    title: {
      type: String,
      default: null
    },
    // eslint-disable-next-line vue/prop-name-casing
    widgets_configuration: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      indicators: this.widgets_configuration.map(({ indicator }) => indicator).length
    }
  },
  computed: {
    indicatorsLabel() {
      return I18n.t("gobierto_dashboards.indicators_amount", { amount: this.indicators || 0 })
    }
  },
};
</script>

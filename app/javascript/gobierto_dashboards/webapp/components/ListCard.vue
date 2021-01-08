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
  computed: {
    indicatorsLabel() {
      const amount = this.widgets_configuration ? this.widgets_configuration.map(({ indicator } = {}) => indicator).length : 0
      return I18n.t("gobierto_dashboards.indicators_amount", { amount })
    }
  },
};
</script>

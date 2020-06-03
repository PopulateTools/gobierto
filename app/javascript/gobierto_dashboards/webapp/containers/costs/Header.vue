<template>
  <div class="pure-u-1 gutters m_b_1">
    <h2 class="gobierto-dashboards-title">{{ titleHeader }}</h2>
  </div>
</template>

<script>

export default {
  name: 'Header',
  data() {
    return {
      titleHeader: I18n.t("gobierto_dashboards.layouts.application.gobierto_dashboards.costs") || ""
    };
  },
}
</script>

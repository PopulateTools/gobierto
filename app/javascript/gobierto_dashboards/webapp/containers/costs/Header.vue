<template>
  <div class="pure-u-1 gutters m_b_1">
    <p>{{ titleHeader }}</p>
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

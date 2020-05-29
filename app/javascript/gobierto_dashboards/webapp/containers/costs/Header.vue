<template>
  <div class="pure-g gutters m_b_4">
    <p style="">{{ titleHeader }}</p>
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

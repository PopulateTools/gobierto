<template>
  <div class="block">
    <div class="pure-g header_block_inline">
      <div class="pure-u-1 pure-u-md-12-24">
        <div class="inline_header">
          <h2 class="with_description p_h_r_1">
            {{ labelVisualizations }}
          </h2>
        </div>
        <p>
          {{ labelTextVisualizations }}
        </p>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "VisualizationsHeader",
  data() {
    return {
      labelVisualizations: I18n.t("gobierto_data.projects.visualizations") || "",
      labelTextVisualizations: I18n.t("gobierto_data.layouts.visualizations") || ""
    }
  },
};
</script>

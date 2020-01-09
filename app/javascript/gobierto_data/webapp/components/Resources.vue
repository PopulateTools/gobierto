<template>
  <div class="gobierto-data-summary-resources">
    <h2 class="gobierto-data-tabs-section-title">
      <i class="fas fa-caret-down" />
      {{ labelResources }}
    </h2>
  </div>
</template>

<script>
export default {
  name: "Resources",
  data() {
    return {
      labelResources: ""
    }
  },
  created() {
    this.labelResources = I18n.t("gobierto_data.projects.resources")
  }
}
</script>

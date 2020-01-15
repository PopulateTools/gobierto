<template>
  <div class="investments--loading">
    <i class="fas fa-spinner fa-spin" /> {{ labelLoading }}
  </div>
</template>

<script>
export default {
  name: "Loading",
  data() {
    return {
      labelLoading: ""
    };
  },
  created() {
    this.labelLoading = I18n.t("gobierto_investments.projects.loading");
  }
};
</script>

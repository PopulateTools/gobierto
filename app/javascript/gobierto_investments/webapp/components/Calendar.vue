<template>
  <div class="investments-home-aside--calendar-button">
    <div>
      <strong>{{ labelDate }}</strong>
      <i class="fas fa-caret-down" />
    </div>
    <small>12 ene 2018 - 13 ene 2018</small>
  </div>
</template>

<script>
export default {
  name: "Calendar",
  data() {
    return {
      labelDate: ""
    }
  },
  created() {
    this.labelDate = I18n.t("gobierto_investments.projects.date")
  }
};
</script>
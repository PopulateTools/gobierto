<template>
  <Button
    :text="labelSaveChart"
    icon="save"
    color="var(--color-base)"
    background="#fff"
    class="gobierto-data-btn-download-data"
    @click.native="saveChart"
  />
</template>
<script>
import Button from "./Button.vue";

export default {
  name: 'SaveChartButton',
  components: {
    Button
  },
  data() {
    return {
      labelSaveChart: "",
    }
  },
  created() {
    this.labelSaveChart = I18n.t("gobierto_data.projects.save")
  },
  methods: {
    saveChart() {
      this.$root.$emit("exportPerspectiveConfig");
    }
  }
}
</script>

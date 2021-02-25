<template>
  <div class="investments-home-main--button-container">
    <button
      ref="button"
      class="investments-home-main--button"
      @click="showAll"
    >
      {{ isShowingAll ? labelShowLess : labelShowAll }}
    </button>
  </div>
</template>

<script>
export default {
  name: "ShowMore",
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      labelShowAll: "",
      labelShowLess: "",
      isShowingAll: this.show
    };
  },
  created() {
    this.labelShowAll = I18n.t("gobierto_investments.projects.showall");
    this.labelShowLess = I18n.t("gobierto_investments.projects.showless");

    this.$emit("show-all", this.isShowingAll);
  },
  methods: {
    showAll() {
      this.isShowingAll = !this.isShowingAll;
      this.$emit("show-all", this.isShowingAll);

      if (!this.isShowingAll) {
        const { top } = this.$refs.button.getBoundingClientRect();
        window.scrollTo({ top, behavior: 'smooth' });
      }
    }
  }
};
</script>

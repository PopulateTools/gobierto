<template>
  <div class="gobierto-filter-block-header">
    <strong class="gobierto-filter-block-header--title">
      <i
        class="fas fa-caret-down gobierto-filter-block-header--icon"
        style="color: var(--color-base);"
        @click="toggle"
      />
      {{ title }}</strong>
    <a
      v-if="seeLink"
      class="gobierto-filter-block-header--link"
      @click="selectAll"
    >{{
      labelAlt ? labelNone : labelAll
    }}</a>
  </div>
</template>

<script>
export default {
  name: "BlockHeader",
  props: {
    title: {
      type: String,
      default: ""
    },
    seeLink: {
      type: Boolean,
      default: false
    },
    labelAlt: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      labelAll: "",
      labelNone: ""
    };
  },
  created() {
    this.labelAll = I18n.t("gobierto_common.vue_components.block_header.all");
    this.labelNone = I18n.t("gobierto_common.vue_components.block_header.none");
  },
  methods: {
    selectAll() {
      this.$emit("select-all");
    },
    toggle() {
      this.$emit("toggle");
    }
  }
};
</script>

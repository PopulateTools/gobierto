<template>
  <div>
    <strong>{{ title }}</strong>
    <a
      v-if="seeLink"
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
    }
  }
};
</script>

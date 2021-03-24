<template>
  <div class="gobierto-block-header">
    <strong class="gobierto-block-header--title">
      <i
        :class="rotate ? '' : 'rotate-caret'"
        class="fas fa-caret-down gobierto-block-header--icon"
        @click="toggle"
      />
      {{ title }}</strong>
    <button
      v-if="seeLink"
      tabindex="0"
      class="gobierto-block-header--link"
      @click.stop="selectAll"
    >
      {{ labelAlt ? labelNone : labelAll }}
    </button>
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
    },
    rotate: {
      type: Boolean,
      default: false
    },
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

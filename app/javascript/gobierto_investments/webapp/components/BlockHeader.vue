<template>
  <div class="investments-home-aside--block-header">
    <strong>{{ title }}</strong>
    <a
      v-if="seeLink"
      @click="selectAll"
    >{{ labelAlt ? labelNone : labelAll }}</a>
  </div>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "BlockHeader",
  mixins: [CommonsMixin],
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
    }
  },
  created() {
    this.labelAll = I18n.t("gobierto_investments.projects.all")
    this.labelNone = I18n.t("gobierto_investments.projects.none")
  },
  methods: {
    selectAll() {
      this.$emit('select-all')
    }
  }
};
</script>
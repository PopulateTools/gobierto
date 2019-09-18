<template>
  <div class="investments-home-aside--block-header">
    <strong>{{ title | translate }}</strong>
    <a
      v-if="seeLink"
      @click="selectAll"
    >{{ labelAll }}</a>
  </div>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "BlockHeader",
  mixins: [CommonsMixin],
  props: {
    title: {
      type: Object,
      default: () => {}
    },
    seeLink: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      labelAll: ""
    }
  },
  created() {
    this.labelAll = I18n.t("gobierto_investments.projects.all")
  },
  methods: {
    selectAll() {
      this.$emit('select-all')
    }
  }
};
</script>
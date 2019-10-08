<template>
  <div class="investments-home-aside--checkbox">
    <input
      :id="`investments-home-aside--checkbox-${id}`"
      :checked="checked"
      type="checkbox"
      @change="marked = !marked"
    >
    <label :for="`investments-home-aside--checkbox-${id}`">{{ title | translate }}</label>
  </div>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "Checkbox",
  mixins: [CommonsMixin],
  props: {
    title: {
      type: Object,
      default: () => {}
    },
    id: {
      type: Number,
      default: 0
    },
    checked: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      marked: false
    }
  },
  watch: {
    marked(newVal) {
      this.$emit("checkbox-change", this.id, newVal)
    },
  }
};
</script>
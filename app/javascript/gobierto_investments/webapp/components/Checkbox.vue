<template>
  <div class="investments-home-aside--checkbox">
    <input
      :id="`investments-home-aside--checkbox-${id}`"
      :checked="checked"
      type="checkbox"
      @change="marked = !marked"
    >
    <label
      :for="`investments-home-aside--checkbox-${id}`"
    >
      <div>
        {{ title }}
        <i>({{ counter }})</i>
      </div>
    </label>
  </div>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "Checkbox",
  mixins: [CommonsMixin],
  props: {
    title: {
      type: String,
      default: ""
    },
    id: {
      type: Number,
      default: 0
    },
    checked: {
      type: Boolean,
      default: false
    },
    counter: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      marked: false
    }
  },
  watch: {
    marked(value) {
      this.$emit("checkbox-change", { id: this.id, value })
    },
  }
};
</script>
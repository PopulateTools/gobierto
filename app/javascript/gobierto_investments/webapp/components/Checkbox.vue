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
import { GobiertoInvestmentsSharedMixin } from "../mixins/common.js";

export default {
  name: "Checkbox",
  mixins: [GobiertoInvestmentsSharedMixin],
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
    marked(newVal) {
      this.$emit("checkbox-change", this.id, newVal)
    },
  }
};
</script>
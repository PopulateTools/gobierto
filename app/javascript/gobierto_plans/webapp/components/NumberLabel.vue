<template>
  <div>
    {{ length }} {{ label | translate }}
  </div>
</template>

<script>
import { translate } from "lib/shared";
import { PlansStore } from "../lib/store";

export default {
  name: "NumberLabel",
  filters: {
    translate
  },
  props: {
    length: {
      type: Number,
      default: null
    },
    level: {
      type: Number,
      default: 0
    }
  },
  computed: {
    label() {
      return this.getLabel(this.level, this.length)
    }
  },
  methods: {
    getLabel(level, number_of_elements) {
      const KEYS = PlansStore.state.levelKeys
      const key = KEYS[`level${level}`];
      return number_of_elements === 1 ? key["one"] : key["other"];
    }
  }
};
</script>

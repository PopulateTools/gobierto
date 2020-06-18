<template>
  <!-- TODO: tratar de convertir en computed -->
  <div>
    {{ length }} {{ label | translate }}
  </div>
</template>

<script>
import { translate } from "lib/shared";

export default {
  name: "NumberLabel",
  filters: {
    translate
  },
  props: {
    keys: {
      type: Object,
      default: () => {}
    },
    length: {
      type: Number,
      default: 0
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
      const l = Object.keys(this.keys).length === level + 1 ? level : level + 1;
      const key = this.keys[`level${l}`];
      return number_of_elements === 1 ? key["one"] : key["other"];
    }
  }
};
</script>

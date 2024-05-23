<template>
  <div>
    {{ length }} {{ label | translate }}
  </div>
</template>

<script>
import { translate } from '../../../lib/vue/filters';
import { NamesMixin } from '../lib/mixins/names';

export default {
  name: "NumberLabel",
  filters: {
    translate
  },
  mixins: [NamesMixin],
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
  }
};
</script>

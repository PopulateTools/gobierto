<template>
  <div>
    <div
      v-for="{ id, name } in selections"
      :key="id"
    >
      {{ name | translate }}
    </div>
  </div>
</template>

<script>
import { translate } from '../../../lib/vue/filters';

export default {
  name: "CustomFieldSelection",
  filters: {
    translate
  },
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      selections: []
    };
  },
  created() {
    const { value, options } = this.attributes;

    if (value) {
      const elements = Array.isArray(value) ? value : [value]

      this.selections = elements.reduce((acc, item) => {
        if (Object.keys(options).includes(item)) {
          acc.push({ id: item, name: options[item] })
        }
        return acc
      }, []).sort((a, b) => a.name > b.name)
    }
  }
};
</script>

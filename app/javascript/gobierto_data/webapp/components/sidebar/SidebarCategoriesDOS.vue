<template>
  <div class="pure-u-1 pure-u-lg-4-4">
    <Filters
      v-if="items.length"
      :data="items"
      :fields="fields"
      :metadata="metadata"
      :stats="stats"
      @update="handleUpdate"
    />
  </div>
</template>
<script>
import { Filters } from "lib/vue/components";

export default {
  name: "SidebarCategoriesDOS",
  components: {
    Filters
  },
  props: {
    fields: {
      type: Array,
      default: () => []
    },
    items: {
      type: Array,
      default: () => []
    },
    metadata: {
      type: Array,
      default: () => [],
    },
    stats: {
      type: Object,
      default: () => {},
    },
  },
  methods: {
    handleUpdate(items) {
      this.$emit("update", items)
    }
  }
};
</script>

<template>
  <div
    class="pure-u-1 pure-u-lg-4-4"
    @click="handleClick"
  >
    <Filters
      v-if="items.length"
      :data="items"
      :fields="fields"
      :metadata="metadata"
      :stats="stats"
      :no-empty-options="true"
      @update="handleUpdate"
    />
  </div>
</template>
<script>
import { Filters } from "lib/vue/components";
import { ROUTE_NAMES } from "../../../lib/router";

export default {
  name: "SidebarCategories",
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
      default: () => []
    },
    stats: {
      type: Object,
      default: () => {}
    }
  },
  methods: {
    handleUpdate(items) {
      this.$emit("update", items);
    },
    handleClick() {
      if (this.$route.name !== ROUTE_NAMES.Index) {
        this.$router.push({ name: ROUTE_NAMES.Index });
      }
    }
  }
};
</script>

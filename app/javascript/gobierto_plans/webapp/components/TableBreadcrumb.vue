<template>
  <div class="planification-table__breadcrumb">
    <span class="planification-table__breadcrumb-group">
      {{ uid }}
    </span>
    <i class="planification-table__breadcrumb-arrow fas fa-arrow-right" />
    <router-link
      :to="{ name: 'table', params: { ...params } }"
      class="planification-table__breadcrumb-term"
    >
      <span>{{ termId }}</span>
      <i class="planification-table__breadcrumb-times fas fa-times" />
    </router-link>
  </div>
</template>

<script>
import { NamesMixin } from "../lib/mixins/names";

export default {
  name: "TableBreadcrumb",
  mixins: [NamesMixin],
  props: {
    groups: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      uid: null,
      termId: null
    }
  },
  computed: {
    params() {
      return this.$route.params;
    },
  },
  created() {
    const { id, term } = this.$route.params;
    const { name } = this.groups.find(({ slug }) => slug === term);

    this.termId = name;
    this.uid = this.getName(id);
  }
}
</script>
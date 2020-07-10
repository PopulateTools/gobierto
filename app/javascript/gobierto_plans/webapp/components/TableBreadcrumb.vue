<template>
  <div class="planification-table__breadcrumb">
    <router-link :to="{ name: 'table', params: { ...params } }">
      <span class="planification-table__breadcrumb-group">
        {{ uid }}
      </span>
    </router-link>
    <i class="planification-table__breadcrumb-arrow fas fa-arrow-right" />
    <span class="planification-table__breadcrumb-term">
      {{ termId }}
    </span>
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
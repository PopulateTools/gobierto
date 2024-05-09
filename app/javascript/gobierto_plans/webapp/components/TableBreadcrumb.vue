<template>
  <div class="planification-table__breadcrumb">
    <router-link :to="{ name: routes.TABLE, params: { ...params } }">
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
import { NamesMixin } from '../lib/mixins/names';
import { routes } from '../lib/router';

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
    routes() {
      return routes
    },
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

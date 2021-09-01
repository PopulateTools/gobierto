<template>
  <div class="planification-table__li--content">
    <div
      class="planification-table__td"
      :style="tdFirstChildWidth"
    >
      <div
        class="planification-table__td-link"
        @click="showNestedGroups"
      >
        <i :class="['fas', nestedGroups.length ? `fa-caret-${isOpen ? 'down' : 'right'}` : '']" />
        <router-link
          :to="{ name: routes.TERM, params: { ...params, term: slug } }"
        >
          {{ name }}
        </router-link>
      </div>
    </div>
    <template v-if="isStatus">
      <div class="planification-table__td">
        {{ percentOutOfTotal | percent }}
      </div>
    </template>
    <template v-else>
      <div class="planification-table__td">
        {{ progress | percent }}
      </div>
    </template>
    <div class="planification-table__td">
      {{ length }}
    </div>
  </div>
</template>

<script>
import { percent } from "lib/vue/filters";
import { routes } from "../lib/router";

export default {
  name: "GroupsByTermTableRow",
  filters: {
    percent
  },
  props: {
    isOpen: {
      type: Boolean,
      default: false
    },
    term: {
      type: Object,
      default: () => []
    },
  },
  data() {
    return {
      name: '',
      slug: null,
      progress: 0,
      length: 0,
      level: 0,
      nestedGroups: [],
      percentOutOfTotal: 0
    }
  },
  computed: {
    routes() {
      return routes
    },
    params() {
      return this.$route.params;
    },
    isStatus() {
      const { id } = this.$route.params;
      return id === "status"
    },
    tdFirstChildWidth() {
      return `flex: 0 0 calc(50% - ${this.level / 2}rem)`
    }
  },
  created() {
    const { key, name, slug, progress, length, level, nestedGroups, percentOutOfTotal } = this.term
    this.key = key
    this.name = name
    this.slug = slug
    this.progress = progress
    this.length = length
    this.level = level
    this.nestedGroups = nestedGroups
    this.percentOutOfTotal = percentOutOfTotal
  },
  methods: {
    showNestedGroups() {
      this.$emit('show-nested-groups', this.key)
    }
  }
};
</script>

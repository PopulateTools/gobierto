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
          :to="{ name: 'term', params: { ...params, term: slug } }"
        >
          {{ name }}
        </router-link>
      </div>
    </div>
    <div class="planification-table__td">
      {{ progress | percent }}
    </div>
    <div class="planification-table__td">
      {{ length }}
    </div>
  </div>
</template>

<script>
import { percent } from "lib/shared";

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
      nestedGroups: []
    }
  },
  computed: {
    params() {
      return this.$route.params;
    },
    tdFirstChildWidth() {
      return `flex: 0 0 calc(50% - ${this.level / 2}rem)`
    }
  },
  created() {
    const { key, name, slug, progress, length, level, nestedGroups } = this.term
    this.key = key
    this.name = name
    this.slug = slug
    this.progress = progress
    this.length = length
    this.level = level
    this.nestedGroups = nestedGroups
  },
  methods: {
    showNestedGroups() {
      this.$emit('show-nested-groups', this.key)
    }
  }
};
</script>

<template>
  <div class="investments-home-article--item">
    <div
      :class="{ 'is-negative': isNegative }"
      class="investments-home-article--heading p_1"
    >
      <div class="investments-home-article--title">
        {{ title }}
      </div>
      <div>{{ labelProject }}</div>
      <div v-if="budget">
        {{ budget }}
      </div>
    </div>
    <div class="investments-home-article--list">
      <a
        v-for="project in projects"
        :key="project.id"
        class="investments-home-article--list-item"
        @click="nav(project)"
      >{{ project.title }}</a>
    </div>
  </div>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "Phase",
  mixins: [CommonsMixin],
  props: {
    title: {
      type: String,
      default: ""
    },
    count: {
      type: Number,
      default: 0
    },
    budget: {
      type: Number,
      default: 0
    },
    projects: {
      type: Array,
      default: () => {}
    },
    isNegative: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      labelProject: I18n.t("gobierto_investments.projects.project", { count: this.count })
    }
  }
};
</script>


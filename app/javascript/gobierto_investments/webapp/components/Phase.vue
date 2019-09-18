<template>
  <div class="investments-home-article--item">
    <div
      class="investments-home-article--heading p_1"
      :class="{ 'is-negative': isNegative }"
    >
      <div class="investments-home-article--title">
        {{ title }}
      </div>
      <div>{{ count }} proyectos</div>
      <div v-if="budget">
        {{ budget }}
      </div>
    </div>
    <div class="investments-home-article--list">
      <a
        v-for="project in projects"
        :key="project.id"
        class="investments-home-article--list-item"
        @click="nav(project.id)"
      >{{ project.title | translate }}</a>
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
};
</script>


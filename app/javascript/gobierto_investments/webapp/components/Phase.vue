<template>
  <div class="investments-home-article--item">
    <div
      :class="{ 'is-negative': isNegative }"
      class="investments-home-article--heading p_1"
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
        @click="nav(project)"
      >{{ project.title }}</a>
    </div>
  </div>
</template>

<script>
import { GobiertoInvestmentsSharedMixin } from "../mixins/common.js";

export default {
  name: "Phase",
  mixins: [GobiertoInvestmentsSharedMixin],
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


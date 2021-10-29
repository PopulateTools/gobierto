<template>
  <div
    class="node-root"
    :class="classes"
  >
    <a @click="open">
      <div class="node-img">
        <img
          v-if="image"
          :src="image"
        >
      </div>
      <div class="node-info">
        <div
          class="info-progress progress"
          :style="{ width: progressWidth }"
        />
        <div class="info-content">
          <h3
            class="counter"
            :class="{ 'hide-counter': hideCounter }"
          >
            {{ title }}
          </h3>
          <span>{{ progress | percent }}</span>
        </div>
      </div>
    </a>
  </div>
</template>

<script>
import { percent } from "lib/vue/filters"
import { routes } from "../lib/router";

export default {
  name: "NodeRoot",
  filters: {
    percent
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    classes: {
      type: Array,
      default: () => []
    },
    options: {
      type: Object,
      default: () => {}
    },
  },
  data() {
    return {
      image: null,
      title: '',
      progress: 0
    }
  },
  computed: {
    progressWidth() {
      return `${this.progress}%`;
    }
  },
  created() {
    const { attributes: { name } = {}, progress } = this.model
    const { logo, hideCounter } = this.options

    this.image = logo
    this.progress = progress
    this.title = name
    this.hideCounter = hideCounter
  },
  methods: {
    open() {
      this.$emit("open-menu-mobile");
      this.$router.push({ name: routes.CATEGORIES, params: { ...this.$route.params, id: this.model.id } })
    }
  }
};
</script>

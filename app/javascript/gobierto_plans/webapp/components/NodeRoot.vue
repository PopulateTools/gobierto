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
          <h3 class="counter">
            {{ title }}
          </h3>
          <span>{{ progress | percent }}</span>
        </div>
      </div>
    </a>
  </div>
</template>

<script>
import { percent } from "lib/shared"

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
    const { logo } = this.options

    this.image = logo
    this.progress = progress
    this.title = name
  },
  methods: {
    open() {
      this.$emit("open-menu-mobile");
      this.$router.push({ path: `${this.$root.$data.baseurl}/categoria/${this.model.id}` })
    }
  }
};
</script>

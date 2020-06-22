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
          <h3 :class="{ counter }">
            {{ title | translate }}
          </h3>
          <span>{{ progress | percent }}</span>
        </div>
      </div>
    </a>
  </div>
</template>

<script>
import { percent, translate } from "lib/shared"

export default {
  name: "NodeRoot",
  filters: {
    percent,
    translate
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
  },
  data() {
    return {
      image: null,
      counter: 0,
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
    const { attributes: { img, progress, counter, title } = {} } = this.model

    this.image = img
    this.progress = progress
    this.counter = counter
    this.title = title
  },
  methods: {
    open() {
      this.$emit("open-menu-mobile");
      this.$router.push({ name: 'categories', params: { ...this.$route.params, id: this.model.id } })
    }
  }
};
</script>

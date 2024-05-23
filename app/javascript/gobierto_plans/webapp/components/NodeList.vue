<template>
  <div class="node-list">
    <div
      class="node-title"
      @click="setActive"
    >
      <div>
        <i
          class="fa cursor-pointer"
          :class="[isOpen ? 'fa-caret-down' : 'fa-caret-right']"
        />
      </div>
      <h3>
        <a>{{ title }}</a>
      </h3>
    </div>
    <div class="flex-basis-20">
      <slot />
    </div>
    <div class="flex-basis-10">
      {{ progress | percent }}
    </div>
  </div>
</template>

<script>
import { percent } from '../../../lib/vue/filters';
import { PlansFactoryMixin } from '../lib/factory';
import { routes } from '../lib/router';

export default {
  name: "NodeList",
  filters: {
    percent
  },
  mixins: [PlansFactoryMixin],
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    maxCategoryLevel: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      isOpen: false,
      title: "",
      progress: 0
    };
  },
  created() {
    const { attributes: { name } = {}, progress } = this.model;

    this.progress = progress;
    this.title = name;
  },
  methods: {
    setActive() {
      const { id, level } = this.model;

      if (level !== this.maxCategoryLevel) {
        this.$router.push({ name: routes.CATEGORIES, params: { ...this.$route.params, id } })
      } else {
        this.$emit("toggle");
        this.isOpen = !this.isOpen;
      }
    }
  }
};
</script>

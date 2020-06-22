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
        <a>{{ title | translate }}</a>
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
import Vue from "vue";
import { percent, translate } from "lib/shared";
import { PlansFactoryMixin } from "../../lib/factory";

export default {
  name: "NodeList",
  filters: {
    percent,
    translate
  },
  mixins: [PlansFactoryMixin],
  props: {
    model: {
      type: Object,
      default: () => {}
    }
  },
  data: function() {
    return {
      isOpen: false,
      title: "",
      progress: 0
    };
  },
  created() {
    const { attributes: { progress, title } = {} } = this.model;

    this.progress = progress;
    this.title = title;
  },
  methods: {
    async setActive() {
      const {
        id,
        type,
        max_level,
        children = [],
        attributes: { children_count, nodes_list_path }
      } = this.model;

      if (type === "category" && !max_level) {
        this.$router.push({
          name: "categories",
          params: { ...this.$route.params, id }
        });
      } else {
        this.$emit("toggle");
        this.isOpen = !this.isOpen;

        if (children.length === 0 && children_count > 0) {
          const { data } = await this.getProjects(nodes_list_path);
          Vue.set(this.model, "children", data);
        }
      }
    }
  }
};
</script>

<template>
  <div class="node-list">
    <div
      class="node-title"
      @click.stop="setActive"
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
import Vue from 'vue'
import { percent, translate } from "lib/shared";

export default {
  name: "NodeList",
  filters: {
    percent,
    translate
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    }
  },
  data: function() {
    return {
      isOpen: false,
      title: '',
      progress: 0,
      childrenCount: 0,
    };
  },
  created() {
    const { attributes: { progress, title, children_count } = {} } = this.model

    this.progress = progress
    this.title = title
    this.childrenCount = children_count
  },
  methods: {
    // REVIEW: falta refactor
    setActive() {
      if (this.model.type === "category" && !this.model.max_level) {
        var model = { ...this.model };

        this.$emit("selection", model);
      }

      if (this.model.type === "category" && this.model.max_level) {
        let query_params = window.location.search.substring(0);
        if (
          (this.model.children || []).length == 0 &&
          this.model.attributes.children_count > 0
        ) {
          fetch(`${this.model.attributes.nodes_list_path}${query_params}`).then(
            response =>
              response.json().then(json => {
                Vue.set(this.model, "children", json);
                this.$emit("toggle");
                this.isOpen = !this.isOpen;
              })
          );
        } else {
          this.$emit("toggle");
          this.isOpen = !this.isOpen;
        }
      }
    }
  }
};
</script>

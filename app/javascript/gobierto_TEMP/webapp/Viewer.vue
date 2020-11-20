<template>
  <GridLayout
    :layout.sync="layout"
    :col-num="columns"
    :row-height="itemHeight"
    :margin="margin"
    :is-draggable="isDraggable"
    :is-resizable="isResizable"
    :auto-size="true"
    :use-css-transforms="true"
    :prevent-collision="true"
    :style="adjustMargins"
    class="dashboards-viewer"
  >
    <GridItem
      v-for="{ x, y, w, h, i, template } in layout"
      :key="`${Math.random()}-${i}`"
      :x="x"
      :y="y"
      :w="w"
      :h="h"
      :i="i"
      @move="moveEvent"
    >
      <component :is="template" />
    </GridItem>
  </GridLayout>
</template>

<script>
// add the styles here, because this element can be inserted both as a component or standalone
import "../../../assets/stylesheets/module-TEMP-viewer.scss";
import { GridLayout, GridItem } from "vue-grid-layout";
// import { Widgets } from "./lib/widgets";

export default {
  name: "Viewer",
  components: {
    GridLayout,
    GridItem
  },
  props: {
    itemDragged: {
      type: Object,
      default: () => {}
    },
    isDraggable: {
      type: Boolean,
      default: true
      // default: false
    },
    isResizable: {
      type: Boolean,
      default: true
      // default: false
    }
  },
  data() {
    return {
      columns: 12,
      itemHeight: 30,
      margin: [10, 10],
      emptyLayout: [ ]
    };
  },
  computed: {
    layout() {
      const layout = [...this.emptyLayout];
      if (this.itemDragged) {
        const { i } = this.itemDragged;
        if (!layout.some(d => d.i === i)) {
          layout.push({ x: 0, y: 0, ...this.itemDragged });
        }
      }
      return layout;
    },
    adjustMargins() {
      const [x, y] = this.margin;
      return {
        marginTop: `${-y}px`,
        marginBottom: `${-y}px`,
        marginLeft: `${-x}px`,
        marginRight: `${-x}px`
      };
    }
  },
  methods: {
    moveEvent(i, newX, newY) {
        console.log("MOVE i=" + i + ", X=" + newX + ", Y=" + newY);
    },
  }
};
</script>

<style scoped>
.vue-grid-layout {
  background: #eee;
}

.vue-grid-item:not(.vue-grid-placeholder) {
    background: #ccc;
}
</style>

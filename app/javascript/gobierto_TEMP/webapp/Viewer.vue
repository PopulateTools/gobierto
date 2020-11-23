<template>
  <GridLayout
    :layout.sync="widgets"
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
      v-for="{ i, x, y, w, h, template, attributes } in widgets"
      :key="i"
      :x="x"
      :y="y"
      :w="w"
      :h="h"
      :i="i"
      @move="moveEvent"
    >
      <component
        :is="template"
        v-bind="attributes"
      />
    </GridItem>
  </GridLayout>
</template>

<script>
// add the styles here, because this element can be inserted both as a component or standalone
import "../../../assets/stylesheets/module-TEMP-viewer.scss";
import { GridLayout, GridItem } from "vue-grid-layout";
import { Widgets } from "./lib/widgets";
import { DashboardFactoryMixin } from "./lib/factories";

export default {
  name: "Viewer",
  components: {
    GridLayout,
    GridItem
  },
  mixins: [DashboardFactoryMixin],
  props: {
    item: {
      type: Object,
      default: () => {}
    },
    config: {
      type: Object,
      default: () => {}
    },
    isDraggable: {
      type: Boolean,
      default: false
    },
    isResizable: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      columns: 12,
      itemHeight: 30,
      margin: [10, 10],
      widgets: []
    };
  },
  computed: {
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
  watch: {
    item(newItem) {
      if (newItem) {
        const { i } = newItem
        if (!this.widgets.some(d => d.i === i)) {
          this.widgets.push({ x: 0, y: 0, ...newItem });
        }
      }
    }
  },
  async mounted() {
    this.getConfiguration();
  },
  methods: {
    async getConfiguration() {
      const {
        data: {
          attributes: { widget_configuration } = {}
        } = {}
      } = this.config || await this.getDashboard(0); // TODO: el ID se define en la vista?
      this.widgets = this.parseWidgets(widget_configuration);
    },
    parseWidgets(conf = []) {
      return conf.map(({ id, type, layout, ...options }) => {
        const match = Widgets[type];
        if (!match) throw new Error("Widget does not exist");

        // Once we have a matched widget, we flat all necessary properties
        const { layout: defaultLayout, ...widgetCommons } = match;
        return {
          ...widgetCommons,
          ...defaultLayout,
          ...layout,
          ...options,
          i: id
        };
      });
    },
    moveEvent() {}
  }
};
</script>

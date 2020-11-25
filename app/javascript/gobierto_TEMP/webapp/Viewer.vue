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
    :prevent-collision="false"
    :style="adjustMargins"
    class="dashboards-viewer"
    @layout-updated="handleLayoutUpdate"
    @layout-ready="handleLayoutReady"
  >
    <Widget
      v-for="widget in widgets"
      :key="widget.i"
      :edition-mode="isEditionMode"
      v-bind="widget"
      @delete="handleWidgetDelete"
    />
  </GridLayout>
</template>

<script>
// add the styles here, because this element can be inserted both as a component or standalone
import "../../../assets/stylesheets/module-TEMP-viewer.scss";
import { GridLayout } from "vue-grid-layout";
import { Widgets } from "./lib/widgets";
import { DashboardFactoryMixin } from "./lib/factories";
import Widget from "./components/Widget"

export default {
  name: "Viewer",
  components: {
    GridLayout,
    Widget
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
    isEditionMode() {
      // if there's config prop, it comes from Maker
      return !!this.config
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
          edition: false,
          i: id
        };
      });
    },
    handleWidgetDelete(i) {
      this.widgets.splice(this.widgets.findIndex(d => d.i === i), 1)
    },
    handleLayoutUpdate(layout) {
      if (this.isEditionMode) {
        this.$emit('layout-updated', layout)
      }
    },
    handleLayoutReady(layout) {
      if (this.isEditionMode) {
        this.$emit('layout-ready', layout)
      }
    }
  }
};
</script>

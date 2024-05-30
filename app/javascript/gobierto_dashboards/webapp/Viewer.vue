<template>
  <GridLayout
    v-if="widgets.length"
    ref="grid"
    class="dashboards-viewer"
    :layout.sync="widgets"
    :col-num="columns"
    :row-height="itemHeight"
    :margin="margin"
    :is-draggable="isEditionMode"
    :is-resizable="isEditionMode"
    :auto-size="true"
    :use-css-transforms="true"
    :prevent-collision="false"
    :style="adjustMargins"
    @layout-updated="handleLayoutUpdate"
    @layout-ready="handleLayoutReady"
  >
    <Widget
      v-for="widget in widgets"
      ref="widget"
      :key="widget.i"
      :edition-mode="isEditionMode"
      v-bind="{ ...widget, widgetsData }"
      @change="handleWidgetChange"
      @delete="handleWidgetDelete"
    />
  </GridLayout>
</template>

<script>
import { GridLayout } from 'vue-grid-layout';
import { Widgets } from './lib/widgets';
import { FactoryMixin } from './lib/factories';
import Widget from './components/Widget.vue';

export default {
  name: "Viewer",
  components: {
    GridLayout,
    Widget
  },
  mixins: [FactoryMixin],
  props: {
    item: {
      type: Object,
      default: () => {}
    },
    config: {
      type: Object,
      default: () => {}
    },
    isEditionMode: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      columns: 12,
      itemHeight: 30,
      margin: [24, 24],
      widgets: [],
      widgetsData: []
    };
  },
  computed: {
    pipe() {
      return this.$root.$data?.pipe;
    },
    context() {
      return this.$root.$data?.context;
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
      // if user drags a new item inside the grid
      if (newItem) {
        const { i } = newItem;
        if (!this.widgets.some(d => d.i === i)) {
          this.widgets.push({ x: 0, y: 0, ...newItem });
        }
      }
    }
  },
  created() {
    this.getConfiguration();
  },
  methods: {
    async getConfiguration() {
      const { attributes: { widgets_configuration } = {} } = this.config;
      const { data: { data: widgets_data } = {} } = await this.getData({
        context: this.context,
        data_pipe: this.pipe
      });

      this.widgetsData = widgets_data;
      this.widgets = this.parseWidgets(widgets_configuration || [], widgets_data || []);
    },
    parseWidgets(conf, data) {
      return conf.map(({ type = "", ...options }) => {
        const defaults = Widgets[type.toUpperCase()];
        if (!defaults) throw new Error("Widget does not exist");

        return {
          ...defaults,
          ...options,
          // if there is a property called indicator, append the data related
          ...(options.indicator && {
            data: data.find(({ id, project }) => `${id}---${project}` === options.indicator)
          }),
          type,
          edition: false
        };
      });
    },
    handleWidgetDelete(i) {
      this.widgets.splice(
        this.widgets.findIndex(d => d.i === i),
        1
      );
    },
    handleWidgetChange(i, value) {
      const ix = this.widgets.findIndex(d => d.i === i);
      this.widgets[ix] = { ...this.widgets[ix], ...value };
      this.widgets.splice(ix, 1, this.widgets[ix]);
    },
    handleLayoutUpdate(layout) {
      if (this.isEditionMode) {
        this.$emit("layout-updated", layout);
      }
    },
    handleLayoutReady(layout) {
      if (this.isEditionMode) {
        this.$emit("layout-ready", layout);
      }
    }
  }
};
</script>

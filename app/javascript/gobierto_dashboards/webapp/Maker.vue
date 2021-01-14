<template>
  <div class="dashboards-maker">
    <HeaderForm
      :is-dirty="dirty"
      :config="configuration"
      @save="handleSave"
      @delete="handleDelete"
      @view="handleView"
    >
      <template #title>
        <TextEditable
          tag="h1"
          :icon="true"
          @input="handleInputTitle"
        >
          {{ title }}
        </TextEditable>
      </template>

      <template #checkbox>
        <label
          class="dashboards-maker--checkbox"
          for="dashboard-status"
        >
          <input
            id="dashboard-status"
            type="checkbox"
            :checked="status"
            @input="handleInputStatus"
          >
          {{ publicLabel }}
        </label>
      </template>
    </HeaderForm>

    <Main>
      <template #aside>
        <Aside>
          <SmallCard
            v-for="({ name }, key) in cards"
            :key="key"
            :name="name()"
            @drag.native="debounce(drag(key, $event), 1000)"
            @dragend.native="dragend"
          />
        </Aside>
      </template>

      <Viewer
        v-if="configuration"
        ref="viewer"
        :is-edition-mode="true"
        :item="item"
        :config="configuration"
        @layout-updated="handleViewerUpdated"
        @layout-ready="handleViewerReady"
      />
    </Main>
  </div>
</template>

<script>
import Viewer from "./Viewer";
import HeaderForm from "./components/HeaderForm";
import Aside from "./layouts/Aside";
import Main from "./layouts/Main";
import SmallCard from "./components/SmallCard";
import { Widgets, RequiredFields } from "./lib/widgets";
import { FactoryMixin } from "./lib/factories";
import { TextEditable } from "lib/vue-components";

export default {
  name: "Maker",
  components: {
    Viewer,
    HeaderForm,
    Main,
    Aside,
    SmallCard,
    TextEditable
  },
  mixins: [FactoryMixin],
  data() {
    return {
      dirty: false,
      cards: Widgets,
      item: null,
      configuration: null,
      viewerLoaded: false,
      publicLabel: I18n.t("gobierto_dashboards.public") || ""
    };
  },
  computed: {
    id() {
      return this.$root.$data?.id;
    },
    previewPath() {
      return this.$root.$data?.previewPath;
    },
    title() {
      return (
        this.configuration?.attributes?.title ||
        I18n.t("gobierto_dashboards.default_title") ||
        ""
      );
    },
    status() {
      return this.configuration?.attributes?.visibility_level === "active";
    }
  },
  created() {
    this.getConfiguration();
  },
  mounted() {
    document.addEventListener("dragover", this.dragoverPosition);
  },
  destroyed() {
    document.removeEventListener("dragover", this.dragoverPosition);
  },
  methods: {
    async getConfiguration() {
      ({ data: { data: this.configuration } = {} } = this.id
        ? await this.getDashboard(this.id)
        : { data: {} });
      this.dirty = false;
    },
    dragoverPosition({ clientX, clientY }) {
      // current mouse position
      this.x = clientX;
      this.y = clientY;
    },
    debounce(func, timeout) {
      let timer = undefined;
      return (...args) => {
        const next = () => func(...args);
        if (timer) {
          clearTimeout(timer);
        }
        timer = setTimeout(next, timeout > 0 ? timeout : 300);
      };
    },
    drag(key) {
      if (!this.item) {
        // If no item, it means a new item is being dragged
        const match = this.cards[key];
        if (match) {
          this.item = {
            i: `${key}-${Math.random()
              .toString(36)
              .substring(7)}`,
            ...match
          };
        }
      } else {
        // If there is item while dragging, you've to update the current positions
        const { i, ix, x: oldX, y: oldY } = this.item;

        // drag events triggers even before this.item has been updated
        if (Number.isInteger(ix)) {
          // https://jbaysolutions.github.io/vue-grid-layout/guide/10-drag-from-outside.html
          // this block has been copied and adapted from the library example (quite a botch)
          const el = this.$refs.viewer.$refs.widget[ix].$refs.item;
          const { top, left } = this.$refs.viewer.$el.getBoundingClientRect();
          el.dragging = { top: this.y - top, left: this.x - left };
          const { x, y } = el.calcXY(this.y - top, this.x - left);
          this.$refs.viewer.$refs.grid.dragEvent("dragstart", i, x, y, 1, 1);

          // finally, update the item after its calculations, if changes
          if (x !== oldX || y !== oldY) {
            this.item = { ...this.item, x, y };
          }
        }
      }
    },
    dragend() {
      const { i, x, y } = this.item;
      this.$refs.viewer.$refs.grid.dragEvent("dragend", i, x, y, 1, 1);
      // once the drag event finishes, nullish the item
      this.item = null;
    },
    setConfiguration(attr, value) {
      if (!this.configuration) this.configuration = {};
      if (!this.configuration.attributes) this.configuration.attributes = {};

      this.configuration.attributes[attr] = value;
      this.dirty = true;
    },
    handleInputStatus({ target }) {
      this.setConfiguration(
        "visibility_level",
        target.checked ? "active" : "draft"
      );
    },
    handleInputTitle(title) {
      this.setConfiguration("title", title);
    },
    handleViewerUpdated(widgets) {
      if (this.viewerLoaded) {
        this.setConfiguration("widgets_configuration", widgets);

        // when dragging an external element to the canvas, this.item will exists
        if (this.item) {
          const ix = widgets.findIndex(d => d.i === this.item.i);
          this.item = { ...this.item, ...widgets[ix], ix };
        }
      }
    },
    handleViewerReady() {
      this.viewerLoaded = true;
    },
    subset(x) {
      // purge those unwanted props
      return Object.keys(x).reduce((acc, key) => { if (RequiredFields.includes(key)) acc[key] = x[key]; return acc }, {})
    },
    handleSave() {
      const widgetsConfigurationReduced = this.configuration?.attributes?.widgets_configuration.map(this.subset)
      const configuration = {
        ...this.configuration,
        attributes: {
          ...this.configuration?.attributes,
          widgets_configuration: widgetsConfigurationReduced
        }
      }

      this.id
        ? this.putDashboard(this.id, configuration)
        : this.postDashboard(configuration);

      this.dirty = false;
    },
    async handleDelete() {
      if (this.id) {
        const { status } = await this.deleteDashboard(this.id);

        // if properly deleted, close the current popup, if exists
        if (status === 204 && window.$ && window.$.magnificPopup) {
          $.magnificPopup.close()
        }
      }
    },
    handleView() {
      if (this.previewPath) {
        // open new location
        window.open(this.previewPath, '_blank');
      }
    }
  }
};
</script>

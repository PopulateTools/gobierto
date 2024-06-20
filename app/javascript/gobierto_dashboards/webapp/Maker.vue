<template>
  <div class="dashboards-maker">
    <HeaderForm
      :is-dirty="dirty"
      :show-view-item="!!previewPath.length"
      :shaking="shaking"
      @save="handleSave"
      @delete="handleDelete"
      @view="handleView"
      @close="handleClose"
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
import { debounce } from '../../lib/shared';
import { TextEditable } from '../../lib/vue/components';
import Viewer from './Viewer.vue';
import HeaderForm from './components/HeaderForm.vue';
import SmallCard from './components/SmallCard.vue';
import Aside from './layouts/Aside.vue';
import Main from './layouts/Main.vue';
import { FactoryMixin } from './lib/factories';
import { RequiredFields, Widgets } from './lib/widgets';

const seed = () =>
  Math.random()
    .toString(36)
    .substring(7);

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
      shaking: false,
      publicLabel: I18n.t("gobierto_dashboards.public") || "",
      deleteDialogLabel: I18n.t("gobierto_dashboards.delete_dialog") || ""
    };
  },
  computed: {
    id() {
      return this.$root.$data?.id;
    },
    previewPath() {
      return this.$root.$data?.previewPath;
    },
    indicator() {
      return this.$root.$data?.indicator;
    },
    indicatorContext() {
      return this.$root.$data?.indicatorContext;
    },
    context() {
      return this.$root.$data?.context;
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

    if (window.$ && window.$.magnificPopup) {
      const self = this;

      // invalidate autoclose stuff for magnificPopup
      $.magnificPopup.instance.st.closeOnContentClick = false
      $.magnificPopup.instance.st.closeOnBgClick = false
      $.magnificPopup.instance.st.enableEscapeKey = false

      // modifiy the original magnificPopup close function
      $.magnificPopup.instance.close = function() {
        if (self.dirty) {
          // if form is dirty, it shakes the button during 1.5s
          self.shaking = true
          setTimeout(() => (self.shaking = false), 1500);
          return;
        }

        window.location.reload()
        $.magnificPopup.proto.close.call(this);
      };
    }
  },
  mounted() {
    document.addEventListener("dragover", this.dragoverPosition);
  },
  unmounted() {
    document.removeEventListener("dragover", this.dragoverPosition);
  },
  methods: {
    debounce, // add external func to the vue-this context
    async getConfiguration() {
      ({ data: { data: this.configuration } = {} } = this.id
        ? await this.getDashboard(this.id)
        : { data: { data: {} } });

      if (this.indicator) {
        // autoloads the indicator provided via props
        this.setConfiguration("widgets_configuration", [
          ...(this.configuration?.attributes?.widgets_configuration || []),
          {
            ...this.cards["INDICATOR"],
            indicator: `${this.indicator}---${this.indicatorContext}`,
            i: `INDICATOR-${seed()}`,
            x: 0,
            y: 0
          }
        ]);
      }

      this.dirty = false;
    },
    dragoverPosition({ clientX, clientY }) {
      // current mouse position
      this.x = clientX;
      this.y = clientY;
    },
    drag(key) {
      if (!this.item) {
        // If no item, it means a new item is being dragged
        const match = this.cards[key];
        if (match) {
          this.item = {
            i: `${key}-${seed()}`,
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
      return Object.keys(x).reduce((acc, key) => {
        if (RequiredFields.includes(key)) acc[key] = x[key];
        return acc;
      }, {});
    },
    handleSave() {
      if (!this.configuration?.attributes?.context) {
        this.setConfiguration("context", this.context);
      }

      if (!this.configuration?.attributes?.title) {
        this.setConfiguration("title", this.title);
      }

      this.setConfiguration(
        "widgets_configuration",
        this.configuration?.attributes?.widgets_configuration?.map(this.subset)
      );

      this.id
        ? this.putDashboard(this.id, this.configuration)
        : this.postDashboard(this.configuration);

      this.dirty = false;
    },
    async handleDelete() {
      if (!confirm(this.deleteDialogLabel)) {
        return;
      }

      if (this.id) {
        const { status } = await this.deleteDashboard(this.id);

        // if properly deleted, close the current popup, if exists
        if (status === 204 && window.$ && window.$.magnificPopup) {
          $.magnificPopup.close();
        }
      }
    },
    handleView() {
      if (this.previewPath) {
        // open new location
        window.open(this.previewPath, "_blank");
      }
    },
    handleClose() {
      if (window.$ && window.$.magnificPopup) {
        $.magnificPopup.proto.close.call(this);
      }
    }
  }
};
</script>

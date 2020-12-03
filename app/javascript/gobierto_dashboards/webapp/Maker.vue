<template>
  <div class="dashboards-maker">
    <HeaderForm
      :is-dirty="dirty"
      :config="configuration"
      @save="handleSave"
      @edit="handleEdit"
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
            :name="name"
            @drag.native="drag(key, $event)"
            @dragend.native="dragend"
          />
        </Aside>
      </template>

      <Viewer
        v-if="configuration"
        ref="viewer"
        :is-draggable="true"
        :is-resizable="true"
        :item="item"
        :config="configuration"
        @layout-updated="handleViewerUpdated"
        @layout-ready="handleViewerReady"
      />
    </Main>
  </div>
</template>

<script>
// add the styles here, because this element can be inserted both as a component or standalone
import "../../../assets/stylesheets/module-dashboards-maker.scss";
import Viewer from "./Viewer";
import HeaderForm from "./components/HeaderForm";
import Aside from "./layouts/Aside";
import Main from "./layouts/Main";
import SmallCard from "./components/SmallCard";
import { Widgets } from "./lib/widgets";
import { DashboardFactoryMixin } from "./lib/factories";
import { TextEditable } from "lib/vue-components";

const loadWidgets = () => import("./lib/widgets")

export default {
  name: "Maker",
  components: {
    Viewer,
    HeaderForm,
    Main,
    Aside,
    SmallCard,
    TextEditable,
  },
  mixins: [DashboardFactoryMixin],
  data() {
    return {
      dirty: false,
      cards: Widgets, // load async
      item: null,
      configuration: null,
      viewerLoaded: false,
      publicLabel: I18n.t("gobierto_dashboards.public") || "",
    };
  },
  computed: {
    id() {
      return this.$root.$data?.id;
    },
    title() {
      return this.configuration?.data?.attributes?.title || I18n.t("gobierto_dashboards.default_title") || "";
    },
    status() {
      return this.configuration?.data?.attributes?.visibility_level === "active";
    },
  },
  created() {
    this.getConfiguration();
  },
  mounted() {
    document.addEventListener('dragover', this.dragoverPosition)
  },
  destroyed() {
    document.removeEventListener('dragover', this.dragoverPosition)
  },
  methods: {
    async getConfiguration() {
      this.configuration = this.id ? await this.getDashboard(this.id) : {};
      this.dirty = false
    },
    dragoverPosition({ clientX, clientY }) {
      this.x = clientX
      this.y = clientY
    },
    drag(key) {
      if (!this.item) {
        const match = this.cards[key];
        if (match) {
          this.item = {
            i: `${key}-${Math.random().toString(36).substring(7)}`,
            ...match
          };
        }
      } else {
//         const ix = this.configuration?.data?.attributes?.widget_configuration?.findIndex(({ i }) => i === this.item.i)
//         const item = this.configuration?.data?.attributes?.widget_configuration[ix]

//         const el = this.$refs.viewer.$children[0].$children[ix]
//         const { top, left } = this.$refs.viewer.$el.getBoundingClientRect()

// console.log(el);
//         // el.dragging = { "top": this.y - top, "left": this.x - left };
//         const { x, y } = el.calcXY(this.y - top, this.x - left);

//         this.$refs.viewer.$children[0].dragEvent('dragstart', item.i, x, y, 1, 1);

//         this.fakeItem = {
//           i: item.i,
//           x,
//           y
//         }
      }
    },
    dragend() {
      // this.$refs.viewer.$children[0].dragEvent('dragend', this.fakeItem.i, this.fakeItem.x, this.fakeItem.y, 1, 1);
      this.item = null;
    },
    setConfiguration(attr, value) {
      if (!this.configuration) this.configuration = {}
      if (!this.configuration.data) this.configuration.data = {}
      if (!this.configuration.data.attributes) this.configuration.data.attributes = {}

      this.configuration.data.attributes[attr] = value
      this.dirty = true
    },
    handleInputStatus({ target }) {
      this.setConfiguration('visibility_level', target.checked ? "active" : "draft")
    },
    handleInputTitle(title) {
      this.setConfiguration('title', title)
    },
    handleViewerUpdated(widgets) {
      if (this.viewerLoaded) {
        this.setConfiguration('widget_configuration', widgets)
      }
    },
    handleViewerReady() {
      this.viewerLoaded = true
    },
    handleSave() {
      this.id
        ? this.putDashboard(this.id, this.configuration)
        : this.postDashboard(this.configuration);
    },
    handleDelete() {
      if (this.id) {
        this.deleteDashboard(this.id);
      }
    },
    handleView() {
      // open new location
    },
    handleEdit() {
      // edit this.configuration attrs
    }
  }
};
</script>

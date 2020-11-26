<template>
  <div class="dashboards-maker">
    <HeaderContent
      :is-dirty="dirty"
      @save="handleSave"
      @edit="handleEdit"
      @delete="handleDelete"
      @view="handleView"
    >
      <TextEditable
        tag="h1"
        :icon="true"
        @input="handleInputTitle"
      >
        {{ title }}
      </TextEditable>
    </HeaderContent>

    <Main>
      <template #aside>
        <Aside>
          <SmallCard
            v-for="({ name }, key) in cards"
            :key="key"
            :name="name"
            @drag.native="drag(key)"
            @dragend.native="dragend"
          />
        </Aside>
      </template>

      <Viewer
        v-if="configuration"
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
import "../../../assets/stylesheets/module-TEMP-maker.scss";
import Viewer from "./Viewer";
import HeaderContent from "./containers/HeaderContent";
import Aside from "./layouts/Aside";
import Main from "./layouts/Main";
import SmallCard from "./components/SmallCard";
import TextEditable from "./components/TextEditable.vue";
import { Widgets } from "./lib/widgets";
import { DashboardFactoryMixin } from "./lib/factories";

export default {
  name: "Maker",
  components: {
    Viewer,
    HeaderContent,
    TextEditable,
    Main,
    Aside,
    SmallCard
  },
  mixins: [DashboardFactoryMixin],
  data() {
    return {
      dirty: false,
      cards: Widgets,
      item: null,
      configuration: null,
      viewerLoaded: false
    };
  },
  computed: {
    id() {
      return this.$root.$data?.id;
    },
    title() {
      return this.configuration?.data?.attributes?.title || "Título del dashboard";
    },
  },
  watch: {
    configuration: {
      deep: true,
      handler(newVal) {
        if (this.viewerLoaded) {
          this.configuration = newVal
          this.dirty = true
        }
      }
    }
  },
  created() {
    this.getConfiguration();
  },
  methods: {
    async getConfiguration() {
      this.configuration = this.id ? await this.getDashboard(this.id) : {};
      this.dirty = false
    },
    drag(key) {
      if (!this.item) {
        const match = Widgets[key];
        if (match) {
          this.item = {
            i: `${match.name.replaceAll(" ", "_")}-${Math.random()
              .toString(36)
              .substring(7)}`,
            template: match.template,
            ...match.layout
          };
        }
      } else {
        // TODO: mover el item
      }
    },
    dragend() {
      this.item = null;
    },
    handleViewerUpdated(widgets) {
      if (this.viewerLoaded) {
        this.configuration.data.attributes.widget_configuration = widgets
      }
    },
    handleViewerReady() {
      this.viewerLoaded = true
    },
    handleInputTitle(title) {
      this.configuration.data.attributes.title = title
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

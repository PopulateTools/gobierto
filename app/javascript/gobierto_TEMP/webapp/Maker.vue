<template>
  <div class="dashboards-maker">
    <HeaderContent :title="title" />
    <Main>
      <template #aside>
        <Aside>
          <SmallCard
            v-for="({ type }, key) in cards"
            :key="key"
            :name="type"
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
import { Widgets } from "./lib/widgets";
import { DashboardFactoryMixin } from "./lib/factories";

export default {
  name: "Maker",
  components: {
    Viewer,
    HeaderContent,
    Main,
    Aside,
    SmallCard
  },
  mixins: [DashboardFactoryMixin],
  data() {
    return {
      cards: Widgets,
      item: null,
      configuration: null,
    };
  },
  computed: {
    title() {
      return this.configuration?.attributes?.title
    }
  },
  created() {
    this.getConfiguration()
  },
  methods: {
    async getConfiguration() {
      const { id } = this.$root.$data;
      this.configuration = (id !== undefined) ? await this.getDashboard(+id) : {}
    },
    drag(key) {
      if (!this.item) {
        const match = Widgets[key]
        if (match) {
          this.item = {
            i: `${match.type.replaceAll(" ", "_")}-${Math.random().toString(36).substring(7)}`,
            template: match.template,
            ...match.layout
          };
        }
      } else {
        // TODO: mover el item
      }
    },
    dragend() {
      this.item = null
    }
  }
};
</script>

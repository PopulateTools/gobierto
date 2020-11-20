<template>
  <div class="dashboards-maker">
    <HeaderContent />
    <Main>
      <template #aside>
        <Aside>
          <SmallCard
            v-for="{ type } in cards"
            :key="type"
            :name="type"
            @drag.native="drag"
          />
        </Aside>
      </template>

      <Viewer
        ref="viewer"
        :is-draggable="true"
        :is-resizable="true"
        :item-dragged="item"
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

export default {
  name: "Maker",
  components: {
    Viewer,
    HeaderContent,
    Main,
    Aside,
    SmallCard
  },
  data() {
    return {
      cards: Widgets,
      item: null
    };
  },
  methods: {
    drag() {
      this.item = {
        i: `${Widgets.HTML.type}-${Math.random().toString(36).substring(7)}`,
        template: Widgets.HTML.template,
        ...Widgets.HTML.layout
      };
    },
  }
};
</script>

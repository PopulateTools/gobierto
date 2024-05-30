<template>
  <div class="dashboards-viewer">
    <transition name="fade">
      <!-- show list if there's more than one -->
      <template v-if="isList">
        <div class="dashboards-viewer__card-grid">
          <ListCard
            v-for="{ id: uid, attributes } in dashboards"
            :key="uid"
            v-bind="attributes"
            @click.native="handleClick(uid)"
          />
        </div>
      </template>
      <!-- display directly the dashboard otherwise -->
      <template v-else-if="currentDashboard">
        <Viewer :config="currentDashboard" />
      </template>
    </transition>
    <span
      v-if="showBackBtn"
      class="dashboards-viewer__button"
      @click="handleClick"
    >
      <i class="fas fa-arrow-left" /> {{ backLabel }}
    </span>
  </div>
</template>

<script>
import Viewer from './Viewer.vue';
import ListCard from './components/ListCard.vue';
import { FactoryMixin } from './lib/factories';
import { GOBIERTO_DASHBOARDS } from '../../lib/events'

export default {
  name: "ViewerManager",
  components: {
    Viewer,
    ListCard
  },
  mixins: [FactoryMixin],
  data() {
    return {
      dashboards: [],
      currentDashboard: null,
      backLabel: I18n.t("gobierto_dashboards.back") || ""
    }
  },
  computed: {
    id() {
      return this.$root.$data?.id;
    },
    pipe() {
      return this.$root.$data?.pipe;
    },
    context() {
      return this.$root.$data?.context;
    },
    isList() {
      return !this.currentDashboard && this.dashboards.length > 1
    },
    showBackBtn() {
      return this.currentDashboard && this.dashboards.length > 1
    }
  },
  async created() {
    // request all dashboards
    ({ data: { data: this.dashboards } = {} } = await this.getDashboards({ context: this.context, data_pipe: this.pipe }))

    if (this.id) {
      this.currentDashboard = this.dashboards.find(({ id }) => +id === +this.id)
    } else if (this.dashboards.length === 1) {
      const [{ id }] = this.dashboards
      this.handleClick(id)
    }

    // Emit to his parent, if there was any
    this.$emit(GOBIERTO_DASHBOARDS.LOADED, this.dashboards)
    // Otherwise, dispatch a general event (CustomEvent in order to send payload)
    const event = new CustomEvent(GOBIERTO_DASHBOARDS.LOADED, { detail: this.dashboards })
    document.dispatchEvent(event)
  },
  methods: {
    handleClick(uid) {
      // if uid is null, no selected dashboard, i.e. show the list
      this.currentDashboard = this.dashboards.find(({ id }) => +id === +uid)

      // Emit to his parent, if there was any
      this.$emit(GOBIERTO_DASHBOARDS.SELECTED, this.currentDashboard)
      // Otherwise, dispatch a general event (CustomEvent in order to send payload)
      const event = new CustomEvent(GOBIERTO_DASHBOARDS.SELECTED, { detail: this.currentDashboard })
      document.dispatchEvent(event)
    }
  }
};
</script>

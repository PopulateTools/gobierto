<template>
  <div>
    <nav
      v-if="displayNavbar"
      class="planification-tabs__container"
    >
      <div class="planification-tabs">
        <router-link
          v-for="(tab, i) in tabs"
          :key="tab.title"
          :to="{ params: { ...$route.params }, ...tab }"
          class="planification-tabs__item"
          :class="{ 'is-active': activeTab === i }"
        >
          {{ tab.title }}
        </router-link>
      </div>
    </nav>

    <template v-for="(_, i) in tabs">
      <slot
        v-if="activeTab === i"
        :name="`tab-${i}`"
      />
    </template>
  </div>
</template>

<script>
export default {
  name: "Tabs",
  props: {
    tabs: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    activeTab() {
      const { name: current, meta: { tab } } = this.$route
      return this.tabs.findIndex(({ name }) => [current, tab].includes(name))
    },
    displayNavbar() {
      return this.tabs.length > 1
    }
  }
};
</script>

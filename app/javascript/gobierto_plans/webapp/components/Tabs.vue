<template>
  <div>
    <nav class="planification-tabs__container">
      <div class="planification-tabs">
        <router-link
          v-for="(tab, i) in tabs"
          :key="tab.title"
          :to="{ params: { ...$route.params }, ...tab }"
          class="planification-tabs__item"
          :class="{ 'is-active': activeTab === i }"
          @click.native="activeTab = i"
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
  data() {
    return {
      activeTab: 0
    }
  }
};
</script>

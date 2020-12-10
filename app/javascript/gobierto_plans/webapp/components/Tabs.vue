<template>
  <div>
    <nav>
      <router-link
        v-for="(tab, i) in tabs"
        :key="tab"
        :to="{}"
        @click.native="activeTab = i"
      >
        {{ tab }}
      </router-link>
    </nav>

    <template v-for="(_ , i) in tabs">
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

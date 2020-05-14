<template>
  <nav class="gobierto-data-home-nav">
    <ul>
      <router-link
        :to="'/datos/'"
        :class="{ 'is-active': activeTab === 0 }"
        class="gobierto-data-home-nav--tab"
      >
        {{ name }}
        <span>{{ labelDatasets }}</span>
      </router-link>
    </ul>
  </nav>
</template>

<script>
// TODO: component UNREVIEWED YET
export default {
  name: "Nav",
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
    labelDatasets: I18n.t("gobierto_data.projects.dataset") || ''
    }
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
};

</script>

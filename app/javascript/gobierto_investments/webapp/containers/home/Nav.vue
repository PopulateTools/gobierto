<template>
  <nav class="investments-home-nav">
    <ul>
      <li
        :class="{ 'is-active': activeTab === 0 }"
        class="investments-home-nav--tab"
        @click="activateTab(0)"
      >
        <i class="fas fa-map" />
        <i class="far fa-map" />
        <span>{{ labelMap }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 1 }"
        class="investments-home-nav--tab"
        @click="activateTab(1)"
      >
        <i class="fas fa-clone" />
        <i class="far fa-clone" />
        <span>{{ labelGallery }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 2 }"
        class="investments-home-nav--tab"
        @click="activateTab(2)"
      >
        <i class="fas fa-list-alt" />
        <i class="far fa-list-alt" />
        <span>{{ labelList }}</span>
      </li>
    </ul>
  </nav>
</template>

<script>
export default {
  name: "HomeNav",
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelMap: "",
      labelGallery: "",
      labelList: "",
    };
  },
  created() {
    this.labelMap = I18n.t("gobierto_investments.projects.map")
    this.labelGallery = I18n.t("gobierto_investments.projects.gallery")
    this.labelList = I18n.t("gobierto_investments.projects.list")
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
};
</script>


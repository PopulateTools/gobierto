<template>
  <nav class="investments-home-nav">
    <ul>
      <!-- <li
        class="investments-home-nav--tab"
        :class="{ 'is-active': isActive === 0 }"
        @click="activateTab(0)"
      >
        <i class="fas fa-map" />
        <i class="far fa-map" />
        <span>{{ labelMap }}</span>
      </li> -->
      <li
        class="investments-home-nav--tab"
        :class="{ 'is-active': isActive === 1 }"
        @click="activateTab(1)"
      >
        <i class="fas fa-clone" />
        <i class="far fa-clone" />
        <span>{{ labelGallery }}</span>
      </li>
      <li
        class="investments-home-nav--tab"
        :class="{ 'is-active': isActive === 2 }"
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
  data() {
    return {
      isActive: 0,
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
      this.isActive = index;
      this.$emit("active-tab", index);
    }
  }
};
</script>


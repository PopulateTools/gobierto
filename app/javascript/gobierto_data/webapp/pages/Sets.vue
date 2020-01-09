<template>
  <div class="pure-g">
    <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
      <p>Sidebar</p>
    </div>
    <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
      <h2 class="gobierto-data-title-dataset">
        {{ titleDataset }}
        <BlueButton>
          <span>{{ labelFav }}</span>
        </BlueButton>
        <BlueButton>
          <span>{{ labelFollow }}</span>
        </BlueButton>
        <NavSets />
      </h2>
    </div>
  </div>
</template>

<script>
import BlueButton from "./../components/BlueButton.vue";
import NavSets from "./../components/NavSets.vue";


export default {
  name: "Sets",
  components: {
    BlueButton,
    NavSets
  },
  data() {
    return {
      activeTabIndex: 0,
      titleDataset: "Actuaciones del Cuerpo de Bomberos",
      labelFav: '',
      labelFollow: ''
    }
  },
  created() {
    this.labelFav = I18n.t("gobierto_data.projects.fav")
    this.labelFollow = I18n.t("gobierto_data.projects.follow")
  },
  methods: {
  }
};
</script>

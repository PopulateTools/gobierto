<template>
  <div class="pure-g">
    <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
      <p>Sidebar</p>
    </div>
    <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
      <div class="pure-g">
        <div class="pure-u-1-2">
          <h2 class="gobierto-data-title-dataset">
            {{ titleDataset }}
          </h2>
        </div>
        <div class="pure-u-1-2 gobierto-data-buttons">
          <BlueButton>
            <i class="fas fa-star" />
            <span>{{ labelFav }}</span>
          </BlueButton>
          <BlueButton>
            <i class="fas fa-bell" />
            <span>{{ labelFollow }}</span>
          </BlueButton>
        </div>
      </div>
      <NavDatasets
        :active-tab="activeTabIndex"
        @active-tab="activeTabIndex = $event"
      />
    </div>
  </div>
</template>

<script>
import BlueButton from "./../components/BlueButton.vue";
import NavDatasets from "./../components/datasets/NavDatasets.vue";


export default {
  name: "Datasets",
  components: {
    BlueButton,
    NavDatasets
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
  }
}
</script>

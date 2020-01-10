<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <div class="pure-g">
      <div class="pure-u-1-2">
        <h2 class="gobierto-data-title-dataset">
          {{ titleDataset }}
        </h2>
      </div>
      <div class="pure-u-1-2 gobierto-data-buttons">
        <Button>
          <i class="fas fa-star" />
          <span>{{ labelFav }}</span>
        </Button>
        <Button>
          <i class="fas fa-bell" />
          <span>{{ labelFollow }}</span>
        </Button>
      </div>
    </div>
    <NavDatasets :active-tab="activeTabIndex" @active-tab="activeTabIndex = $event" />
  </div>
</template>
<script>
import Button from "./../components/commons/Button.vue";
import NavDatasets from "./../components/sets/Nav.vue";


export default {
  name: "Sets",
  components: {
    Button,
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

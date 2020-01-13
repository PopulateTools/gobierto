<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <div style="background-color: rgba(113, 184, 193, .1); color: #71B8C1; height: 40vh; widht: 100%; padding: 1rem; font-weight: bold;">
      Promo - Intro al módulo
    </div>
    <Info />
  </div>
</template>
<script>
import Info from "./../components/commons/Info.vue";
export default {
  name: "Categories",
  components: {
    Info
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

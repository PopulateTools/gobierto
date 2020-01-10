<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <div>Promo - Intro al módulo</div>
  </div>
</template>
<script>

export default {
  name: "Categories",
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

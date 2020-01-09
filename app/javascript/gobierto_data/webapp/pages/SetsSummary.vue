<template>
  <div>

  </div>
</template>

<script>
import BlueButton from "./../components/BlueButton.vue";
import NavSets from "./../components/NavSets.vue";


export default {
  name: "SetsSummary",
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
  }
}
</script>

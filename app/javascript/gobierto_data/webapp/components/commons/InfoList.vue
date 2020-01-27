<template>
  <div>
    <InfoListElement
      v-for="(item, index) in items"
      :key="index"
      :item="item"
      class="gobierto-data-info-list-element"
    />
  </div>
</template>
<script>
import InfoListElement from "./InfoListElement.vue";
export default {
  name: "Info",
  components: {
    InfoListElement
  },
  props: {
    items: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      labelUpdated: '',
      labelFrequency: '',
      labelSubject: '',
      labelDownloadData: '',
      datasetDescription: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
    }
  },
  methods: {
    nav(slugDataset) {
      this.$router.push({ name: "dataset", params: { id: slugDataset } });
    }
  }
}

</script>

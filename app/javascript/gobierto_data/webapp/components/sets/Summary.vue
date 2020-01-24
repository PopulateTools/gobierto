<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Info />
    <DownloadButton
      :class="[
        directionLeft ? 'modal-left': 'modal-right'
      ]"
      class="arrow-top"
      :editor="false"
    />
    <Resources :items="filesDataset" />
    <Queries />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import Queries from "./../commons/Queries.vue";

export default {
  name: "Summary",
  components: {
    Resources,
    Queries,
    DownloadButton,
    Info
  },
  data() {
    return {
      isActive: false,
      labelDownloadData: "",
      directionLeft: true,
      filesDataset: [{
          file: {
            name: 'Actuaciones Bomberos Enero 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Febrero 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Marzo 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Abril 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Mayo 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Junio 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Julio 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Agosto 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Septiembre 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Octubre 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Noviembre 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Diciembre 2019.xls',
            size: '232kb'
          }
        }
      ]
    }
  },
  created() {
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
  }
}

</script>

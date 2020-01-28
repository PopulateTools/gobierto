<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Info />
    <keep-alive>
      <DownloadButton
        :class="[
          directionLeft ? 'modal-left': 'modal-right'
        ]"
        :slug-name="item"
        class="arrow-top"
      />
    </keep-alive>
    <Resources :items="filesDataset" />
    <Queries :array-queries="arrayQueries" />
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
  props: {
    item: {
      type: String,
      required: true
    },
    arrayQueries: {
      type: Array,
      required: true
    }
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
        }
      ]
    }
  },
  created() {
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
  }
}
</script>

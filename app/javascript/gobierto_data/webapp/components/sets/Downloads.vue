<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <keep-alive>
      <DownloadButton
        :class="[
          directionLeft ? 'modal-left': 'modal-right'
        ]"
        :array-formats="arrayFormats"
        class="arrow-top"
      />
    </keep-alive>
    <Resources :items="filesDataset" />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import DownloadButton from "./../commons/DownloadButton.vue";

export default {
  name: "Downloads",
  components: {
    Resources,
    DownloadButton
  },
  props: {
    arrayFormats: {
      type: Object,
      required: true,
      activeTabIndex: 0
    }
  },
  data() {
    return {
      directionLeft: true,
      filesDataset: [{
          file: {
            name: 'Actuaciones Bomberos Enero 2019.xls',
            size: '232kb'
          }
        }
      ]
    }
  }
}
</script>

<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <keep-alive>
      <DownloadButton
        :class="[
          directionLeft ? 'modal-left': 'modal-right'
        ]"
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

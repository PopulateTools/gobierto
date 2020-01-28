<template>
  <div class="gobierto-data-sets-nav--tab-container">
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
    item: {
      type: String,
      required: true
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

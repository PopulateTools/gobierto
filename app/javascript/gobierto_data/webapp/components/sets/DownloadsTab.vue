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
    <Resources :resources-list="resourcesList" />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import DownloadButton from "./../commons/DownloadButton.vue";

export default {
  name: "DownloadsTab",
  components: {
    Resources,
    DownloadButton
  },
  props: {
    arrayFormats: {
      type: Object,
      required: true
    },
    resourcesList: {
      type: Array,
      required: true,
      default: () => []
    }
  },
  data() {
    return {
      directionLeft: true
    }
  }
}
</script>

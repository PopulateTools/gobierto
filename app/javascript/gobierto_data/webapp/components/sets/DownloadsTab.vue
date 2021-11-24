<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <keep-alive>
      <template v-if="moreThanOneFormat">
        <DownloadButton
          :class="[
            directionLeft ? 'modal-left': 'modal-right'
          ]"
          :array-formats="arrayFormats"
          class="arrow-top"
        />
      </template>
      <template v-else>
        <DownloadLink
          :editor="false"
          :array-formats="arrayFormats"
        />
      </template>
    </keep-alive>
    <Resources :resources-list="resourcesList" />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import DownloadLink from "./../commons/DownloadLink.vue";

export default {
  name: "DownloadsTab",
  components: {
    Resources,
    DownloadButton,
    DownloadLink
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
  },
  computed: {
    moreThanOneFormat() {
      return Object.keys(this.arrayFormats).length > 1
    }
  }
}
</script>

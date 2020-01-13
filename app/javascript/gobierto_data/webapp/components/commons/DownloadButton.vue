<template>
  <div class="gobierto-data-container-btn-download-data">
    <Button
      :text="labelDownloadData"
      icon="download"
      color="var(--color-base)"
      background="#fff"
      class="gobierto-data-btn-download-data"
      icon-color="rgba(var(--color-base-string), .2)"
      @click.native="showModalButton"
    />
    <div
      :class="{ 'active': isActive }"
      class="gobierto-data-btn-download-data-modal arrow-top"
    >
      <!-- //TODO ACTIONS -->
      <button class="gobierto-data-btn-download-data-modal-element">
        CSV
      </button>
      <button class="gobierto-data-btn-download-data-modal-element">
        JSON
      </button>
      <button class="gobierto-data-btn-download-data-modal-element">
        XLXS
      </button>
      <button class="gobierto-data-btn-download-data-modal-element">
        OTHER
      </button>
    </div>
  </div>
</template>
<script>

import Button from "./Button.vue";
export default {
  name: 'DownloadButton',
  components: {
    Button
  },
  data() {
    return {
      labelDownloadData: ""
    }
  },
  created() {
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
  }
}

</script>

<template>
  <div
    v-if="!!this.dataDownloadEndpoint"
    class="dashboards-home-aside--download-open-data"
  >
    <i class="fas fa-table"></i>
    <a :href="dataDownloadEndpoint" target="_blank">
      {{ labelDownloadData }}
    </a>
  </div>
</template>

<script>
export default {
  name: 'DownloadButton',
  data() {
    return {
      labelDownloadData: I18n.t('gobierto_dashboards.shared.download_data'),
    }
  },
  props: {
    dataDownloadEndpoint: {
      type: String,
      default: ''
    }
  }
}
</script>

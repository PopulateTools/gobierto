<template>
  <div
    v-if="!!dataDownloadEndpoint"
    class="dashboards-home-aside--download-open-data"
  >
    <i class="fas fa-table" />
    <a
      class="dashboards-home-aside--download-open-data-link"
      :href="dataDownloadEndpoint"
      target="_blank"
    >
      {{ labelDownloadData }}
    </a>
  </div>
</template>

<script>
export default {
  name: 'DownloadButton',
  props: {
    dataDownloadEndpoint: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      labelDownloadData: I18n.t('gobierto_dashboards.shared.download_data'),
    }
  }
}
</script>

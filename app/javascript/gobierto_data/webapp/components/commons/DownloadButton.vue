<template>
  <div class="gobierto-data-container-btn-download-data">
    <Button
      v-clickoutside="closeMenu"
      :text="labelDownloadData"
      icon="download"
      color="var(--color-base)"
      background="#fff"
      class="gobierto-data-btn-download-data"
      @click.native="showModalButton"
    />
    <div
      :class="{ 'active': isActive }"
      class="gobierto-data-btn-download-data-modal"
    >
      <a
        :href="fileCSV"
        class="gobierto-data-btn-download-data-modal-element"
        download="data.csv"
      >
        CSV
      </a>
      <a
        :href="fileJSON"
        class="gobierto-data-btn-download-data-modal-element"
        download="data.json"
      >
        JSON
      </a>
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
  directives: {
    clickoutside: {
      bind: function(el, binding, vnode) {
        el.clickOutsideEvent = function(event) {
          if (!(el == event.target || el.contains(event.target))) {
            vnode.context[binding.expression](event);
          }
        };
        document.body.addEventListener('click', el.clickOutsideEvent)
      },
      unbind: function(el) {
        document.body.removeEventListener('click', el.clickOutsideEvent)
      },
      stopProp(event) { event.stopPropagation() }
    }
  },
  data() {
    return {
      labelDownloadData: "",
      isActive: false,
      dataLink: '',
      fileCSV: '',
      fileJSON: ''
    }
  },
  created() {
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
    this.$root.$on('sendFiles', this.arrayFiles)
  },
  methods: {
    showModalButton() {
      this.isActive = !this.isActive;
    },
    closeMenu() {
      this.isActive = false
    },
    arrayFiles(values) {
      const { 0: fileCSV, 1: fileJSON } = values
      this.fileCSV = fileCSV
      this.fileJSON = fileJSON
    }
  }
}

</script>

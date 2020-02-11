<template>
  <div class="gobierto-data-container-btn-download-data">
    <Button
      v-clickoutside="closeMenu"
      :text="labelDownloadData"
      icon="download"
      color="var(--color-base)"
      background="#fff"
      class="gobierto-data-btn-download-data"
      @click.native="isHidden = !isHidden"
    />
    <transition
      name="fade"
      mode="out-in"
    >
      <div
        v-show="!isHidden"
        class="gobierto-data-btn-download-data-modal"
      >
        <div
          v-for="(item, key, index) in arrayFormats"
          :key="index"
          :item="item"
        >
          <template
            v-for="(item, key, index) in arrayFormats"
          >
            <a
              :key="index"
              :item="item"
              :href="editor ? sqlfileCSV : item"
              :download="titleDataset"
              class="gobierto-data-btn-download-data-modal-element"
            >
              {{ key }}
            </a>
          </template>
        </div>
      </transition>
    </keep-alive>
  </div>
</template>
<script>

import Button from "./Button.vue";
import { baseUrl, CommonsMixin } from "./../../../lib/commons.js";
export default {
  name: 'DownloadButton',
  components: {
    Button
  },
  mixins: [CommonsMixin],
  props: {
    editor: {
      type: Boolean,
      default: false
    },
    arrayFormats: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      labelDownloadData: "",
      code: '',
      isHidden: true,
      dataLink: '',
      fileCSV: '',
      fileXLSX: '',
      fileJSON: '',
      sqlfileCSV: '',
      sqlfileXLSX: '',
      sqlfileJSON: '',
      endPointSQL: '',
      titleDataset: ''
    }
  },
  created() {
    this.$root.$on('sendCode', this.updateCode);
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
    this.endPointSQL = `${baseUrl}/data.csv?sql=`
  },
  methods: {
    closeMenu() {
      this.isHidden = true
    },
    updateCode(sqlQuery) {
      this.code = sqlQuery
      this.sqlfileCSV = `${this.urlPath}${this.endPointSQL}${this.code}&csv_separator=semicolon`
      this.sqlfileXLSX = `${this.urlPath}${this.endPointSQL}${this.code}`
      this.sqlfileJSON = `${this.urlPath}${this.endPointSQL}${this.code}`
    }
  }
}
</script>

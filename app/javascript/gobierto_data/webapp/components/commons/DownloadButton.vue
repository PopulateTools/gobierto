<template>
  <div class="gobierto-data-container-btn-download-data">
    <Button
      v-clickoutside="closeMenu"
      :text="labelDownloadData"
      icon="download"
      color="var(--color-base)"
      background="#fff"
      class="gobierto-data-btn-download-data"
      @click.native="isHidden = !isHidden; getData()"
    />
    <transition
      name="fade"
      mode="out-in"
    >
      <div
        v-show="!isHidden && rawData"
        class="gobierto-data-btn-download-data-modal"
      >
        <div
          v-for="(item, key, index) in links"
          :key="index"
          :item="item"
        >
          <a
            :href="editor ? sqlfileCSV : item"
            :download="titleDataset"
            class="gobierto-data-btn-download-data-modal-element"
          >
            {{ key }}
          </a>
        </div>
      </div>
    </transition>
  </div>
</template>
<script>

import axios from 'axios';
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
    slugName: {
      type: String,
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
      endPoint: '',
      rawData: null,
      slugDataset: '',
      links: [],
      titleDataset: ''
    }
  },
  created() {
    this.$root.$on('sendCode', this.updateCode);
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
    this.endPointSQL = `${baseUrl}/data.csv?sql=`
    this.slugDataset = this.slugName
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
    },
    getData() {
      this.slugDataset = this.slugName
      this.endPoint = `${baseUrl}/datasets/${this.slugDataset}/meta`
      this.url = `${this.endPoint}`

      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.links = this.rawData.data.attributes.formats
          this.titleDataset = this.rawData.data.attributes.name
        })
        .catch(error => {
          console.error(error)
        })
    }
  }
}

</script>

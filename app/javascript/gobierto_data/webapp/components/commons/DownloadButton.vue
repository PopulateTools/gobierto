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
        :href="editor ? sqlfileCSV : fileCSV"
        class="gobierto-data-btn-download-data-modal-element"
        download="data.csv"
      >
        CSV
      </a>
      <a
        :href="editor ? sqlfileJSON : fileJSON"
        class="gobierto-data-btn-download-data-modal-element"
        download="data.json"
      >
        JSON
      </a>
      <a
        :href="editor ? sqlfileXLSX : fileXLSX"
        class="gobierto-data-btn-download-data-modal-element"
        download="data.xlsx"
      >
        XLSX
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
  props: {
    editor: {
      type: Boolean
    }
  },
  data() {
    return {
      labelDownloadData: "",
      code: '',
      isActive: false,
      dataLink: '',
      fileCSV: '',
      fileXLSX: '',
      fileJSON: '',
      sqlfileCSV: '',
      sqlfileXLSX: '',
      sqlfileJSON: '',
      urlPath: location.origin,
      endPoint: ''
    }
  },
  created() {
    this.$root.$on('sendCode', this.updateCode);
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
    this.$root.$on('sendFiles', this.arrayFiles)

    this.urlPath = location.origin
    this.endPoint = '/api/v1/data/datasets/agendas-de-politicos';
    this.fileCSV = `${this.urlPath}${this.endPoint}.csv`
    this.fileJSON = `${this.urlPath}${this.endPoint}`
    this.fileXLSX = `${this.urlPath}${this.endPoint}.xlsx`


  },
  methods: {
    showModalButton() {
      this.isActive = !this.isActive;
    },
    closeMenu() {
      this.isActive = false
    },
    updateCode(sqlQuery) {
      console.log("sqlQuery", sqlQuery);
      this.code = sqlQuery
      this.sqlfileCSV = `${this.fileCSV}?sql=${this.code}&csv_separator=semicolon`
      console.log("this.sqlfileCSV", this.sqlfileCSV);
      this.sqlfileXLSX = `${this.fileJSON}?sql=${this.code}&csv_separator=semicolon`
      console.log("this.sqlfileXLSX", this.sqlfileXLSX);
      this.sqlfileJSON = `${this.fileXLSX}?sql=${this.code}&csv_separator=semicolon`
      console.log("this.sqlfileJSON", this.sqlfileJSON);
    }
  }
}

</script>

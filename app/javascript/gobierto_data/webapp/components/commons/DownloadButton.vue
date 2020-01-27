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
    <keep-alive>
      <transition
        name="fade"
        mode="out-in"
      >
        <div
          v-show="!isHidden"
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
      </transition>
    </keep-alive>
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
      type: Boolean,
      default: false
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
      urlPath: location.origin,
      endPoint: ''
    }
  },
  created() {
    this.$root.$on('sendCode', this.updateCode);
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
    this.urlPath = location.origin
    this.endPoint = '/api/v1/data/datasets/grupost-de-interes'
    this.endPointSQL = '/api/v1/data/data.csv?sql='
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
      this.code = sqlQuery
      this.sqlfileCSV = `${this.urlPath}${this.endPointSQL}${this.code}&csv_separator=semicolon`
      this.sqlfileXLSX = `${this.urlPath}${this.endPointSQL}${this.code}`
      this.sqlfileJSON = `${this.urlPath}${this.endPointSQL}${this.code}`
    }
  }
}

</script>

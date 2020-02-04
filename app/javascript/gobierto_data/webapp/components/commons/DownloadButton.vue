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
      urlPath: location.origin,
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
    this.endPointSQL = '/api/v1/data/data.csv?sql='
    this.slugName = this.$route.params.id
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

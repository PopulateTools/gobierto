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
    >
      <transition
        name="fade"
        mode="out-in"
      >
        <template v-if="!editor">
          <div
            v-show="!isHidden"
            class="gobierto-data-btn-download-data-modal"
          >
            <template
              v-for="(item, key, index) in arrayFormats"
            >
              <a
                :key="index"
                :href="item"
                :download="titleFile"
                class="gobierto-data-btn-download-data-modal-element"
              >
                {{ key }}
              </a>
            </template>
          </div>
        </template>
        <template v-else>
          <div
            v-show="!isHidden"
            class="gobierto-data-btn-download-data-modal"
          >
            <template
              v-for="({ url, name, label }, index) in arrayFormatsQuery"
            >
              <a
                :key="index"
                :href="url"
                :download="name"
                class="gobierto-data-btn-download-data-modal-element"
                target="_blank"
              >
                {{ label }}
              </a>
            </template>
          </div>
        </template>
      </transition>
    </Button>
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
    },
    queryStored: {
      type: String,
      default: ""
    },
  },
  data() {
    return {
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || "",
      isHidden: true,
      arrayFormatsQuery: {},
      titleFile: ''
    }
  },
  watch: {
    queryStored(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.createObjectFormatsQuery(newValue)
      }
    }
  },
  created() {
    this.createObjectFormatsQuery(this.queryStored)
  },
  methods: {
    closeMenu() {
      this.isHidden = true
    },
    createObjectFormatsQuery(sql) {
      const queryTrim = sql.trim()
      const endPointCSV = `${baseUrl}/data.csv?sql=${queryTrim}&csv_separator=semicolon`
      const endPointJSON = `${baseUrl}/data.json?sql=${queryTrim}`
      const endPointXLSX = `${baseUrl}/data.xlsx?sql=${queryTrim}`

      const {
        params: {
          id: titleFile
        }
      } = this.$route

      this.titleFile = titleFile

      this.arrayFormatsQuery = [
        {
          label: 'CSV',
          url: endPointCSV,
          name: `${titleFile}.csv`
        },
        {
          label: 'JSON',
          url: endPointJSON,
          name: `${titleFile}.json`
        },
        {
          label: 'XLSX',
          url: endPointXLSX,
          name: `${titleFile}.xlsx`
        }
      ]
    }
  }
}
</script>

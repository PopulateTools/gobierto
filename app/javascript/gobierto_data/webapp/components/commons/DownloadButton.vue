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
              v-for="(item, key) in arrayFormats"
            >
              <a
                :key="key"
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
              v-for="({ url, name, label }, key) in arrayFormatsQuery"
            >
              <a
                :key="key"
                class="gobierto-data-btn-download-data-modal-element"
                @click.prevent="getFiles(url, name)"
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
import { DownloadFilesFactoryMixin } from "./../../../lib/factories/download";

export default {
  name: 'DownloadButton',
  components: {
    Button
  },
  mixins: [CommonsMixin, DownloadFilesFactoryMixin],
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

      //Get the formats from API
      const keyFomarts = Object.keys(this.arrayFormats)
      //Convert all linebreaks from any SO(Windows: \r\n Linux: \n Older Macs: \r) to spaces.
      const formatSQL = sql.replace(/[\r\n]+/gm, " ");
      let datetime = new Date();
      const date = `${datetime.getDate()}_${(datetime.getMonth() + 1)}_${datetime.getFullYear()}`;

      const {
        params: {
          id: titleFile
        }
      } = this.$route

      this.titleFile = titleFile

      for (let i = 0; i < keyFomarts.length; i++) {
        this.arrayFormatsQuery[i] = {
          label: keyFomarts[i],
          url: `${baseUrl}/data.${keyFomarts[i]}?sql=${formatSQL}`,
          name: `${titleFile}_${date}.${keyFomarts[i]}`
        };
      }
    }
  }
}
</script>

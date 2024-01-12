<template>
  <div class="gobierto-data-container-btn-download-data">
    <Button
      v-clickoutside="closeMenu"
      :text="labelDownloadData"
      icon="download"
      icon-color="rgba(var(--color-base-string), .5)"
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
            <a
              v-for="(item, key) in arrayFormats"
              :key="key"
              :href="item"
              :download="titleFile"
              class="gobierto-data-btn-download-data-modal-element"
            >
              {{ key }}
            </a>
          </div>
        </template>
        <template v-else>
          <div
            v-show="!isHidden"
            class="gobierto-data-btn-download-data-modal"
          >
            <a
              v-for="({ url, name, label }, key) in arrayFormatsQuery"
              :key="key"
              :href="url"
              class="gobierto-data-btn-download-data-modal-element"
              @click.prevent="getFiles(url, name)"
            >
              {{ label }}
            </a>
          </div>
        </template>
      </transition>
    </Button>
  </div>
</template>
<script>
import Button from "./Button.vue";
import { VueDirectivesMixin } from "lib/vue/directives";
import { DownloadFilesFactoryMixin } from "./../../../lib/factories/download";

export default {
  name: 'DownloadButton',
  components: {
    Button
  },
  mixins: [VueDirectivesMixin, DownloadFilesFactoryMixin],
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
    }
  }
}
</script>

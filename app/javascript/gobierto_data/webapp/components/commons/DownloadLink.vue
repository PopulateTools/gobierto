<template>
  <div
    class="gobierto-data-container-btn-download-data"
    :class="cssClass"
  >
    <transition
      name="fade"
      mode="out-in"
    >
      <template v-if="!editor">
        <template
          v-for="(item, key) in arrayFormats"
        >
          <a
            :key="key"
            :href="item"
            :download="titleFile"
            class="gobierto-data-btn-blue gobierto-data-btn-download-data"
          >
            <i class="fas fa-download" />
            {{ labelDownloadData }}
          </a>
        </template>
      </template>
      <template v-else>
        <template
          v-for="({ url, name }, key) in arrayFormatsQuery"
        >
          <a
            :key="key"
            :href="url"
            class="gobierto-data-btn-blue gobierto-data-btn-download-data align-right"
            @click.prevent="getFiles(url, name)"
          >
            <i class="fas fa-download" />
            {{ labelDownloadData }}
          </a>
        </template>
      </template>
    </transition>
  </div>
</template>
<script>
import { VueDirectivesMixin } from "lib/vue/directives";
import { DownloadFilesFactoryMixin } from "./../../../lib/factories/download";

export default {
  name: 'DownloadLink',
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
    cssClass: {
      type: String,
      default: ""
    }
  },
  data() {
    return {
      labelDownloadData: I18n.t("gobierto_data.projects.downloadData") || "",
      arrayFormatsQuery: {},
      titleFile: ''
    }
  },
  computed: {
    moreThanOneFormat() {
      return Object.keys(this.arrayFormats).length > 1
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

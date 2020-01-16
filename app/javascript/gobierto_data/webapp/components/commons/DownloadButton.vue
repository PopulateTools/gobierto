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
      class="gobierto-data-btn-download-data-modal arrow-top"
    >
      <!-- //TODO ACTIONS -->
      <button class="gobierto-data-btn-download-data-modal-element">
        CSV
      </button>
      <button class="gobierto-data-btn-download-data-modal-element">
        JSON
      </button>
      <button class="gobierto-data-btn-download-data-modal-element">
        XLXS
      </button>
      <button class="gobierto-data-btn-download-data-modal-element">
        OTHER
      </button>
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
      dataLink: ''
    }
  },
  created() {
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
  },
  methods: {
    showModalButton() {
      this.isActive = !this.isActive;
    },
    closeMenu() {
      this.isActive = false
    }
  }
}

</script>

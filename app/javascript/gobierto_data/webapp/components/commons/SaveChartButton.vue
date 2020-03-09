<template>
  <div class="gobierto-data-sql-editor-container-save">
    <input
      v-if="isSavingPromptVisible"
      ref="inputText"
      v-model="labelVisName"
      type="text"
      class="gobierto-data-sql-editor-container-save-text"
      @keyup="nameChart($event.target.value)"
    >

    <template v-if="isSavingPromptVisible">
      <label
        :for="labelPrivate"
        class="gobierto-data-sql-editor-container-save-label"
      >
        <input
          :id="labelPrivate"
          :checked="isPrivate"
          type="checkbox"
          class="gobierto-data-sql-editor-container-save-checkbox"
          @input="isPrivateChart($event.target.checked)"
        >
        {{ labelPrivate }}
      </label>
      <i
        :class="isPrivate ? 'fa-lock' : 'fa-lock-open'"
        :style="isPrivate ? 'color: #D0021B;' : 'color: #A0C51D;'"
        class="fas"
      />
    </template>

    <Button
      :text="labelSaveChart"
      :style="
        isSavingPromptVisible
          ? 'color: #fff; background-color: var(--color-base)'
          : 'color: var(--color-base); background-color: rgb(255, 255, 255);'
      "
      icon="save"
      color="var(--color-base)"
      background="#fff"
      class="gobierto-data-btn-download-data"
      @click.native="saveChart"
    />

    <Button
      v-if="isSavingPromptVisible"
      :text="labelCancel"
      class="btn-sql-editor btn-sql-editor-cancel"
      icon="undefined"
      color="var(--color-base)"
      background="#fff"
      @click.native="cancelChart"
    />
  </div>
</template>
<script>
import Button from "./Button.vue";

export default {
  name: 'SaveChartButton',
  components: {
    Button
  },
  data() {
    return {
      isPrivate: false,
      isSavingPromptVisible: false,
      labelSaveChart: "",
      labelPrivate: "",
      labelCancel: "",
    }
  },
  created() {
    this.labelSaveChart = I18n.t("gobierto_data.projects.save")
    this.labelPrivate = I18n.t('gobierto_data.projects.private');
    this.labelCancel = I18n.t('gobierto_data.projects.cancel');
    this.labelVisName = I18n.t('gobierto_data.projects.visName');
  },
  methods: {
    saveChart() {
      if (!this.isSavingPromptVisible) {
        this.isSavingPromptVisible = true
        this.$nextTick(() => {
          this.$refs.inputText.focus();
        });
      } else {
        this.$root.$emit("exportPerspectiveConfig", {
          name: this.labelVisName,
          privacy: this.isPrivate
        });
        this.isSavingPromptVisible = false
      }
    },
    cancelChart() {
      this.isSavingPromptVisible = false
    },
    nameChart(name) {
      this.labelVisName = name
    },
    isPrivateChart(valuePrivate) {
      this.isPrivate = valuePrivate
    },
  }
}
</script>

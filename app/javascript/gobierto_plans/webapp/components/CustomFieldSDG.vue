<template>
  <div class="ods-goal-container">
    <div
      v-for="{ id: idx, external_id } in value"
      :key="idx"
      class="ods-goal-content"
    >
      <a
        :href="`${baseUrl}/ods/${+external_id}`"
        :class="`ods-goal ods-goal__${external_id.padStart(2, 0)}__${locale}`"
      />
    </div>
  </div>
</template>

<script>
export default {
  name: "CustomFieldSDG",
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      baseUrl: this.$root.$data.baseurl,
      locale: I18n.locale,
    };
  },
  created() {
    const { value } = this.attributes;
    this.value = value;
  }
};
</script>

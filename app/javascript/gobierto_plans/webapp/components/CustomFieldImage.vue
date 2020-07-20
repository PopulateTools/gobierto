<template>
  <div class="project-description__images">
    <img
      v-for="{ id, src } in images"
      :key="id"
      :src="src"
    >
  </div>
</template>

<script>
export default {
  name: "CustomFieldImage",
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      images: []
    };
  },
  created() {
    const { value } = this.attributes;

    if (value) {
      const elements = Array.isArray(value) ? value : [value]
      this.images = elements.map((imagePath, id) => ({ id, src: imagePath }))
    }
  }
};
</script>

<template>
  <div>
    <i class="fas fa-file-excel" />
    <span class="gobierto-data-resources-list-element-name">{{ item.file.name }}</span>
    <span class="gobierto-data-resources-list-element-size">{{ item.file.size }}</span>
  </div>
</template>

<script>
export default {
  name: "ResourcesItem",
  props: {
    item: {
      type: Object,
      required: true
    },
  }
}
</script>

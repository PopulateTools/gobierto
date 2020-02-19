<template>
  <div>
    <template
      v-for="(item, index) in resourcesList"
    >
      <a
        :key="index"
        :href="item.attributes.url"
      >
        <i class="fas fa-file-excel" />
      </a>
      <span
        :key="index"
        class="gobierto-data-resources-list-element-name"
      >
        item.attributes.name
      </span>
      <span
        :key="index"
        class="gobierto-data-resources-list-element-size"
      >
        item.attributes.file_size
      </span>
    </template>
  </div>
</template>

<script>
export default {
  name: "ResourcesItem",
  props: {
    resourcesList: {
      type: Array,
      required: true
    }
  },
}
</script>

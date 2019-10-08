<template>
  <div>
    <div
      class="investments-home-main--gallery-item"
      @click.prevent="nav(item)"
    >
      <div class="investments-home-main--photo">
        <img
          v-if="item.photo"
          :src="item.photo"
        >
      </div>
      <div class="investments-home-main--data">
        <a
          href
          class="investments-home-main--link"
          @click.stop.prevent="nav(item)"
        >{{ item.title | translate }}</a>
        <div>
          <div
            v-for="attr in attributes"
            :key="attr.id"
            class="investments-home-main--property"
          >
            <div>{{ attr.name | translate }}</div>

            <div v-if="attr.filter === 'money'">
              {{ attr.value | money }}
            </div>
            <div v-else-if="attr.filter === 'translate'">
              {{ attr.value | translate }}
            </div>
            <div v-else>
              {{ attr.value }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "GalleryItem",
  mixins: [CommonsMixin],
  props: {
    item: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      attributes: {},
    }
  },
  created() {
    const { availableGalleryFields = {} } = this.item
    this.attributes = availableGalleryFields
  },
};
</script>
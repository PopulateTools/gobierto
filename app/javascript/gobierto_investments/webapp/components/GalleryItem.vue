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
          :alt="item.title"
        >
      </div>
      <div class="investments-home-main--data">
        <a
          href
          class="investments-home-main--link"
          @click.stop.prevent="nav(item)"
        >{{ item.title }}</a>
        <div>
          <div
            v-for="{ id, name, field_type, value } in attributes"
            :key="id"
            class="investments-home-main--property"
          >
            <div
              v-if="displayGalleryFieldTags"
              class="investments-home-main--property__tag"
            >
              {{ name }}
            </div>

            <div
              v-if="field_type === 'money'"
              class="investments-home-main--property__value"
            >
              {{ value | money }}
            </div>
            <div
              v-else-if="field_type === 'date'"
              class="investments-home-main--property__value"
            >
              {{ value | date }}
            </div>
            <div
              v-else
              class="investments-home-main--property__value"
            >
              {{ value }}
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
      displayGalleryFieldTags: true
    };
  },
  created() {
    const { availableGalleryFields = {}, displayGalleryFieldTags } = this.item;
    this.displayGalleryFieldTags = !!displayGalleryFieldTags
    this.attributes = availableGalleryFields.filter(
      ({ type, value }) => type === "separator" || (value !== null && value !== undefined && !(value instanceof Array && value.length === 0))
    );
  }
};
</script>

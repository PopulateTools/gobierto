<template>
  <div class="read-more js-read-more">
    <div>
      {{ firstChars }}
      <span
        v-if="isFeatureEnable"
        data-toggle
      >
        <a>{{ seeMore }}</a>
      </span>
    </div>
    <div>
      {{ lastChars }}
      <span data-toggle>
        <a>{{ seeLess }}</a>
      </span>
    </div>
  </div>
</template>

<script>
import { readMore } from '../../../../lib/shared';

export default {
  name: "ReadMore",
  props: {
    seeMore: {
      type: String,
      default: I18n.t("gobierto_common.vue_components.read_more.more")
    },
    seeLess: {
      type: String,
      default: I18n.t("gobierto_common.vue_components.read_more.less")
    },
    roundChars: {
      type: Number,
      default: 150
    }
  },
  data() {
    return {
      text: "",
      breakIndex: 0
    };
  },
  computed: {
    isFeatureEnable() {
      return this.text.length > this.breakIndex
    },
    firstChars() {
      return this.text.substring(0, this.breakIndex);
    },
    lastChars() {
      return this.text.substring(this.breakIndex, this.text.length);
    }
  },
  created() {
    const { text = "" } = this.$slots.default[0];
    this.text = text;
    this.breakIndex = this.roundChars + this.firstBreakAppearance() + 1;
  },
  mounted() {
    if (this.isFeatureEnable) {
      readMore(this.$el);
    }
  },
  methods: {
    firstBreakAppearance() {
      const textBreaks = [".", ";", "\n"];
      const indexTextBreaks = [];
      for (let i = 0; i < textBreaks.length; i++) {
        const element = textBreaks[i];
        const index = this.text
          .substring(this.roundChars, this.text.length)
          .indexOf(element);
        if (index >= 0) {
          indexTextBreaks.push(index);
        }
      }

      return Math.min.apply(Math, indexTextBreaks);
    }
  }
};
</script>

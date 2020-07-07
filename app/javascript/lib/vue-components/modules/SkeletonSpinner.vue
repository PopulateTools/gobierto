<template>
  <div>
    <div class="gobierto-skeleton-spinner-container-squares">
      <template v-for="square in parseInt(squares)">
        <div
          :key="`square-${square}`"
          :style="styles"
          class="gobierto-skeleton-spinner gobierto-skeleton-spinner-square"
        />
      </template>
    </div>
    <template v-for="line in parseInt(lines)">
      <div
        :key="`line-${line}`"
        class="gobierto-skeleton-spinner gobierto-skeleton-spinner-line"
      />
    </template>
  </div>
</template>

<script>
export default {
  name: "SkeletonSpinner",
  props: {
    heightSquare: {
      default: `1rem`,
      type: String,
    },
    squares: {
      default: '0',
      type: String,
    },
    lines: {
      default: '0',
      type: String,
    }
  },
  computed: {
    styles() {
      return {
        width: ((100 - (this.squares - 1)) / this.squares) + '%',
        height: this.heightSquare
      }
    }
  }
};
</script>

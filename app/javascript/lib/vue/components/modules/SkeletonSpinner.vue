<template>
  <div>
    <template v-for="line in parseInt(lines)">
      <div
        :key="`line-${line}`"
        :style="stylesLines()"
        class="gobierto-skeleton-spinner gobierto-skeleton-spinner-line"
      />
    </template>
    <template v-for="square in parseInt(squaresRows)">
      <div
        :key="`square-row-${square}`"
        class="gobierto-skeleton-spinner-container-squares"
      >
        <template v-for="square in parseInt(squares)">
          <div
            :key="`square-${square}`"
            :style="styleSquares"
            class="gobierto-skeleton-spinner gobierto-skeleton-spinner-square"
          />
        </template>
      </div>
    </template>
  </div>
</template>

<script>
export default {
  name: "SkeletonSpinner",
  props: {
    heightSquare: {
      default: '1rem',
      type: String,
    },
    squaresRows: {
      default: '1',
      type: String,
    },
    squares: {
      default: '1',
      type: String,
    },
    lines: {
      default: '0',
      type: String,
    }
  },
  computed: {
    styleSquares() {
      return {
        width: ((100 - (+(this.squares) - 1)) / +(this.squares)) + '%',
        height: this.heightSquare
      }
    },
  },
  methods: {
    stylesLines() {
      return {
        width: Math.floor(Math.random() * (90 - 50 + 1)) + 50 + '%'
      }
    }
  }
};
</script>

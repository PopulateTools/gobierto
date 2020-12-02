<template>
  <div>
    <slot
      v-if="label.length"
      name="label"
    >
      <!-- default autocomplete label -->
      <label
        class="gobierto-autocomplete__label"
        for="autocomplete-input"
      >
        {{ label }}
      </label>
    </slot>

    <input
      id="autocomplete-input"
      v-model="search"
      name="autocomplete"
      autocomplete="off"
      :placeholder="placeholder"
      type="text"
      class="gobierto-autocomplete__input"
      :class="{ 'is-active': isOpen }"
      @input="onChange"
      @keydown.down="onArrowDown"
      @keydown.up="onArrowUp"
      @keydown.enter="onEnter"
    >

    <transition name="slide">
      <ul
        v-if="isOpen"
        class="gobierto-autocomplete__results"
      >
        <li
          v-for="(result, i) in results"
          :key="i"
          class="gobierto-autocomplete__result"
          :class="{ 'is-active': i === arrowCounter }"
          @click="setResult(result)"
        >
          <slot :result="result">
            <!-- default autocomplete item list -->
            {{ result }}
          </slot>
        </li>
      </ul>
    </transition>
  </div>
</template>

<script>
export default {
  name: "Autocomplete",
  props: {
    label: {
      type: String,
      default: null
    },
    placeholder: {
      type: String,
      default: ""
    },
    items: {
      type: Array,
      default: () => []
    },
    searchKey: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      results: this.items,
      isOpen: false,
      search: "",
      arrowCounter: -1
    };
  },
  mounted() {
    document.addEventListener("click", this.handleClickOutside);
  },
  destroyed() {
    document.removeEventListener("click", this.handleClickOutside);
  },
  methods: {
    onChange() {
      this.$emit("input", this.search);

      this.isOpen = true;
      this.results = this.items.filter(item => {
        if (typeof item === "object" && item !== null) {
          if (!this.searchKey) throw new Error("search-key prop is not provided")

          return (""+item[this.searchKey])
              .toLowerCase()
              .indexOf(this.search.toLowerCase()) > -1
        }

        return (""+item).toLowerCase().indexOf((""+this.search).toLowerCase()) > -1
      }
      );
    },
    onArrowDown() {
      this.isOpen = true;
      if (this.arrowCounter < this.results.length) {
        this.arrowCounter = this.arrowCounter + 1;
      }
    },
    onArrowUp() {
      this.isOpen = true;
      if (this.arrowCounter > 0) {
        this.arrowCounter = this.arrowCounter - 1;
      }
    },
    onEnter() {
      this.search = this.results[this.arrowCounter];
      this.isOpen = false;
      this.arrowCounter = -1;
    },
    handleClickOutside(evt) {
      if (!this.$el.contains(evt.target)) {
        this.isOpen = false;
        this.arrowCounter = -1;
      }
    },
    setResult(result) {
      this.search = result;
      this.isOpen = false;
    }
  }
};
</script>

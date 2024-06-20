<template>
  <div class="gobierto-autocomplete">
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
      :name="name"
      autocomplete="off"
      :placeholder="placeholder"
      type="text"
      class="gobierto-autocomplete__input"
      :class="{ 'is-active': isOpen }"
      @input="onChange"
      @keydown.down="onArrowDown"
      @keydown.up="onArrowUp"
      @keydown.enter.prevent="setResult()"
      @dblclick="isOpen = !isOpen"
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
    name: {
      type: String,
      default: "autocomplete"
    },
    items: {
      type: Array,
      default: () => []
    },
    defaultValue: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      results: this.items,
      isOpen: false,
      search: this.defaultValue || "",
      arrowCounter: -1
    };
  },
  mounted() {
    document.addEventListener("click", this.handleClickOutside);
  },
  unmounted() {
    document.removeEventListener("click", this.handleClickOutside);
  },
  methods: {
    onChange() {
      this.$emit("input", this.search);

      this.isOpen = true;
      this.results = this.items.filter(item => (""+item).toLowerCase().indexOf((""+this.search).toLowerCase()) > -1);
    },
    onArrowDown() {
      this.isOpen = true;
      this.arrowCounter = (this.arrowCounter < this.results.length - 1) ? this.arrowCounter + 1 : 0
    },
    onArrowUp() {
      this.isOpen = true;
      this.arrowCounter = (this.arrowCounter > 0) ? this.arrowCounter - 1 : this.results.length - 1
    },
    handleClickOutside(evt) {
      if (!this.$el.contains(evt.target)) {
        this.isOpen = false;
        this.arrowCounter = -1;
      }
    },
    setResult(result) {
      this.search = result || this.results[this.arrowCounter];
      this.isOpen = false;
      this.arrowCounter = -1;

      this.$emit("change", this.search);
    }
  }
};
</script>

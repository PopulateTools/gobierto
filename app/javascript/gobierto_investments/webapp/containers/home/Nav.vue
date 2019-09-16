<template>
  <nav class="investments-home-nav">
    <ul>
      <li
        class="investments-home-nav--tab"
        :class="{ 'is-active': isActive === 0 }"
        @click="activateTab(0)"
      >
        <i class="fas fa-map"></i>
        <i class="far fa-map"></i>
        <span>Mapa</span>
      </li>
      <li
        class="investments-home-nav--tab"
        :class="{ 'is-active': isActive === 1 }"
        @click="activateTab(1)"
      >
        <i class="fas fa-clone"></i>
        <i class="far fa-clone"></i>
        <span>Galería</span>
      </li>
      <li
        class="investments-home-nav--tab"
        :class="{ 'is-active': isActive === 2 }"
        @click="activateTab(2)"
      >
        <i class="fas fa-list-alt"></i>
        <i class="far fa-list-alt"></i>
        <span>Llista</span>
      </li>
    </ul>
  </nav>
</template>

<script>
export default {
  name: "HomeNav",
  data() {
    return {
      isActive: 0
    };
  },
  methods: {
    activateTab(index) {
      this.isActive = index;
      this.$emit("active-tab", index);
    }
  }
};
</script>


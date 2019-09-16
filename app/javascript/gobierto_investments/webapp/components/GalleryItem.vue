<template>
  <div>
    <div class="investments-home-main--gallery-item">
      <div class="investments-home-main--photo">
        <img
          src="https://loremflickr.com/g/320/240/mataro"
          alt
        >
      </div>
      <div class="investments-home-main--data">
        <a
          href
          class="investments-home-main--link"
          @click.prevent="nav(item.id)"
        >{{ item.title }}</a>
        <div>
          <div class="investments-home-main--property">
            <div>Estáu</div>
            <div>{{ item.status }}</div>
          </div>
          <div class="investments-home-main--property">
            <div>Tipu</div>
            <div>Pisu</div>
          </div>
          <div class="investments-home-main--property">
            <div>Edificiu</div>
            <div>Edificius deportivus</div>
          </div>
          <div class="investments-home-main--property">
            <div>Cantidá</div>
            <div>{{ item.import }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "GalleryItem",
  props: {
    item: {
      type: Object,
      default: () => {}
    }
  },
  methods: {
    nav(id) {
      this.$router.push({ name: "project", params: { id } });
    }
  }
};
</script>
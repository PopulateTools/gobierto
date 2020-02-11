<template>
  <div
    id="container"
    class="gobierto-data-sets-nav--tab-container"
  >
    <perspective-viewer editable />
  </div>
</template>
<script>
export default {
  name: "Visualizations",
  data() {
    return {
      dataPerspective: []
    }
  },
  methods: {
    loadData(table){
      this.dataPerspective = table
      console.log("this.dataPerspective", this.dataPerspective);
      this.initPerspective(this.dataPerspective)
    },
    initPerspective(data){
      const viewer = document.getElementsByTagName("perspective-viewer")[0];
      viewer.load(data);


    }
  }
}
</script>
<style>
#container {
    background-color: #ccc;
}

perspective-viewer {
    overflow: hidden;
}
</style>

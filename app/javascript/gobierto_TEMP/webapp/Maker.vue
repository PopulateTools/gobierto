<template>
  <div class="dashboards-maker">
    <HeaderContent />
    <Main>
      <template #aside>
        <Aside />
      </template>
      <template>
        <Viewer />
      </template>
    </Main>
  </div>
</template>

<script>
import Viewer from "./Viewer"
import HeaderContent from "./containers/HeaderContent"
import Aside from "./containers/Aside"
import Main from "./layouts/Main"

export default {
  name: "Maker",
  components: {
    Viewer,
    HeaderContent,
    Main,
    Aside
  },
  data() {
    return {

    }
  }
}
</script>
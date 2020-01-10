<template>
  <Layout>
    <Sidebar>
      <template v-slot:sidebar>
        <slot name="sidebar" />
      </template>
    </Sidebar>
    <slot />
  </Layout>
</template>
<script>
import Sidebar from "./../components/Sidebar.vue";

export default {
  components: {
    Sidebar
  }
}

</script>

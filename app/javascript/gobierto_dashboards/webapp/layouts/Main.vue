<template>
  <main class="layout-main">
    <aside>
      <slot name="aside" />
    </aside>
    <article>
      <slot />
    </article>
  </main>
</template>

<script>
export default {
  name: "Main",
}
</script>
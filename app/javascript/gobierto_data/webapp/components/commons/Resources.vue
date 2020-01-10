<template>
  <div class="gobierto-data-summary-resources">
    <h2 class="gobierto-data-tabs-section-title">
      <i class="fas fa-caret-down" />
      {{ labelResources }}
    </h2>
    <div class="gobierto-data-resources-list">
      <div
        v-for="(item, index) in items"
        :key="index"
        class="gobierto-data-resources-list-element"
      >
        <i class="fas fa-file-excel" />
        <span class="gobierto-data-resources-list-element-name">{{ item.file.name }}</span>
        <span class="gobierto-data-resources-list-element-size">{{ item.file.size }}</span>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "Resources",
  data() {
    return {
      labelResources: "",
      items: [{
          file: {
            name: 'Actuaciones Bomberos Enero 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Febrero 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Marzo 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Abril 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Mayo 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Junio 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Julio 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Agosto 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Septiembre 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Octubre 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Noviembre 2019.xls',
            size: '232kb'
          }
        },
        {
          file: {
            name: 'Actuaciones Bomberos Diciembre 2019.xls',
            size: '232kb'
          }
        }
      ]
    }
  },
  created() {
    this.labelResources = I18n.t("gobierto_data.projects.resources")
  }
}

</script>

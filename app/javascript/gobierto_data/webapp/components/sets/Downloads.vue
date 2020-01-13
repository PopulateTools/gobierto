<template>
  <div>
    <Resources :items="filesDataset" />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";

export default {
  name: "Downloads",
  components: {
    Resources
  },
  data() {
    return {
      filesDataset: [{
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
  }
}
</script>

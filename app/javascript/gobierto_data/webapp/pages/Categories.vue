<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <div style="background-color: rgba(113, 184, 193, .1); color: #71B8C1; height: 40vh; widht: 100%; padding: 1rem; font-weight: bold;">
      Promo - Intro al módulo
    </div>
    <InfoList :items="datasets" />
  </div>
</template>
<script>
import InfoList from "./../components/commons/InfoList.vue";
export default {
  name: "Categories",
  components: {
    InfoList
  },
  data() {
    return {
      datasets: [{
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      },
      {
        file: {
          title: 'Mobiliario urbano. Juegos en áreas actividades de mayores',
          date: '12 de octubre de 2019',
          frequency: 'Anual',
          subject: 'Urbanismo e infraestructuras',
          description: 'Este conjuntos de datos contiene el detalle de más de 1.200 elementos para actividades de mayores de la ciudad de Madrid con su tipología y coordenadas. En este portal tambien están disponibles otros.'
        }
      }
      ]
    }
  },
  created() {
    this.labelFav = I18n.t("gobierto_data.projects.fav")
    this.labelFollow = I18n.t("gobierto_data.projects.follow")
  }
}

</script>

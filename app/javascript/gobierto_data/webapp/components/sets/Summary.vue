<template>
  <div>
    <Info />
    <div class="gobierto-data-container-btn-download-data">
      <Button
        :text="labelDownloadData"
        icon="download"
        color="var(--color-base)"
        background="#fff"
        class="gobierto-data-btn-download-data"
        icon-color="rgba(var(--color-base-string), .2)"
        @click.native="showModalButton"
      />
      <div
        :class="{ 'active': isActive }"
        class="gobierto-data-btn-download-data-modal arrow-top"
      >
        <button class="gobierto-data-btn-download-data-modal-element">
          CSV
        </button>
        <button class="gobierto-data-btn-download-data-modal-element">
          JSON
        </button>
        <button class="gobierto-data-btn-download-data-modal-element">
          XLXS
        </button>
        <button class="gobierto-data-btn-download-data-modal-element">
          OTHER
        </button>
      </div>
    </div>
    <Resources :items="filesDataset" />
    <Queries />
  </div>
</template>

<script>
import Resources from "./../commons/Resources.vue";
import Info from "./../commons/Info.vue";
import Button from "./../commons/Button.vue";
import Queries from "./../commons/Queries.vue";

export default {
  name: "Summary",
  components: {
    Resources,
    Queries,
    Button,
    Info
  },
  data() {
    return {
      isActive: false,
      labelDownloadData: "",
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
  },
  created() {
    this.labelDownloadData = I18n.t("gobierto_data.projects.downloadData")
  },
  methods: {
    showModalButton() {
      this.isActive = !this.isActive;
    }
  }

}

</script>

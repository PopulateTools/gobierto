<template>
  <div>
    <div class="pure-g">
      <div class="pure-u-1-2">
        <h2 class="gobierto-data-title-dataset">
          {{ titleDataset }}
        </h2>
      </div>
      <div class="pure-u-1-2 gobierto-data-buttons">
        <Button
          :text="labelFav"
          icon="star"
          color="#fff"
          background="var(--color-base)"
        />
        <Button
          :text="labelFollow"
          icon="bell"
          color="#fff"
          background="var(--color-base)"
        />
      </div>
    </div>
    <nav class="gobierto-data-sets-nav">
      <ul>
        <li
          :class="{ 'is-active': activeTab === 0 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(0)"
        >
          <span>{{ labelSummary }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 1 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(1)"
        >
          <span>{{ labelData }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 2 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(2)"
        >
          <span>{{ labelQueries }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 3 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(3)"
        >
          <span>{{ labelVisualizations }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 4 }"
          class="gobierto-data-sets-nav--tab"
          @click="activateTab(4)"
        >
          <span>{{ labelDownload }}</span>
        </li>
      </ul>
    </nav>
    <keep-alive>
      <Summary
        v-if="activeTab === 0"
        :array-queries="arrayQueries"
        :public-queries="publicQueries"
        :array-formats="arrayFormats"
        :description-dataset="descriptionDataset"
        :category-dataset="categoryDataset"
        :frequency-dataset="frequencyDataset"
        :resources-list="resourcesList"
        :date-updated="dateUpdated"
      />
      <Data
        v-else-if="activeTab === 1"
        :dataset-id="datasetId"
        :array-queries="arrayQueries"
        :array-columns="arrayColumns"
        :public-queries="publicQueries"
        :table-name="tableName"
        :array-formats="arrayFormats"
        :number-rows="numberRows"
      />
      <Queries
        v-else-if="activeTab === 2"
        :array-queries="arrayQueries"
        :public-queries="publicQueries"
      />
      <Visualizations v-else-if="activeTab === 3" />
      <Downloads
        v-else-if="activeTab === 4"
        :array-formats="arrayFormats"
        :resources-list="resourcesList"
      />
    </keep-alive>
  </div>
</template>
<script>
import Button from "./../commons/Button.vue";
import Summary from "./Summary.vue";
import Data from "./Data.vue";
import Queries from "./Queries.vue";
import Visualizations from "./Visualizations.vue";
import Downloads from "./Downloads.vue";
import axios from 'axios'
import { baseUrl } from "./../../../lib/commons"
import { getUserId, getToken } from "./../../../lib/helpers"

export default {
  name: "NavSets",
  components: {
    Summary,
    Data,
    Queries,
    Visualizations,
    Downloads,
    Button
  },
  data() {
    return {
      activeTab: 0,
      labelSummary: "",
      labelData: "",
      labelQueries: "",
      labelVisualizations: "",
      labelDownload: "",
      labelFav: "",
      labelFollow: "",
      slugName: '',
      tableName: '',
      titleDataset: '',
      arrayQueries: [],
      numberRows: 0,
      arrayFormats: {},
      publicQueries: [],
      resourcesList: [],
      userId: '',
      dateUpdated: '',
      descriptionDataset: '',
      categoryDataset: '',
      frequencyDataset: ''
    }
  },
  created() {
    this.labelSummary = I18n.t("gobierto_data.projects.summary")
    this.labelData = I18n.t("gobierto_data.projects.data")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelVisualizations = I18n.t("gobierto_data.projects.visualizations")
    this.labelDownload = I18n.t("gobierto_data.projects.download")
    this.labelFav = I18n.t("gobierto_data.projects.fav")
    this.labelFollow = I18n.t("gobierto_data.projects.follow")

    this.$root.$on('changeNavTab', this.changeTab)
    this.$root.$on('activeTabIndex', this.changeTab)
    this.$root.$on('reloadQueries', this.getQueries)

    this.slugName = this.$route.params.id
    this.userId = getUserId()
    this.token = getToken()

    this.setValuesDataset()
  },
  methods: {
    changeTab() {
      this.activateTab(1)
    },
    activateTab(index) {
      this.activeTab = index
      this.$emit("active-tab", index);
    },
    setValuesDataset(){
      const url = `${baseUrl}/datasets/${this.slugName}/meta`
      axios
        .get(url)
        .then(response => {

         const rawData = response.data
         const { data: {
           id: datasetId,
           attributes: {
             name: titleDataset,
             slug: slugDataset,
             table_name: tableName,
             columns: arrayColumns,
             description: descriptionDataset,
             data_summary: {
               number_of_rows: numberRows
             },
             formats: arrayFormats,
             frequency: {
              name_translations: frequencyDataset
             },
             category: {
              name_translations: categoryDataset
             }
           }
         } } = rawData;

          const resourcesData = response.included
          this.datasetId = parseInt(datasetId)
          this.titleDataset = titleDataset
          this.slugDataset = slugDataset
          this.tableName = tableName
          this.arrayFormats = arrayFormats
          this.arrayColumns = arrayColumns
          this.numberRows = numberRows
          this.frequencyDataset = frequencyDataset === undefined ? '' : frequencyDataset
          this.categoryDataset = categoryDataset === undefined ? '' : categoryDataset
          this.descriptionDataset = descriptionDataset
          const dateFromApi = rawData.data.attributes.data_updated_at === undefined ? '' : rawData.data.attributes.data_updated_at
          const newDateFromApi = new Date(dateFromApi)
          this.dateUpdated = newDateFromApi.toLocaleDateString('es-ES', {
              day : 'numeric',
              month : 'short',
              year : 'numeric'
          })
          this.resourcesList = resourcesData

          this.getPublicQueries()
        })
        .catch(error => {
          console.error(error)
        })
    },
    getQueries() {
      const endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}&filter[user_id]=${this.userId}`
      axios
        .get(endPoint, {
          headers: {
            'Content-type': 'application/json',
            'Authorization': `${this.token}`
          }
        })
        .then(response => {
          const rawData = response.data
          const items = rawData.data
          this.arrayQueries = items
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
     getPublicQueries() {
      const endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}`
      axios
        .get(endPoint)
        .then(response => {
          const rawData = response.data
          const items = rawData.data
          this.publicQueries = items
          this.getQueries()
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    }
  }
}
</script>

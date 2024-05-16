import { baseUrl } from '../commons.js';
import axios from 'axios';

const endPoint = `${baseUrl}/datasets`;

// Dataset-endpoint factory to get/post/put/delete API data
export const DatasetFactoryMixin = {
  methods: {
    getDatasets(params) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      const qs = new URLSearchParams(params);
      return axios.get(`${endPoint}?${qs.toString()}locale=${I18n.locale}`, { headers });
    },
    getDatasetsMetadata(params) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      const qs = new URLSearchParams(params);
      return axios.get(`${endPoint}/meta?${qs.toString()}`, { headers });
    },
    getDatasetMetadata(id) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      return axios.get(`${endPoint}/${id}/meta/?locale=${I18n.locale}`, { headers })
    }
  }
};

import { baseUrl } from "../commons.js";
import { getToken } from "../helpers";
import axios from "axios";

const endPoint = `${baseUrl}/datasets`;
const token = getToken();
const headers = {
  "Content-type": "application/json",
  Authorization: token
};

// Dataset-endpoint factory to get/post/put/delete API data
export const DatasetFactoryMixin = {
  methods: {
    getDatasets(params) {
      const qs = new URLSearchParams(params);
      return axios.get(`${endPoint}?${qs.toString()}locale=${I18n.locale}`, { headers });
    },
    getDatasetsMetadata(params) {
      const qs = new URLSearchParams(params);
      return axios.get(`${endPoint}/meta?${qs.toString()}`, { headers });
    },
    getDatasetMetadata(id) {
      return axios.get(`${endPoint}/${id}/meta/?locale=${I18n.locale}`, { headers })
    }
  }
};

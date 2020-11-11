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
    getDatasetMetadata(id) {
      return axios.get(`${endPoint}/${id}/meta`, { headers })
    }
  }
};

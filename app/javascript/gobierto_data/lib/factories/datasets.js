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
    async getDatasetMetadata(id) {
      return axios.get(`${endPoint}/${id}/meta`, { headers })
        .then(response => {
          return response
        })
        // eslint-disable-next-line no-unused-vars
        .catch(error => {
          if (error.response.status === 404) {
            // eslint-disable-next-line no-unused-vars
            this.$router.push('/datos/').catch(error => {})
          }
        })
    },
  }
};

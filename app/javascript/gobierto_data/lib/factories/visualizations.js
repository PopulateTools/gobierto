import { baseUrl } from "../commons.js";
import { getToken } from "../helpers";
import axios from "axios";

const endPoint = `${baseUrl}/visualizations`;
const token = getToken();
const headers = {
  "Content-type": "application/json",
  Authorization: token
};

// Visualizations-endpoint factory to get/post/put/delete API data
export const VisualizationFactoryMixin = {
  methods: {
    getVisualization(id) {
      return axios.get(`${endPoint}/${id}`, { headers });
    },
    getVisualizations(params) {
      console.log(params);

      return axios.get(endPoint, { headers });
    },
    postVisualization(data) {
      // Return a promise to handle the response where it's invoked
      return axios.post(endPoint, data, { headers });
    }
  }
};

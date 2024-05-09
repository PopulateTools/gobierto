import { baseUrl } from '../commons.js';
import { getToken } from '../helpers';
import axios from 'axios';

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
      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`, { headers });
    },
    postVisualization(data) {
      // Return a promise to handle the response where it's invoked
      return axios.post(endPoint, data, { headers });
    },
    putVisualization(id, data) {
      return axios.put(`${endPoint}/${id}`, data, { headers });
    },
    deleteVisualization(id) {
      return axios.delete(`${endPoint}/${id}`, { headers });
    }
  }
};

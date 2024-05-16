import { baseUrl } from '../commons.js';
import axios from 'axios';

const endPoint = `${baseUrl}/visualizations`;

// Visualizations-endpoint factory to get/post/put/delete API data
export const VisualizationFactoryMixin = {
  methods: {
    getVisualization(id) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      return axios.get(`${endPoint}/${id}`, { headers });
    },
    getVisualizations(params) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`, { headers });
    },
    postVisualization(data) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      // Return a promise to handle the response where it's invoked
      return axios.post(endPoint, data, { headers });
    },
    putVisualization(id, data) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      return axios.put(`${endPoint}/${id}`, data, { headers });
    },
    deleteVisualization(id) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.populateData.token
      };

      return axios.delete(`${endPoint}/${id}`, { headers });
    }
  }
};

import { baseUrl } from '../commons.js';
import axios from 'axios';

const endPoint = `${baseUrl}/queries`;

// Queries-endpoint factory to get/post/put/delete API data
export const QueriesFactoryMixin = {
  methods: {
    getQuery(id) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.gobiertoAPI.token
      };

      return axios.get(`${endPoint}/${id}`, { headers });
    },
    getQueries(params) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.gobiertoAPI.token
      };

      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`, { headers });
    },
    postQuery(data) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.gobiertoAPI.token
      };

      return axios.post(endPoint, data, { headers });
    },
    putQuery(id, data) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.gobiertoAPI.token
      };

      return axios.put(`${endPoint}/${id}`, data, { headers });
    },
    deleteQuery(id) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.gobiertoAPI.token
      };

      return axios.delete(`${endPoint}/${id}`, { headers });
    },
  }
};

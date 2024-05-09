import { baseUrl } from '../commons.js';
import { getToken } from '../helpers';
import axios from 'axios';

const endPoint = `${baseUrl}/queries`;
const token = getToken();
const headers = {
  "Content-type": "application/json",
  Authorization: token
};

// Queries-endpoint factory to get/post/put/delete API data
export const QueriesFactoryMixin = {
  methods: {
    getQuery(id) {
      return axios.get(`${endPoint}/${id}`, { headers });
    },
    getQueries(params) {
      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`, { headers });
    },
    postQuery(data) {
      return axios.post(endPoint, data, { headers });
    },
    putQuery(id, data) {
      return axios.put(`${endPoint}/${id}`, data, { headers });
    },
    deleteQuery(id) {
      return axios.delete(`${endPoint}/${id}`, { headers });
    },
  }
};

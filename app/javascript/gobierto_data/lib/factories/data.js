import { baseUrl } from '../commons.js';
import axios from 'axios';

const endPoint = `${baseUrl}/data.csv`;

// Data-endpoint factory to get/post/put/delete API data
export const DataFactoryMixin = {
  methods: {
    getData(params) {
      const headers = {
        "Content-type": "application/json",
        Authorization: window.gobiertoAPI.token
      };

      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`, { headers });
    },
  }
};

import { baseUrl } from '../commons.js';
import { getToken } from '../helpers';
import axios from 'axios';

const endPoint = `${baseUrl}/data.csv`;
const token = getToken();
const headers = {
  Authorization: token
};

// Data-endpoint factory to get/post/put/delete API data
export const DataFactoryMixin = {
  methods: {
    getData(params) {
      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`, { headers });
    },
  }
};

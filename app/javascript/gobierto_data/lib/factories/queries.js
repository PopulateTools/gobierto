import { baseUrl } from "../commons.js";
import { getToken } from "../helpers";
import axios from "axios";

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
    // getQueries() {
    //   return axios.get(endPoint, { headers });
    // },
    // postQuery(data) {
    //   return axios.post(endPoint, data, { headers });
    // }
  }
};

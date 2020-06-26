import axios from "axios";

const baseUrl = location.origin;
const endPoint = `${baseUrl}/api/v1/plans`;
const headers = {
  "Content-type": "application/json",
  Authorization: window.gobiertoAPI.token
};

// Plans-endpoint factory to get/post/put/delete API data
export const PlansFactoryMixin = {
  methods: {
    getPlan(id) {
      return axios.get(`${endPoint}/${id}`, { headers })
    },
    getProjects(id) {
      return axios.get(`${endPoint}/${id}/projects`, { headers })
    },
    getMeta(id) {
      return axios.get(`${endPoint}/${id}/meta`, { headers })
    }
  }
};

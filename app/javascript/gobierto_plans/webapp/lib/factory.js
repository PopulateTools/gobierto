import axios from "axios";

const baseUrl = location.origin;
const endPoint = `${baseUrl}/api/v1/plans`;
const headers = {
  "Content-type": "application/json",
  Authorization: window.gobiertoAPI.token
};

import FAKE from "./FAKE.JSON";

// Plans-endpoint factory to get/post/put/delete API data
export const PlansFactoryMixin = {
  methods: {
    getPlan(id) {
      return axios.get(`${endPoint}/${id}`, { headers })
        .catch(() => {
          // TODO: Eliminar cuando la API devuelva bien
          return { data: FAKE }
        });
    },
    getProjects(id) {
      return axios.get(`${endPoint}/${id}/projects`, { headers });
    },
    getProjectsByUrl(url) {
      return axios.get(url, { headers });
    }
  }
};

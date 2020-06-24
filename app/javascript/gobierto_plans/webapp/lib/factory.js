import axios from "axios";

const baseUrl = location.origin;
const endPoint = `${baseUrl}/api/v1/plans`;
const headers = {
  "Content-type": "application/json",
  Authorization: window.gobiertoAPI.token
};

import categories from "./fake_categories.json";
import projects from "./fake_projects.json";

// Plans-endpoint factory to get/post/put/delete API data
export const PlansFactoryMixin = {
  methods: {
    getPlan(id) {
      return axios.get(`${endPoint}/${id}`, { headers })
        .catch(() => {
          // TODO: Eliminar cuando la API devuelva bien
          return { data: categories }
        });
    },
    getProjects(id) {
      return axios.get(`${endPoint}/${id}/projects`, { headers })
        .catch(() => {
          // TODO: Eliminar cuando la API devuelva bien
          return { data: projects }
        });
    },
    getProjectsByUrl(url) {
      return axios.get(url, { headers });
    }
  }
};

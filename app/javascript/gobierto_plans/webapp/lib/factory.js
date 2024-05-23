import axios from 'axios';

const baseUrl = location.origin;
const endPoint = `${baseUrl}/api/v1/plans`;
const headers = {};

// Plans-endpoint factory to get/post/put/delete API data
export const PlansFactoryMixin = {
  methods: {
    searchParams(params) {
      return new URLSearchParams({ locale: I18n.locale, ...params })
    },
    getPlan(id, params) {
      return axios.get(`${endPoint}/${id}`, { headers, params: this.searchParams(params) })
    },
    getProjects(id, params) {
      return axios.get(`${endPoint}/${id}/projects`, { headers, params: this.searchParams(params) })
    },
    getMeta(id, params) {
      return axios.get(`${endPoint}/${id}/meta`, { headers, params: this.searchParams(params) })
    }
  }
};

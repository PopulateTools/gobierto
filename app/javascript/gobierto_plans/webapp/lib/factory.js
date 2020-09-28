import axios from "axios";

const baseUrl = location.origin;
const endPoint = `${baseUrl}/api/v1/plans`;

const headers = {
  "Content-type": "application/json"
};

// Plans-endpoint factory to get/post/put/delete API data
export const PlansFactoryMixin = {
  locale: I18n.locale,
  methods: {
    getPlan(id, params) {
      const qs = new URLSearchParams({ locale: this.$options.locale, ...params })
      return axios.get(`${endPoint}/${id}?${qs.toString()}`, { headers })
    },
    getProjects(id, params) {
      const qs = new URLSearchParams({ locale: this.$options.locale, ...params })
      return axios.get(`${endPoint}/${id}/projects?${qs.toString()}`, { headers })
    },
    getMeta(id, params) {
      const qs = new URLSearchParams({ locale: this.$options.locale, ...params })
      return axios.get(`${endPoint}/${id}/meta?${qs.toString()}`, { headers })
    }
  }
};

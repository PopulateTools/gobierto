import axios from "axios";

const baseUrl = `${location.origin}` // TODO: edit once the proper endpoint will be ready
const endPoint = `${baseUrl}`;
const headers = {
  "Content-type": "application/json",
  Authorization: window.gobiertoAPI.token
};

// Plans-endpoint factory to get/post/put/delete API data
export const PlansFactoryMixin = {
  methods: {
    getPlans(params) {
      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`, { headers });
    },
  }
};

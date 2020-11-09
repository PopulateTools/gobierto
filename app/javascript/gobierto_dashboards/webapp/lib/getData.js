import axios from "axios";

//TODO changes to location.origin
const endPoint = `https://getafe.gobify.net/api/v1/data/data.json`

export const getDataMixin = {
  methods: {
    getData(params) {
      const qs = new URLSearchParams(params)
      return axios.get(`${endPoint}?${qs.toString()}`);
    },
  }
};

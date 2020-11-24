import axios from "axios";

const baseUrl = location.origin;
const endPointDashboard = `${baseUrl}/api/v1/dashboard`;
const endPointData = `${baseUrl}/api/v1/dashboard_data`;
const headers = new Headers({
  "Content-type": "application/json"
});

// DEBUG
import { Mock } from "./mock__DELETABLE";
axios.interceptors.response.use(() => {}, () => new Mock().dashboard);
// END DEBUG

export const DashboardFactoryMixin = {
  methods: {
    searchParams(params) {
      return new URLSearchParams({ locale: I18n.locale, ...params })
    },
    getDashboards(params) {
      return axios.get(`${endPointDashboard}?${this.searchParams(params).toString()}`, { headers })
    },
    getDashboard(id, params) {
      return axios.get(`${endPointDashboard}/${id}?${this.searchParams(params).toString()}`, { headers })
    },
    postDashboard(data, params) {
      return axios.post(`${endPointDashboard}?${this.searchParams(params).toString()}`, data, { headers })
    },
    putDashboard(id, data, params) {
      return axios.put(`${endPointDashboard}/${id}?${this.searchParams(params).toString()}`, data, { headers })
    },
    deleteDashboard(id, params) {
      return axios.delete(`${endPointDashboard}/${id}?${this.searchParams(params).toString()}`, { headers })
    },
    getData(params) {
      return axios.get(`${endPointData}?${this.searchParams(params).toString()}`, { headers })
    },
  }
};

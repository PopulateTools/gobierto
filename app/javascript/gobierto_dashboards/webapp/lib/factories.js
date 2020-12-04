import axios from "axios";

const baseUrl = location.origin;
const endPointDashboard = `${baseUrl}/api/v1/dashboards`;
const endPointData = `${baseUrl}/api/v1/dashboard_data`;
const headers = new Headers({
  "Content-type": "application/json"
});

// DEBUG
import { Mock } from "./mock__DELETABLE";
axios.interceptors.response.use(() => {}, ({ config: { url } }) => {
  const { dashboard, dashboardData, dashboards } = new Mock()
  switch (true) {
    case url.includes("dashboard_data"):
      return dashboardData
    case /dashboards\/.+/.test(url):
      return dashboard
    default:
      return dashboards
  }
});
// END DEBUG

export const FactoryMixin = {
  methods: {
    searchParams(params) {
      return new URLSearchParams({ locale: I18n.locale, ...params })
    },
    getDashboards(params) {
      return axios.get(endPointDashboard, { headers, params: this.searchParams(params) })
    },
    getDashboard(id, params) {
      return axios.get(`${endPointDashboard}/${id}`, { headers, params: this.searchParams(params) })
    },
    postDashboard(data, params) {
      return axios.post(endPointDashboard, data, { headers, params: this.searchParams(params) })
    },
    putDashboard(id, data, params) {
      return axios.put(`${endPointDashboard}/${id}`, data, { headers, params: this.searchParams(params) })
    },
    deleteDashboard(id, params) {
      return axios.delete(`${endPointDashboard}/${id}`, { headers, params: this.searchParams(params) })
    },
    getData(params) {
      return axios.get(endPointData, { headers, params: this.searchParams(params) })
    },
  }
};
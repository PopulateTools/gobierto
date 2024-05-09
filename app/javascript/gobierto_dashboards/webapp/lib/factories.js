import axios from 'axios';

const baseUrl = location.origin;
const endPointDashboard = `${baseUrl}/api/v1/dashboards`;
const endPointData = `${baseUrl}/api/v1/dashboard_data`;
const defaultHeaders = {};

export const FactoryMixin = {
  methods: {
    getHeaders() {
      let headers = {};
      if (window.GobiertoAdmin && window.GobiertoAdmin.token) {
        headers = {
          Authorization: `Bearer ${window.GobiertoAdmin.token}`
        };
      }
      return { ...defaultHeaders, ...headers };
    },
    searchParams(params) {
      return new URLSearchParams(params);
    },
    getDashboards(params) {
      return axios.get(endPointDashboard, {
        headers: this.getHeaders(),
        params: this.searchParams({ locale: I18n.locale, ...params })
      });
    },
    getDashboard(id, params) {
      return axios.get(`${endPointDashboard}/${id}`, {
        headers: this.getHeaders(),
        params: this.searchParams({ locale: I18n.locale, ...params })
      });
    },
    postDashboard(data, params) {
      return axios.post(
        endPointDashboard,
        { data },
        { headers: this.getHeaders(), params: this.searchParams(params) }
      );
    },
    putDashboard(id, data, params) {
      return axios.put(
        `${endPointDashboard}/${id}`,
        { data },
        { headers: this.getHeaders(), params: this.searchParams(params) }
      );
    },
    deleteDashboard(id, params) {
      return axios.delete(`${endPointDashboard}/${id}`, {
        headers: this.getHeaders(),
        params: this.searchParams(params)
      });
    },
    getData(params) {
      return axios.get(endPointData, {
        headers: this.getHeaders(),
        params: this.searchParams({ locale: I18n.locale, ...params })
      });
    }
  }
};

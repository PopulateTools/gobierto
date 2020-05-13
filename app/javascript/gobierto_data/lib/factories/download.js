import { baseUrl } from '../commons.js';
import axios from 'axios';

const endPoint = `${baseUrl}/data.`;

// Factor to force download files in multiple formats
export const DownloadFilesFactoryMixin = {
  methods: {
    createObjectFormatsQuery(sql) {
      //Get the formats from API
      const keyFormats = Object.keys(this.arrayFormats)

      //Create an object to parse query, is the same method which use to run a query. If we don't do this we've to use regex and replace to encode URL with too hacks https://stackoverflow.com/a/32882427
      const objectSql = { sql: sql }
      let queryUrl = new URLSearchParams(objectSql);

      let datetime = new Date();
      const date = `${datetime.getDate()}_${(datetime.getMonth() + 1)}_${datetime.getFullYear()}`;

      const {
        params: {
          id: titleFile
        }
      } = this.$route

      this.titleFile = titleFile

      for (let i = 0; i < keyFormats.length; i++) {
        this.arrayFormatsQuery[i] = {
          label: keyFormats[i],
          url: `${endPoint}${keyFormats[i]}?${queryUrl.toString()}`,
          name: `${titleFile}_${date}.${keyFormats[i]}`
        };
      }

    },
    getFiles(url, name) {
      return axios
        .get(url, { responseType: 'blob' })
        .then(response => {
          const blob = new Blob([response.data], { type: 'text/plain' });
          const link = document.createElement('a');
          link.href = URL.createObjectURL(blob);
          link.download = name;
          link.click();
          URL.revokeObjectURL(link.href);
        })
        .catch(console.error);
    }
  }
};

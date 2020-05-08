import { baseUrl } from '../commons.js';
import axios from 'axios';

const endPoint = `${baseUrl}/data.`;

// Factor to force download files in multiple formats
export const DownloadFilesFactoryMixin = {
  methods: {
    createObjectFormatsQuery(sql) {

      //Get the formats from API
      const keyFormats = Object.keys(this.arrayFormats)
      //Convert all linebreaks from any SO(Windows: \r\n Linux: \n Older Macs: \r) to spaces.
      const formatSQL = sql.replace(/[\r\n]+/gm, " ");
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
          url: `${endPoint}${keyFormats[i]}?sql=${formatSQL}`,
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

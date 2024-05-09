import { json } from 'd3-fetch';

export class Card {
  constructor(divClass) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;

    const container = document.querySelector(this.container);
    this.trend = container.dataset.trend;
    this.freq = container.dataset.freq;
  }

  handlePromise(url, opts = {}) {
    return json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    });
  }

  render() {
    var data = this.handlePromise(
      window.populateData.endpoint + this.query.trim().replace(/\s\s/g, "")
    );
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(response => this.getData(response));
  }

  getMetadataEndpoint(dataset) {
    return window.populateData.endpoint.replace(
      "data.json?sql=",
      `datasets/${dataset}/meta`
    );
  }

  getMetadataFields(metadata) {
    return {
      source_name: metadata.data.attributes["dataset-source"],
      source_url: metadata.data.attributes["dataset-source-url"],
      description: metadata.data.attributes.description,
      frequency_type:
        metadata.data.attributes.frequency[0].name_translations[I18n.locale],
      updated_at: metadata.data.attributes.data_updated_at
    };
  }

  _normalize(str) {
    var from =
        "1234567890ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ‘/&().!,'",
      to = "izeasgtogoAAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_______",
      mapping = {};

    for (let i = 0, j = from.length; i < j; i++) {
      mapping[from.charAt(i)] = to.charAt(i);
    }

    var ret = [];
    for (let i = 0, j = str.length; i < j; i++) {
      var c = str.charAt(i);
      if (Object.prototype.hasOwnProperty.call(mapping, str.charAt(i))) {
        ret.push(mapping[c]);
      } else {
        ret.push(c);
      }
    }

    return ret.join("").toLowerCase();
  }
}

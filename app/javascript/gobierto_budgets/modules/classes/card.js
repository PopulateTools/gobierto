import * as d3 from 'd3';
import { SimpleCard } from '../../../lib/visualizations';

export class Card {
  constructor(divClass) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;

    this.metadata = this.getMetadataEndpoint("presupuestos-municipales")
  }

  handlePromise(url, opts = {}) {
    return d3.json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    })
  }

  render() {
    this.getData();
  }

  getData() {
    var data = this.handlePromise(window.populateData.endpoint + encodeURIComponent(this.query.trim().replace(/\s\s/g, "")));
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var opts = {
        metadata: this.getMetadataFields(jsonMetadata),
        cardName: this.cardName
      };

      if (jsonData.data.length) {
        new SimpleCard(this.container, jsonData.data, opts);
      } else {
        console.warn(`No data found for cardName: ${this.cardName}`)
      }
    })
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
      description: metadata.data.attributes.description,
      frequency_type:
        metadata.data.attributes.frequency[0].name_translations[
          I18n.locale
        ],
      updated_at: metadata.data.attributes.data_updated_at
    }
  }
}

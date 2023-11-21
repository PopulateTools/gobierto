import { json } from "d3-fetch";
import { SimpleCard } from "lib/visualizations";

export class Card {
  constructor(divClass, current_year) {
    this.container = divClass;
    this.currentYear =
      current_year !== undefined ? parseInt(current_year) : null;
    this.tbiToken = window.populateData.token;

    this.metadata = this.getMetadataEndpoint("presupuestos-municipales")
  }

  handlePromise(url, opts = {}) {
    return json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    });
  }

  render() {
    this.getData();
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var opts = {
        metadata: this.getMetadataFields(jsonMetadata),
        cardName: this.cardName
      };

      new SimpleCard(this.container, jsonData.data, opts);
    });
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

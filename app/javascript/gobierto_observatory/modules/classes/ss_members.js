import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ssMembersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT year, SUM(value::integer) AS value,
        CONCAT(year, '-', 1, '-', 1) AS date
        FROM afiliados_seguridad_social
          WHERE
            place_id = ${city_id}
        GROUP BY year
        Order BY year DESC limit 5
      `;
    this.metadata = window.populateData.endpoint.replace("data.json?sql=", "datasets/afiliados-seguridad-social/meta")
  }

  getData() {
    var data = this.handlePromise(this.url);
    var getMetaData = this.handlePromise(this.metadata);

    getMetaData.then(jsonMetaData => {

      data.then(jsonData => {
        var value = jsonData.data[0].value;
        var newMetadata = {
          "indicator": {
            "source_name": jsonMetaData.data.attributes["dataset-source"],
            "description": jsonMetaData.data.attributes.description,
            "frequency_type": jsonMetaData.data.attributes.frequency[0].name_translations[I18n.locale]
          }
        };

        jsonData.metadata = newMetadata

        new SimpleCard(this.container, jsonData, value, "ss_members");
      });
    });
  }
}

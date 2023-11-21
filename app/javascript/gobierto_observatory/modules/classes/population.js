import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields } from "../helpers.js";

export class PopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        SUM(total::integer) AS value
      FROM poblacion_edad_sexo
      WHERE
        place_id = ${city_id} AND
        sex = 'Total'
      GROUP BY year
      ORDER BY 1 DESC
      LIMIT 5
      `;
    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/poblacion-edad-sexo/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "population"
      };

      new SimpleCard(this.container, jsonData.data, opts);
    });
  }
}

import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ActivePopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.activePopUrl =
      window.populateData.endpoint +
      `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        SUM(total::integer) AS value
      FROM poblacion_edad_sexo
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM poblacion_edad_sexo ) AND
        age >= 16 AND
        sex = 'Total'
      GROUP BY year
      `;

    this.popUrl =
      window.populateData.endpoint +
      `
      SELECT
        SUM(total::integer) AS value
      FROM poblacion_edad_sexo
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM poblacion_edad_sexo ) AND
        sex = 'Total'
      `;

    this.metadata = this.getMetadataEndpoint("poblacion-edad-sexo")
  }

  getData() {
    var active = this.handlePromise(this.activePopUrl);
    var pop = this.handlePromise(this.popUrl);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([active, pop, metadata]).then(
      ([jsonActive, jsonPop, jsonMetadata]) => {
        var value = jsonActive.data[0].value;
        var rate = (value / jsonPop.data[0].value) * 100;

        var opts = {
          metadata: this.getMetadataFields(jsonMetadata),
          cardName: "active_pop"
        };

        new ComparisonCard(this.container, rate, value, opts);
      }
    );
  }
}

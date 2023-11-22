import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ActivePopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      WITH maxyear AS
        (SELECT max(YEAR)
        FROM poblacion_edad_sexo
        WHERE place_id = ${city_id}) ,
          pob_total AS
        (SELECT SUM(total::integer) AS value
        FROM poblacion_edad_sexo
        WHERE place_id = ${city_id}
          AND sex = 'Total'
          AND YEAR =
            (SELECT *
              FROM maxyear))
      SELECT
        (SUM(total::decimal) / (SELECT value FROM pob_total)) * 100 AS rate,
        SUM(total::decimal) AS value
      FROM poblacion_edad_sexo
      WHERE place_id = ${city_id}
        AND YEAR =
          (SELECT *
          FROM maxyear)
        AND age >= 16
        AND sex = 'Total'
      `;

    this.metadata = this.getMetadataEndpoint("poblacion-edad-sexo");
  }

  getData([jsonData, jsonMetadata]) {
    const [{ rate, value }] = jsonData.data;

    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "active_pop"
    };

    new ComparisonCard(this.container, rate, value, opts);
  }
}

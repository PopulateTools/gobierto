import { BarsCard } from '../../../lib/visualizations';
import { Card } from './card.js';

export class CarsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      WITH
        maxyear AS (SELECT max(year) FROM coches WHERE place_id = ${city_id}),
        population AS (
          SELECT
            SUM(total::integer)
          FROM poblacion_edad_sexo
          WHERE
            place_id = ${city_id}
          AND sex = 'Total'
          AND year = (SELECT * FROM maxyear)
        ),
        population_prov AS (
          SELECT
            SUM(total::integer)
          FROM poblacion_edad_sexo
          WHERE
            place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
            AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
            AND sex = 'Total'
            AND year = (SELECT * FROM maxyear)
        ),
        population_country AS (
          SELECT
            SUM(total::integer)
          FROM poblacion_edad_sexo
          WHERE
            sex = 'Total'
          AND year = (SELECT * FROM maxyear)
        )
      SELECT
        1 as index,
        '${window.populateData.municipalityName}' as key,
        COALESCE(SUM(parque_total::decimal) / NULLIF((SELECT * FROM population), 0), 0) AS value
      FROM coches
      WHERE
        place_id = ${city_id}
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        2 as index,
        '${window.populateData.provinceName}' as key,
        COALESCE(SUM(parque_total::decimal) / NULLIF((SELECT * FROM population_prov), 0), 0) AS value
      FROM coches
      WHERE
        place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
        AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
        AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        3 as index,
        '${I18n.t("country")}' as key,
        COALESCE(SUM(parque_total::decimal) / NULLIF((SELECT * FROM population_country), 0), 0) AS value
      FROM coches
      WHERE
        year = (SELECT * FROM maxyear)
      ORDER BY index
      `;

    this.metadata = this.getMetadataEndpoint("coches");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "cars"
    };

    new BarsCard(this.container, jsonData.data, opts);
  }
}

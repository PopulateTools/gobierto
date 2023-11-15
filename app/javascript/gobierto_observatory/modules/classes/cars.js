import { BarsCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields, getProvinceIds } from "../helpers.js";

export class CarsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    const [lower, upper] = getProvinceIds(city_id);

    this.url =
      window.populateData.endpoint +
      `
      WITH
        maxyear AS (SELECT max(year) FROM coches WHERE place_id = ${city_id}),
        population AS (
          SELECT
            sum(total::integer)
          FROM poblacion_edad_sexo
          WHERE
            place_id = ${city_id}
          AND sex = 'Total'
          AND year = (SELECT * FROM maxyear)
        ),
        population_prov AS (
          SELECT
            sum(total::integer)
          FROM poblacion_edad_sexo
          WHERE
            place_id BETWEEN ${lower} AND ${upper}
          AND sex = 'Total'
          AND year = (SELECT * FROM maxyear)
        ),
        population_country AS (
          SELECT
            sum(total::integer)
          FROM poblacion_edad_sexo
          WHERE
            sex = 'Total'
          AND year = (SELECT * FROM maxyear)
        )
      SELECT
        1 as index,
        '${window.populateData.municipalityName}' as key,
        COALESCE(sum(parque_total::decimal) / NULLIF((SELECT * FROM population), 0), 0) AS value
      FROM coches
      WHERE
        place_id = ${city_id}
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        2 as index,
        '${window.populateData.provinceName}' as key,
        COALESCE(sum(parque_total::decimal) / NULLIF((SELECT * FROM population_prov), 0), 0) AS value
      FROM coches
      WHERE
        place_id BETWEEN ${lower} AND ${upper}
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        3 as index,
        '${I18n.t("country")}' as key,
        COALESCE(sum(parque_total::decimal) / NULLIF((SELECT * FROM population_country), 0), 0) AS value
      FROM coches
      WHERE
        year = (SELECT * FROM maxyear)
      ORDER BY index
      `;

    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/coches/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      const parsedData = jsonData.data.map(x => ({ ...x, value: Number(x.value) }))

      new BarsCard(this.container, parsedData, {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "cars"
      });
    });
  }
}

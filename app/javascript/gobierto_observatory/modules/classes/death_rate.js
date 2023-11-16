import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields, getProvinceIds } from "../helpers.js";
import { groupBy } from "../helpers";

export class DeathRateCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    const [lower, upper] = getProvinceIds(city_id);

    this.url =
    window.populateData.endpoint +
    `
    (
      SELECT
        1 AS index,
        'place' AS key,
        year AS date,
        value::decimal AS value
      FROM tasa_mortalidad
      WHERE
        place_id = ${city_id}
      ORDER BY year DESC
      LIMIT 2
    )
    UNION
    (
      SELECT
        2 AS index,
        'province' AS key,
        year AS date,
        AVG(value::decimal) AS value
      FROM tasa_mortalidad
      WHERE
        place_id between ${lower} and ${upper}
      GROUP BY year
      ORDER BY year DESC
      LIMIT 2
    )
    UNION
    (
      SELECT
        3 AS index,
        'country' AS key,
        year AS date,
        AVG(value::decimal) AS value
      FROM tasa_mortalidad
      GROUP BY year
      ORDER BY year DESC
      LIMIT 2
    )
    ORDER BY index, date DESC
    `;

  this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/tasa-mortalidad/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      const locationType = groupBy(jsonData.data, "key");

      // transform the data for the chart
      const nestData = Object.entries(locationType).map(([key, values]) => ({
        key,
        value: values[0].value,
        diff: (values[0].value / values[1].value - 1) * 100,
        title: I18n.t(`gobierto_common.visualizations.cards.births.${key}`, {
          place: window.populateData.municipalityName
        })
      }));

      // include empty records
      while (nestData.length < 3) {
        nestData.unshift({
          value: "--",
          diff: "--",
          title: "No hay datos"
        })
      }

      new SparklineTableCard(this.container, nestData, {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "deaths"
      });

      Object.entries(locationType).forEach(([key, values]) => {
        const spark = new Sparkline(
          `${this.container} .sparkline-${key}`,
          values,
          {
            trend: this.trend
          }
        );

        spark.render();
      });
    });
  }
}

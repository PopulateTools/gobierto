import { nest } from "d3-collection";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { groupBy } from "../helpers";
import { Card } from "./card.js";
import { getMetadataFields, getProvinceIds } from "../helpers.js";

export class BirthRateCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    const [lower, upper] = getProvinceIds(city_id);

    this.url =
      window.populateData.endpoint +
      `
      (
        SELECT
          1 as index,
          CONCAT(year, '-', 1, '-', 1) AS date,
          value::decimal AS value
        FROM tasa_natalidad
        WHERE
          place_id = ${city_id}
        ORDER BY year DESC
        LIMIT 5
      )
      UNION
      (
        SELECT
          2 as index,
          CONCAT(year, '-', 1, '-', 1) AS date,
          AVG(value::decimal) AS value
        FROM tasa_natalidad
        WHERE
          place_id between ${lower} and ${upper}
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      UNION
      (
        SELECT
          3 as index,
          CONCAT(year, '-', 1, '-', 1) AS date,
          AVG(value::decimal) AS value
        FROM tasa_natalidad
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      ORDER BY index
      `;

    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/tasa-natalidad/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      // d3v5
      //
      const nestData = nest()
        .key(d => d.location_type)
        .rollup(v => ({
          value: v[0].figure,
          diff: ((v[0].figure - v[1].figure) / v[1].figure) * 100
        }))
        .entries(jsonData.data)
        .map(d => ({
          ...d,
          title: d.key,
          diff: d.value.diff,
          value: d.value.value
        }));

      // d3v6
      //
      // nestData = rollup(
      //   jsonData.data,
      //   v => ({
      //     value: v[0].figure,
      //     diff: ((v[0].figure - v[1].figure) / v[1].figure) * 100
      //   }),
      //   d => d.location_type
      // );
      // // Convert map to specific array
      // nestData = Array.from(nestData, ([key, { value, diff }]) => ({
      //   key,
      //   value,
      //   diff
      // }));

      new SparklineTableCard(this.container, nestData, {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "births"
      });

      /* Sparklines */
      var opts = {
        trend: this.trend,
        freq: this.freq
      };

      const locationType = groupBy(jsonData.data, "location_type");
      Object.entries(locationType).forEach(([key, values]) => {
        const spark = new Sparkline(
          `${this.container} .sparkline-${key}`,
          values,
          opts
        );

        spark.render();
      });
    });
  }
}

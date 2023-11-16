import { nest } from "d3-collection";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields, getProvinceIds, groupBy } from "../helpers";

export class InvestmentByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    const [lower, upper] = getProvinceIds(city_id);

    this.url =
      window.populateData.endpoint +
      `
      (
        SELECT
          1 as index,
          '${window.populateData.municipalityName}' as key,
          CONCAT(year, '-', 1, '-', 1) AS date,
          SUM(amount_per_inhabitant::decimal) as value
        FROM presupuestos_municipales
        WHERE
          place_id = ${city_id}
        AND area = 'e' and kind = 'G' and code IN ('6','7')
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      UNION
      (
        SELECT
          2 as index,
          '${window.populateData.provinceName}' as key,
          CONCAT(year, '-', 1, '-', 1) AS date,
          AVG(amount_per_inhabitant::decimal) as value
        FROM presupuestos_municipales
        WHERE
          place_id between ${lower} and ${upper}
        AND area = 'e' and kind = 'G' and code IN ('6','7')
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      UNION
      (
        SELECT
          3 as index,
          '${I18n.t("country")}' as key,
          CONCAT(year, '-', 1, '-', 1) AS date,
          AVG(amount_per_inhabitant::decimal) as value
        FROM presupuestos_municipales
        WHERE
          area = 'e' and kind = 'G' and code IN ('6','7')
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      ORDER BY index
      `;

    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/presupuestos-municipales/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      this.data = jsonData.data;

      // d3v5
      //
      this.nest = nest()
        .key(function(d) {
          return d.key;
        })
        .rollup(function(v) {
          return {
            value: v[0].value,
            diff: v[1].value ? ((v[0].value - v[1].value) / v[1].value) * 100 : 0
          };
        })
        .entries(this.data);

      this.nest.forEach(
        function(d) {
          d.title = d.key
          d.key = this._normalize(d.key)
          d.diff = d.value.diff;
          d.value = d.value.value;
        }.bind(this)
      );

      // d3v6
      //
      // this.nest = rollup(
      //   this.data,
      //   v => ({
      //     value: v[0].value,
      //     diff: ((v[0].value - v[1].value) / v[1].value) * 100
      //   }),
      //   d => d.row
      // );

      // // Convert map to specific array
      // this.nest = Array.from(this.nest, ([key, { value, diff }]) => ({
      //   key,
      //   value,
      //   diff
      // }));

      new SparklineTableCard(this.container, this.nest, {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "investment_by_inhabitant"
      });

      /* Sparklines */
      var opts = {
        trend: this.trend,
        freq: this.freq
      };

      const locations = groupBy(jsonData.data, "key");
      Object.entries(locations).forEach(([key, values]) => {
        const sorted = values.sort((a, b) => a.date < b.date ? 1 : -1)

        const spark = new Sparkline(
          `${this.container} .sparkline-${this._normalize(key)}`,
          sorted,
          opts
        );

        spark.render();
      });
    });
  }
}

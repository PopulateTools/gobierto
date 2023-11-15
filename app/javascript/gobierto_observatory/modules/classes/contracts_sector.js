import { nest } from "d3-collection";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { getMetadataFields, groupBy } from "../helpers";
import { Card } from "./card.js";

export class ContractsBySectorCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT
        value,
        CONCAT(year, '-', month, '-', 1) AS date,
        sector
      FROM contratos_sectores
      WHERE
        place_id = ${city_id}
      ORDER BY year DESC, month DESC
      LIMIT 50
      `;
    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/contratos-sectores/meta"
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
          return d.sector;
        })
        .rollup(function(v) {
          return {
            value: v[0].value,
            diff: ((v[0].value - v[1].value) / v[1].value) * 100
          };
        })
        .entries(this.data);

      this.nest.forEach(
        function(d) {
          d.key, (d.diff = d.value.diff), (d.value = d.value.value);
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
      //   d => d.sector
      // );

      // // Convert map to specific array
      // this.nest = Array.from(this.nest, ([key, { value, diff }]) => ({
      //   key,
      //   value,
      //   diff
      // }));

      new SparklineTableCard(this.container, jsonData.data, {
        metadata: getMetadataFields(jsonMetadata),
        value: this.nest,
        cardName: "contracts_sector"
      });

      /* Sparklines */
      var opts = {
        trend: this.trend,
        freq: this.freq
      };

      const sectors = groupBy(jsonData.data, "sector");
      Object.entries(sectors).forEach(([key, values]) => {
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

import { nest as nestFn } from "d3-collection";
import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ContractsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint + `
      SELECT SUM(value::integer) AS value, type
      FROM contratos_personas WHERE place_id = ${city_id}
      AND year = (SELECT year FROM contratos_personas ORDER BY year DESC, month DESC LIMIT 1)
      AND month = (SELECT month FROM contratos_personas ORDER BY year DESC, month DESC LIMIT 1)
      GROUP BY type
      `;
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then(json => {
      // d3v5
      //
      var nest = nestFn()
        .key(function(d) {
          return d.type;
        })
        .entries(json.data);
      // d3v6
      //
      // var nest = Array.from(group(json.data, d => d.type), ([key, values]) => ({
      //   key,
      //   values
      // }));

      var i = nest.filter(d => d.key === "undefined")[0].values[0].value;
      var t = nest.filter(d => d.key === "temporary")[0].values[0].value;

      new ComparisonCard(this.container, json, t, i, "contracts_comparison");
    });
  }
}

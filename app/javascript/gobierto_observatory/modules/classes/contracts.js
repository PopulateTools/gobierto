import { group } from "d3-array";
import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ContractsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      "/datasets/ds-contratos-municipio-tipo.json?sort_desc_by=date&with_metadata=true&limit=3&filter_by_location_id=" +
      city_id;
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then(json => {
      var nest = Array.from(group(json.data, d => d.type), ([key, values]) => ({
        key,
        values
      }));

      var i = nest.filter(d => d.key === "INI-I")[0].values[0].value;
      var t = nest.filter(d => d.key === "INI-T")[0].values[0].value;

      new ComparisonCard(this.container, json, t, i, "contracts_comparison");
    });
  }
}

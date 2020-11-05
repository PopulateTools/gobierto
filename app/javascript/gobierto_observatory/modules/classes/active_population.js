import { Card } from "./card.js";
import { ComparisonCard } from "lib/visualizations";

export class ActivePopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.activePopUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-activa-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=" +
      city_id;
    this.popUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=" +
      city_id;
  }

  getData() {
    var active = this.handlePromise(this.activePopUrl);
    var pop = this.handlePromise(this.popUrl);

    Promise.all([active, pop]).then(([jsonActive, jsonPop]) => {
      var value = jsonActive.data[0].value;
      var rate = (value / jsonPop.data[0].value) * 100;

      new ComparisonCard(this.container, jsonActive, rate, value, "active_pop");
    });
  }
}

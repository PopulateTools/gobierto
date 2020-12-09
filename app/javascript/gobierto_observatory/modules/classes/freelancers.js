import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class FreelancersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      "/datasets/ds-autonomos-municipio.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=" +
      city_id;
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then(jsonData => {
      var value = jsonData.data[0].value;

      new SimpleCard(this.container, jsonData, value, "freelancers");
    });
  }
}

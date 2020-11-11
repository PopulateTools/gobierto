import { json } from "d3-request";
import { queue } from "d3-queue";
import { Card } from './card.js'
import { SimpleCard } from 'lib/visualizations'

const d3 = { json, queue }

export class FreelancersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.url = window.populateData.endpoint + '/datasets/ds-autonomos-municipio.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
  }

  getData() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(data.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        new SimpleCard(this.container, jsonData, value, 'freelancers');
      }.bind(this));
  }
}

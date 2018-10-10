import * as d3 from 'd3'
import { Card } from './card.js'
import { SimpleCard } from 'lib/visualizations'

export class ssMembersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.url = window.populateData.endpoint + '/datasets/ds-afiliados-ss-municipio.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
  }

  getData() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(data.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        new SimpleCard(this.container, jsonData, value, 'ss_members');
      }.bind(this));
  }
}

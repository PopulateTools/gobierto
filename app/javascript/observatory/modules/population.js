import * as d3 from 'd3'
import { SimpleCard } from './vis_card_simple.js'

export class PopulationCard {
  constructor(divClass, city_id) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
  }

  getData() {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        new SimpleCard(this.container, jsonData, value, 'population');
      }.bind(this));
  }
  
  render() {
    this.getData();
  }
}

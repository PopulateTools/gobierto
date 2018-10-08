import * as d3 from 'd3'
import { SimpleCard } from './vis_card_simple.js'

export class CompaniesCard {
  constructor(divClass, city_id) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.url = window.populateData.endpoint + '/datasets/ds-empresas-municipio.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_location_id=' + city_id;
  }

  getData() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(data.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        new SimpleCard(this.container, jsonData, value, 'companies');
      }.bind(this));
  }

  render() {
    this.getData();
  }
}

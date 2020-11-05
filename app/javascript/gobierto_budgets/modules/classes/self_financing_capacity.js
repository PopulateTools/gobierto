import { json } from 'd3-fetch'
import { Card } from './card.js'
import { SimpleCard } from 'lib/visualizations'

export class SelfFinancingCapacityCard extends Card {
  constructor(divClass, city_id, current_year) {
    super(divClass, current_year)

    this.popUrl = window.populateData.endpoint + '/datasets/ds-capacidad-autofinanciacion.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=' + city_id + '&date_date_range=20100101-' + this.currentYear + '1231';
  }

  getData() {
    var data = json(this.popUrl, { headers: new Headers({ 'authorization': 'Bearer ' + this.tbiToken }) })

    data.then(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        new SimpleCard(this.container, jsonData, value, 'self_financing_capacity');
      }.bind(this));
  }
}

import * as d3 from 'd3'
import { Card } from './card.js'
import { ComparisonCard } from 'lib/visualizations'

export class HousesCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.famUrl = window.populateData.endpoint + '/datasets/ds-viviendas-municipales-familiares.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.mainUrl = window.populateData.endpoint + '/datasets/ds-viviendas-municipales-principales.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
  }

  getData() {
    var fam = d3.json(this.famUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var main = d3.json(this.mainUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(fam.get)
      .defer(main.get)
      .await(function (error, jsonFamily, jsonMain) {
        if (error) throw error;

        var familyHouses = jsonFamily.data[0].value;
        var mainHouses = jsonMain.data[0].value;

        new ComparisonCard(this.container, jsonFamily, familyHouses, mainHouses, 'houses');
      }.bind(this));
  }
}

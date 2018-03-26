import { Class, d3 } from 'shared'
import { ComparisonCard } from './vis_card_comparision.js'

export var HousesCard = Class.extend({
  init: function(divClass, city_id) {
    this.container = divClass;
    this.tbiToken = window.populateData.token;
    this.famUrl = window.populateData.endpoint + '/datasets/ds-viviendas-municipales-familiares.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
    this.mainUrl = window.populateData.endpoint + '/datasets/ds-viviendas-municipales-principales.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=' + city_id;
  },
  getData: function() {
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
  },
  render: function() {
    this.getData();
  }
});

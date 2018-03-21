'use strict';

var PerCapitaTaxBurdenCard = Class.extend({
  init: function(divClass, city_id, current_year) {
    this.container = divClass;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.tbiToken = window.populateData.token;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-presion-fiscal-por-habitante.json?sort_desc_by=date&with_metadata=true&limit=5&filter_by_municipality_id=' + city_id + '&date_date_range=20100101-' + this.currentYear + '1231';
  },
  getData: function() {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        var value = jsonData.data[0].value;

        if (value == 0) {
          var divContainer = $('div[class*="' + this.container.replace('.','') + '"]');
          divContainer.hide();
        } else {
          new SimpleCard(this.container, jsonData, value, 'per_capita_tax_burden');
        }
      }.bind(this));
  },
  render: function() {
    this.getData();
  }
});

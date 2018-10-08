import * as d3 from 'd3'
import { BarsCard } from './vis_card_bars.js'

export class DebtByInhabitantCard {
  constructor(divClass, city_id) {
    this.container = divClass;
    this.div = d3.select(this.container);
    this.tbiToken = window.populateData.token;
    this.url = window.populateData.endpoint + '/datasets/ds-deuda-municipal.json?divided_by=ds-poblacion-municipal&sort_desc_by=date&with_metadata=true&filter_by_location_id=' + city_id;
    this.bcnUrl = window.populateData.endpoint + '/datasets/ds-deuda-municipal.json?divided_by=ds-poblacion-municipal&sort_desc_by=date&with_metadata=true&filter_by_location_id=08019';  // TODO: Use Populate Data's related cities API
    this.vlcUrl = window.populateData.endpoint + '/datasets/ds-deuda-municipal.json?divided_by=ds-poblacion-municipal&sort_desc_by=date&with_metadata=true&filter_by_location_id=46250';  // TODO: Use Populate Data's related cities API
    this.trend = this.div.attr('data-trend');
    this.freq = this.div.attr('data-freq');
  }

  getData() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var bcn = d3.json(this.bcnUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    var vlc = d3.json(this.vlcUrl)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(data.get)
      .defer(bcn.get)
      .defer(vlc.get)
      .await(function (error, json, bcn, vlc) {
        if (error) throw error;

        json.data.forEach(function(d) {
          d.figure = d.divided_by_value;
          d.key = window.populateData.municipalityName;
        });

        bcn.data.forEach(function(d) {
          d.figure = d.divided_by_value;
          d.key = 'Barcelona';
        });

        vlc.data.forEach(function(d) {
          d.figure = d.divided_by_value;
          d.key = 'Valencia';
        });

        this.data = [json.data[0], bcn.data[0], vlc.data[0]];

        new BarsCard(this.container, json, this.data, 'debt_by_inhabitant');
      }.bind(this));
  }

  render() {
    this.getData();
  }

}

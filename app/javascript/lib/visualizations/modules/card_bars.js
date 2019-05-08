import * as d3 from 'd3'
import { Card } from './card.js'

export class BarsCard extends Card {
  constructor(divClass, json, data, cardName) {
    super(divClass)

    this.dataType = this.div.attr('data-type');

    var freq = this.div.attr('data-freq');
    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%b %Y");
    var isMobile = innerWidth <= 768;

    this.div.selectAll('.tw-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://twitter.com/intent/tweet?text=' + I18n.t('gobierto_common.visualizations.where') + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(I18n.t('gobierto_common.visualizations.cards.' + cardName + '.title')).toLowerCase() + I18n.t('gobierto_common.visualizations.time') + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(this._printData(data[0].figure))  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

    this.div.selectAll('.fb-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href);

    // Append source
    this.div.selectAll('.widget_src')
      .attr('title', json.metadata.indicator['source_name'])
      .text(json.metadata.indicator['source_name']);

    // Append date of last data point
    this.div.selectAll('.widget_updated')
      .text(formatDate(parsedDate));

    // Append update frequency
    this.div.selectAll('.widget_freq')
      .text(this._printFreq(json.metadata.frequency_type));

    // Append metadata
    this.div.selectAll('.widget_title')
      .attr('title', I18n.t('gobierto_common.visualizations.cards.' + cardName + '.title'))
      .text(I18n.t('gobierto_common.visualizations.cards.' + cardName + '.title'));

    // Append backface info
    this.div.selectAll('.js-data-desc')
      .text(json.metadata.indicator.description);
    this.div.selectAll('.js-data-freq')
      .text(formatDate(parsedDate));

    // Paint bars
    var x = d3.scaleLinear()
      .range([0, isMobile ? 30 : 35])
      .domain([0, d3.max(data, function(d) { return d.figure; })]);

    var row = this.div.select('.bars')
      .selectAll('div')
      .data(data)
      .enter()
      .append('div')
      .attr('class', 'row');

    row.append('div')
      .attr('class', 'key')
      .text(function(d) { return d.key });

    row.append('div')
      .attr('class', 'bar')
      .style('width', function(d) { return x(d.figure) + '%'; });

    row.append('div')
      .attr('class', 'qty')
      .text(function(d) { return this._printData(d.figure); }.bind(this));
  }

}

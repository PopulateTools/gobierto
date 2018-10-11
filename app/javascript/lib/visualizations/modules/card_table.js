import * as d3 from 'd3'
import { Card } from './card.js'
import { accounting } from 'lib/shared'

export class TableCard extends Card {
  constructor(divClass, json, nest, cardName) {
    super(divClass)

    this.dataTypeOne = this.div.attr('data-type-one');
    this.dataTypeTwo = this.div.attr('data-type-two');

    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%b %Y");

    this.div.selectAll('.tw-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://twitter.com/intent/tweet?text=' + I18n.t('gobierto_common.visualizations.where') + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(I18n.t('gobierto_common.visualizations.cards.' + cardName + '.title')).toLowerCase() + I18n.t('gobierto_common.visualizations.time') + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(this._printData(nest[0].value.valueOne))  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

    this.div.selectAll('.fb-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href);

    // Append source
    this.div.selectAll('.widget_src')
      .attr('title', json.metadata.indicator['source name'])
      .text(json.metadata.indicator['source name']);

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

    var header = nest.map(function(d) {
      return I18n.t('gobierto_common.visualizations.cards.' + cardName + '.' + this._normalize(d.value.column));
    }.bind(this));

    var rows = nest.map(function(d) {
      return '<td>' + d.value.key + '</td> \
        <td class="right">' + this._printData(d.value.valueOne, this.dataTypeOne) + '</td> \
        <td class="right">' + this._printData(d.value.valueTwo, this.dataTypeTwo) + '</td>'
    }.bind(this));

    var table = this.div.select('.widget_table');

    table
      .selectAll('th')
      .data(header)
      .enter()
      .append('th')
      .attr('class', 'right')
      .html(function(d) {
        if (d === "") d = '<span style="display:none" aria-hidden="true">WCAG 2.0 AA</span>';
        return d; });

    table
      .selectAll('tr')
      .data(rows)
      .enter()
      .append('tr')
      .html(function(d) { return d; });
  }

  _printData(data, dataType) {
    // Switch between different figure types
    switch (data, dataType) {
      case 'percentage':
        return accounting.formatNumber(data, 1) + '%';
      case 'currency':
        return accounting.formatNumber(data, 0) + '€';
      case 'currency_per_person':
        return accounting.formatNumber(data, 0) + '€/' + I18n.t('gobierto_common.visualizations.inhabitants');
      default:
        return accounting.formatNumber(data, 0);
    }
  }

}

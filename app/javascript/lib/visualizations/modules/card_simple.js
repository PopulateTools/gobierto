import * as d3 from 'd3'
import { Card } from './card.js'
import { Sparkline } from './sparkline.js'
import { accounting } from 'lib/shared'

export class SimpleCard extends Card {
  constructor(divClass, json, value, cardName, valueType) {
    super(divClass)

    this.dataType = this.div.attr('data-type');

    var trend = this.div.attr('data-trend');
    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%b %Y");

    var divCard = $('div[class*="' + divClass.replace('.','') + '"]');

    divCard.find("div.indicator_widget.padded").find("div.widget_body").find("div.sparkline").empty();

    this.div.selectAll('.tw-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://twitter.com/intent/tweet?text=' + I18n.t('gobierto_common.visualizations.where') + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(I18n.t('gobierto_common.visualizations.cards.' + cardName + '.title')).toLowerCase() + I18n.t('gobierto_common.visualizations.time') + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(this._printData(value))  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

    this.div.selectAll('.fb-sharer')
      .attr('target', '_blank')
      .attr('href', 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href);

    this.div.select('.widget_figure')
      .text(this._printData(value));

    // If the data is 0
    if (divCard.find("div.indicator_widget.padded").find("div.widget_body").find("span.widget_figure").text() == 0)
      divCard.remove()

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

    if (typeof json.data[1] !== 'undefined') {
      var spark = new Sparkline(divClass + ' .sparkline', json.data, { trend, freq });
      spark.render();

      var pctChange = valueType ? (value / json.data[1][valueType] * 100) - 100 : (value / json.data[1].value * 100) - 100
      var pctFormat = accounting.formatNumber(pctChange, 2) + '%';
      var isPositive = pctChange > 0;

      // If is a positive change, attach a plus sign to the number
      this.div.select('.widget_pct')
        .text(function() { return isPositive ? '+' + pctFormat : pctFormat; });

      // Return the correct icon
      this.div.select('.widget_pct')
        .append('i')
        .attr('aria-hidden', 'true')
        .attr('class', function() {
          return isPositive ? 'fas fa-caret-up' : 'fas fa-caret-down';
        });
    }
  }
}

import { Class, d3, d3locale, accounting } from 'shared'
import { Sparkline } from './vis_sparkline.js'

export var SimpleCard = Class.extend({
  init: function(divClass, json, value, cardName, valueType) {
    d3.timeFormatDefaultLocale(d3locale[I18n.locale]);

    this.div = d3.select(divClass);
    this.dataType = this.div.attr('data-type');

    var trend = this.div.attr('data-trend');
    var freq = this.div.attr('data-freq');

    var parseDate = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    var parsedDate = parseDate(json.data[0].date);
    var formatDate = d3.timeFormat("%b %Y");

    var divCard = $('div[class*="' + divClass.replace('.','') + '"]');

    divCard.find("div.indicator_widget.padded").find("div.widget_body").find("div.sparkline").empty();

    // If no data exists for the selected year.
    if(parsedDate.getFullYear() != window.populateDataYear.currentYear) {
      divCard.remove();
      return;
    }

    this.div.selectAll('.tw-sharer')
    .attr('target', '_blank')
    .attr('href', 'https://twitter.com/intent/tweet?text=' + I18n.t('gobierto_budgets.budgets.cards.meta.where') + encodeURI(window.populateData.municipalityName) + ': ' +  encodeURI(I18n.t('gobierto_budgets.budgets.cards.' + cardName + '.title')).toLowerCase() + I18n.t('gobierto_budgets.budgets.cards.meta.time') + encodeURI(formatDate(parsedDate).toLowerCase()) + ', ' + encodeURI(this._printData(value))  + '&url=' + window.location.href + '&via=gobierto&source=webclient');

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
    .attr('title', I18n.t('gobierto_budgets.budgets.cards.' + cardName + '.title'))
    .text(I18n.t('gobierto_budgets.budgets.cards.' + cardName + '.title'));

    if (typeof json.data[1] !== 'undefined') {
      var spark = new Sparkline(divClass + ' .sparkline', json.data, trend, freq);
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
        return isPositive ? 'fa fa-caret-up' : 'fa fa-caret-down';
      });
    }
  },
  _printFreq: function(json) {
    // Switch between different figure types
    switch (json) {
      case 'yearly':
        return I18n.t('gobierto_observatory.cards.frequency.yearly')
      case 'monthly':
        return I18n.t('gobierto_observatory.cards.frequency.monthly')
      case 'weekly':
        return I18n.t('gobierto_observatory.cards.frequency.weekly')
      case 'daily':
        return I18n.t('gobierto_observatory.cards.frequency.dailt')
      default:
        return ''
    }
  },
  _printData: function(data) {
    // Switch between different figure types
    switch (this.dataType) {
      case 'percentage':
        return accounting.formatNumber(data, 1) + '%';
      case 'currency':
        return accounting.formatNumber(data, 0) + '€';
      case 'currency_per_person':
        return accounting.formatNumber(data, 1) + '€/' + I18n.t('gobierto_observatory.inhabitants');
      default:
        return accounting.formatNumber(data, 0);
    }
  }
});

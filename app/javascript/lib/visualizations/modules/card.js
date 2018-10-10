import * as d3 from 'd3'
import { d3locale, accounting } from 'lib/shared'

export class Card {
  constructor(divClass) {
    d3.timeFormatDefaultLocale(d3locale[I18n.locale]);

    this.div = d3.select(divClass);
  }

  _printData(data) {
    // Switch between different figure types
    switch (this.dataType) {
      case 'percentage':
        return accounting.formatNumber(data, 1) + '%';
      case 'percentage_by_thousand':
        return accounting.formatNumber(data, 1) + '‰';
      case 'currency':
        return accounting.formatNumber(data, 0) + '€';
      case 'currency_per_person':
        return accounting.formatNumber(data, 0) + '€/' + I18n.t('gobierto_common.visualizations.inhabitants');
      case 'per_inhabitant':
        return accounting.formatNumber(data, 2) + '/' + I18n.t('gobierto_common.visualizations.inhabitants');
      default:
        return accounting.formatNumber(data, 0);
    }
  }

  _printFreq(json) {
    // Switch between different figure types
    switch (json) {
      case 'yearly':
        return I18n.t('gobierto_common.visualizations.frequency.yearly')
      case 'monthly':
        return I18n.t('gobierto_common.visualizations.frequency.monthly')
      case 'weekly':
        return I18n.t('gobierto_common.visualizations.frequency.weekly')
      case 'daily':
        return I18n.t('gobierto_common.visualizations.frequency.dailt')
      default:
        return ''
    }
  }

  _normalize(str) {
    var from = "1234567890ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ‘/&().!",
        to = "izeasgtogoAAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_____",
        mapping = {};

    for (let i = 0, j = from.length; i < j; i++) {
      mapping[from.charAt(i)] = to.charAt(i);
    }

    var ret = [];
    for (let i = 0, j = str.length; i < j; i++) {
      var c = str.charAt(i);
      if (mapping.hasOwnProperty(str.charAt(i))) {
        ret.push(mapping[c]);
      }
      else {
        ret.push(c);
      }
    }

    return ret.join('').toLowerCase();
  }
}

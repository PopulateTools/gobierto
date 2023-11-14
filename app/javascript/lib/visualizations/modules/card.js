import { select } from "d3-selection";
import { timeFormatDefaultLocale } from "d3-time-format";
import { accounting, d3locale } from "lib/shared";

const d3 = { timeFormatDefaultLocale, select };

export class Card {
  constructor(divClass) {
    d3.timeFormatDefaultLocale(d3locale[I18n.locale]);

    this.div = d3.select(divClass);
  }

  _printData(data) {
    // Switch between different figure types
    switch (this.dataType) {
      case "percentage":
        return accounting.formatNumber(data, 1) + "%";
      case "percentage_by_thousand":
        return accounting.formatNumber(data, 1) + "‰";
      case "currency":
        return accounting.formatNumber(data, 0) + "€";
      case "currency_per_person":
        return (
          accounting.formatNumber(data, 0) +
          "€/" +
          I18n.t("gobierto_common.visualizations.inhabitants")
        );
      case "per_inhabitant":
        return (
          accounting.formatNumber(data, 2) +
          "/" +
          I18n.t("gobierto_common.visualizations.inhabitants")
        );
      default:
        return accounting.formatNumber(data, 0);
    }
  }

  _printFreq(type) {
    return I18n.t("gobierto_common.visualizations.frequency", { type })
  }

  _normalize(str) {
    var from =
        "1234567890ÃÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛãàáäâèéëêìíïîòóöôùúüûÑñÇç ‘/&().!,'",
      to = "izeasgtogoAAAAAEEEEIIIIOOOOUUUUaaaaaeeeeiiiioooouuuunncc_______",
      mapping = {};

    for (let i = 0, j = from.length; i < j; i++) {
      mapping[from.charAt(i)] = to.charAt(i);
    }

    var ret = [];
    for (let i = 0, j = str.length; i < j; i++) {
      var c = str.charAt(i);
      if (Object.prototype.hasOwnProperty.call(mapping, str.charAt(i))) {
        ret.push(mapping[c]);
      } else {
        ret.push(c);
      }
    }

    return ret.join("").toLowerCase();
  }
}

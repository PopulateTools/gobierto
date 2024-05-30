import * as d3 from 'd3';
import { accounting } from '../../../lib/shared';
import { Card } from './card.js';

export class ComparisonCard extends Card {
  constructor(divClass, value_1, value_2, { metadata, cardName }) {
    super(divClass);

    this.firstDataType = this.div.attr("data-type-first");
    this.secondDataType = this.div.attr("data-type-second");

    var parsedDate = new Date(metadata.updated_at);
    var formatDate = d3.timeFormat("%b %Y");

    this.div
      .selectAll(".tw-sharer")
      .attr("target", "_blank")
      .attr(
        "href",
        "https://twitter.com/intent/tweet?text=" +
          I18n.t("gobierto_common.visualizations.where") +
          encodeURI(window.populateData.municipalityName) +
          ": " +
          encodeURI(
            I18n.t(
              "gobierto_common.visualizations.cards." + cardName + ".title"
            )
          ).toLowerCase() +
          I18n.t("gobierto_common.visualizations.time") +
          encodeURI(formatDate(parsedDate).toLowerCase()) +
          ", " +
          encodeURI(this._printData(this.firstDataType, value_1)) +
          "&url=" +
          window.location.href +
          "&via=gobierto&source=webclient"
      );

    this.div
      .selectAll(".fb-sharer")
      .attr("target", "_blank")
      .attr(
        "href",
        "https://www.facebook.com/sharer/sharer.php?u=" + window.location.href
      );

    this.div
      .select(".widget_figure .figure-first")
      .text(this._printData(this.firstDataType, value_1));

    this.div
      .select(".widget_figure .figure-second")
      .text(this._printData(this.secondDataType, value_2));

    // Append source
    this.div
      .selectAll(".widget_src")
      .attr("title", metadata["source_name"])
      .html(metadata["source_url"] ? `<a href="${metadata["source_url"]}" target="_blank" rel="noopener noreferrer">${metadata["source_name"]}</a>` : metadata["source_name"]);

    // Append update frequency
    this.div
      .selectAll(".widget_freq")
      .text(this._printFreq(metadata.frequency_type));

    // Append date of last data point
    this.div.selectAll(".widget_updated").text(formatDate(parsedDate));

    // Append metadata
    this.div
      .selectAll(".widget_title")
      .attr(
        "title",
        I18n.t("gobierto_common.visualizations.cards." + cardName + ".title")
      )
      .text(
        I18n.t("gobierto_common.visualizations.cards." + cardName + ".title")
      );

    // Append backface info
    this.div
      .selectAll(".js-data-desc")
      .text(metadata.description);
    this.div.selectAll(".js-data-freq").text(formatDate(parsedDate));
  }

  _printData(type, dataRaw) {
    var data = Number(dataRaw)


    // Switch between different figure types
    switch (type) {
      case "percentage":
        return accounting.formatNumber(data, 2) + "%";
      case "currency":
        return accounting.formatNumber(data, 0) + "€";
      case "currency_per_person":
        return (
          accounting.formatNumber(data, 1) +
          "€/" +
          I18n.t("gobierto_common.visualizations.inhabitants")
        );
      default:
        return accounting.formatNumber(data, 0);
    }
  }
}

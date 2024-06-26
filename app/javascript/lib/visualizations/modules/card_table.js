import * as d3 from 'd3';
import { accounting } from '../../../lib/shared';
import { Card } from './card.js';

export class TableCard extends Card {
  constructor(divClass, data, { metadata, cardName }) {
    super(divClass);

    this.dataTypeOne = this.div.attr("data-type-one");
    this.dataTypeTwo = this.div.attr("data-type-two");

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
          encodeURI(this._printData(data[0].value_1)) +
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

    // Append source
    this.div
      .selectAll(".widget_src")
      .attr("title", metadata["source_name"])
      .html(metadata["source_url"] ? `<a href="${metadata["source_url"]}" target="_blank" rel="noopener noreferrer">${metadata["source_name"]}</a>` : metadata["source_name"]);

    // Append date of last data point
    this.div.selectAll(".widget_updated").text(formatDate(parsedDate));

    // Append update frequency
    this.div
      .selectAll(".widget_freq")
      .text(this._printFreq(metadata.frequency_type));

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

    var header = data.map(
      function(d) {
        return I18n.t(
          "gobierto_common.visualizations.cards." +
            cardName +
            "." +
            this._normalize(d.column)
        );
      }.bind(this)
    );

    var rows = data.map(
      function(d) {
        return (
          "<td>" +
          d.key +
          '</td> \
        <td class="right">' +
          this._printData(d.value_1, this.dataTypeOne) +
          '</td> \
        <td class="right">' +
          this._printData(d.value_2, this.dataTypeTwo) +
          "</td>"
        );
      }.bind(this)
    );

    var table = this.div.select(".widget_table");

    table
      .selectAll("th")
      .data(header)
      .enter()
      .append("th")
      .attr("class", "right")
      .html(function(d) {
        if (d === "")
          d =
            '<span style="display:none" aria-hidden="true">WCAG 2.0 AA</span>';
        return d;
      });

    table
      .selectAll("tr")
      .data(rows)
      .enter()
      .append("tr")
      .html(function(d) {
        return d;
      });
  }

  _printData(dataRaw, dataType) {
    var data = Number(dataRaw)

    // Switch between different figure types
    switch ((data, dataType)) {
      case "percentage":
        return accounting.formatNumber(data, 1) + "%";
      case "currency":
        return accounting.formatNumber(data, 0) + "€";
      case "currency_per_person":
        return (
          accounting.formatNumber(data, 0) +
          "€/" +
          I18n.t("gobierto_common.visualizations.inhabitants")
        );
      default:
        return accounting.formatNumber(data, 0);
    }
  }
}

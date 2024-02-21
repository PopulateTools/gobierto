import { timeFormat, timeParse } from "d3-time-format";
import { accounting } from "lib/shared";
import { Card } from "./card.js";

const d3 = { timeFormat, timeParse };

export class SparklineTableCard extends Card {
  constructor(divClass, data, { metadata, cardName }) {
    super(divClass);

    this.dataType = this.div.attr("data-type");

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
          encodeURI(this._printData(data[0].value)) +
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

    var rows = data.map(
      function(d) {
        return (
          "<td>" +
          d.title +
          '</td> \
        <td class="sparktable sparkline-' +
          d.key +
          '"></td> \
        <td>' +
          accounting.formatNumber(d.diff, 1) +
          "%</td> \
        <td>" +
          this._printData(d.value) +
          "</td>"
        );
      }.bind(this)
    );

    this.div
      .select(".widget_table")
      .selectAll("tr")
      .data(rows)
      .enter()
      .append("tr")
      .html(function(d) {
        return d;
      });
  }
}

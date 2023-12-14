import { max } from "d3-array";
import { scaleLinear } from "d3-scale";
import { select } from "d3-selection";
import { timeFormat, timeParse } from "d3-time-format";
import { Card } from "./card.js";

const d3 = { select, scaleLinear, timeFormat, timeParse, max };

export class BarsCard extends Card {
  constructor(divClass, data, { metadata, cardName }) {
    super(divClass);

    this.dataType = this.div.attr("data-type");

    var parsedDate = new Date(metadata.updated_at);
    var formatDate = d3.timeFormat("%b %Y");
    var isMobile = innerWidth <= 768;

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

    // Paint bars
    var x = d3
      .scaleLinear()
      .range([0, isMobile ? 30 : 35])
      .domain([
        0,
        d3.max(data, function(d) {
          return d.value;
        })
      ]);

    var row = this.div
      .select(".bars")
      .selectAll("div")
      .data(data)
      .enter()
      .append("div")
      .attr("class", "row");

    row
      .append("div")
      .attr("class", "key")
      .text(function(d) {
        return d.key;
      });

    row
      .append("div")
      .attr("class", "bar")
      .style("width", function(d) {
        return x(d.value) + "%";
      });

    row
      .append("div")
      .attr("class", "qty")
      .text(
        function(d) {
          return this._printData(d.value);
        }.bind(this)
      );
  }
}

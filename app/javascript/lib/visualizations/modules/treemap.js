import { json } from 'd3-fetch';
import { hierarchy, treemap } from 'd3-hierarchy';
import { scaleOrdinal } from 'd3-scale';
import { select } from 'd3-selection';
import { accounting } from '../../../lib/shared';

const d3 = { scaleOrdinal, select, json, treemap, hierarchy };

export class VisTreemap {
  constructor(divId, size, clickable) {
    this.containerId = divId;

    // Chart dimensions
    this.containerWidth = null;
    this.margin = { top: 0, right: 0, bottom: 0, left: 0 };
    this.width = null;
    this.height = null;

    this.sizeFactor = size == "big" ? 5.5 : 2.5;
    this.clickable = clickable;

    this.treemap = null;
    this.container = null;

    var colors = [
      "#FFBCC8",
      "#FF6181",
      "#EE2657",
      "#8C3044",
      "#516773",
      "#427991",
      "#1F3F4F",
      "#473D3F",
      "#24191B"
    ];
    this.colorScale = d3.scaleOrdinal().range(colors);

    this.opacity = 1;
    this.duration = 1;
  }

  render(urlData) {
    $(this.containerId).html("");

    // Chart dimensions
    const containerNode =
      d3.select(this.containerId).node() || document.createElement("div");
    this.containerWidth = (
      containerNode.parentNode || containerNode
    ).getBoundingClientRect().width;

    this.width = this.containerWidth - this.margin.left - this.margin.right;
    this.height =
      this.containerWidth / this.sizeFactor -
      this.margin.top -
      this.margin.bottom;

    this.container = d3
      .select(this.containerId)
      .style("position", "relative")
      .style("width", this.width + this.margin.left + this.margin.right + "px")
      .style(
        "height",
        this.height + this.margin.top + this.margin.bottom + "px"
      )
      .style("left", this.margin.left + "px")
      .style("top", this.margin.top + "px");

    this.treemap = d3.treemap().size([this.width, this.height]);

    d3.json(urlData).then(data => {
      var root = d3
        .hierarchy(data)
        .eachBefore(d => {
          d.data.id = d.data.code;
        })
        .sum(d => d.budget)
        .sort((a, b) => b.budget - a.budget);

      this.colorScale.domain(root.children.map(d => d.code));

      this.container
        .selectAll(".treemap_node")
        .data(this.treemap(root).leaves())
        .enter()
        .append("div")
        .attr("class", () => {
          if (this.clickable) {
            return "tipsit-treemap treemap_node clickable";
          } else {
            return "tipsit-treemap treemap_node";
          }
        })
        .attr(
          "title",
          function(d) {
            function totalBudgetTooltipStr(str) {
              return (
                "<br>" +
                accounting.formatMoney(
                  str,
                  "€",
                  0,
                  I18n.t("number.currency.format.delimiter"),
                  I18n.t("number.currency.format.separator")
                )
              );
            }
            function perInhabitantTooltipStr(str) {
              return str
                ? "<br>" +
                    accounting.formatMoney(
                      str,
                      "€",
                      0,
                      I18n.t("number.currency.format.delimiter"),
                      I18n.t("number.currency.format.separator")
                    ) +
                    " /" +
                    I18n.t("gobierto_common.visualizations.inhabitant_short")
                : "";
            }
            return (
              "<strong>" +
              d.data.name +
              "</strong>" +
              totalBudgetTooltipStr(d.data.budget) +
              perInhabitantTooltipStr(d.data.budget_per_inhabitant)
            );
          }.bind(this)
        )
        .attr("data-url", d => {
          if (this.clickable) {
            return d.children
              ? null
              : urlData.split("?")[0] + "?parent_code=" + d.data.code;
          }
        })
        .style("left", d => d.x0 + "px")
        .style("top", d => d.y0 + "px")
        .style("width", d => d.x1 - d.x0 + "px")
        .style("height", d => d.y1 - d.y0 + "px")
        .style("background", d => this.colorScale(d.data.code))
        .html(function(d) {
          function getBudgetAmount(d) {
            if (d.data.budget_per_inhabitant) {
              return (
                accounting.formatMoney(
                  d.data.budget_per_inhabitant,
                  "€",
                  0,
                  I18n.t("number.currency.format.delimiter"),
                  I18n.t("number.currency.format.separator")
                ) +
                "/" +
                I18n.t("gobierto_common.visualizations.inhabitant_short")
              );
            } else {
              return accounting.formatMoney(
                d.data.budget,
                "€",
                0,
                I18n.t("number.currency.format.delimiter"),
                I18n.t("number.currency.format.separator")
              );
            }
          }
          if (d.children) {
            return null;
          } else {
            // If the square is small, don't add the text
            if (d.x1 - d.x0 > 70 && d.y1 - d.y0 > 90) {
              return (
                "<p><strong>" +
                d.data.name +
                "</strong></p><p>" +
                getBudgetAmount(d) +
                "</p>"
              );
            }
          }
        });

      $(".tipsit-treemap").tipsy({
        fade: false,
        gravity: $.fn.tipsy.autoNS,
        html: true
      });
    });
  }
}

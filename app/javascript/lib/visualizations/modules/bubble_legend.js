import * as d3 from 'd3';

export class VisBubbleLegend {
  constructor(divId) {
    this.container = divId;
    $(this.container).html("");
    this.isMobile = window.innerWidth <= 740;

    var bigScreen = window.innerWidth > 1280;

    var colors = [
      "#b2182b",
      "#d6604d",
      "#f4a582",
      "#fddbc7",
      "#f7f7f7",
      "#d1e5f0",
      "#92c5de",
      "#4393c3",
      "#2166ac"
    ];

    var scale = d3
      .scaleOrdinal()
      .domain(colors.reverse())
      .range(d3.range(0, 100, 100 / colors.length));

    var margin = { top: 15, right: 5, bottom: 15, left: 5 },
      width =
        parseInt(d3.select(this.container).style("width")) -
        margin.left -
        margin.right,
      height = this.isMobile ? 320 : 520 - margin.top - margin.bottom;

    var svg = d3
      .select(this.container)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .style("overflow", "visible")
      .append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    var defs = svg.append("defs");

    defs
      .append("marker")
      .attr("id", "arrow_start")
      .attr("viewBox", "-10 -10 20 20")
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "-90")
      .append("path")
      .attr("fill", "#2166ac")
      .attr("d", "M-4,-6 L 10,0 L -4,6");

    defs
      .append("marker")
      .attr("id", "arrow_end")
      .attr("viewBox", "-10 -10 20 20")
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("fill", "#b2182b")
      .attr("d", "M-4,-6 L 10,0 L -4,6");

    var gradient = defs
      .append("linearGradient")
      .attr("id", "gradient")
      .attr("x1", 0)
      .attr("x2", 0)
      .attr("y1", 0)
      .attr("y2", height)
      .attr("gradientUnits", "userSpaceOnUse");

    gradient
      .selectAll("stop")
      .data(colors)
      .enter()
      .append("stop")
      .attr("stop-color", d => d)
      .attr("offset", d => `${scale(d)}%`);

    svg
      .append("line")
      .attr("transform", "translate(" + width / 2 + "," + 0 + ")")
      .attr("x1", 0)
      .attr("x2", 0)
      .attr("y1", 0)
      .attr("y2", height)
      .attr("stroke", "url(#gradient)")
      .attr("stroke-width", 4)
      .attr("marker-end", "url(#arrow_end)")
      .attr("marker-start", "url(#arrow_start)");

    var label = svg
      .append("text")
      .attr(
        "transform",
        "translate(" + width / 2 + "," + (height / 2 - 30) + ")"
      )
      .attr("text-anchor", "middle");

    label
      .append("tspan")
      .text(
        I18n.t("gobierto_common.visualizations.main_budget_levels_legend_one")
      );

    label
      .append("tspan")
      .attr("x", 0)
      .attr("y", 18)
      .text(
        I18n.t("gobierto_common.visualizations.main_budget_levels_legend_two")
      );

    svg
      .append("text")
      .attr("class", "legend-label")
      .attr("x", bigScreen ? 36 : 34)
      .attr("dy", 2)
      .text(
        I18n.t("gobierto_common.visualizations.main_budget_levels_legend_up")
      );

    svg
      .append("text")
      .attr("class", "legend-label")
      .attr("x", bigScreen ? 12 : 4)
      .attr("y", height + 8)
      .attr("text-anchor", "end")
      .text(
        I18n.t("gobierto_common.visualizations.main_budget_levels_legend_down")
      );
  }
}

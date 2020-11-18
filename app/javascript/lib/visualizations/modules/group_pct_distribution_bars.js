import { axisTop } from "d3-axis";
import { scaleThreshold } from "d3-scale";
import { select } from "d3-selection";
import { rowChart } from "dc";
import { truncate } from "lib/shared";

const d3 = { scaleThreshold, axisTop, select };
const dc = { rowChart };

export class GroupPctDistributionBars {
  constructor(options) {
    // Declaration
    const { containerSelector, dimension, onFilteredFunction } = options;
    this.container = dc.rowChart(containerSelector, "group");

    // Dimensions
    const groupedDimension = dimension.group().reduceCount(),
      all = dimension.groupAll();

    // Styling
    this._count = groupedDimension.size();
    this._gap = 10;
    this._barHeight = 18;

    const _initialLabelOffset = 250,
      _pctLabelOffset = 50;

    this.node = this.container.root().node() || document.createElement("div");

    this.setContainerSize();

    // Construction
    this.container
      .x(d3.scaleThreshold())
      .dimension(dimension)
      .group(groupedDimension)
      .ordering(d => -d.value)
      .labelOffsetX(-_initialLabelOffset)
      .gap(this._gap)
      .elasticX(true)
      .title(d => d.value)
      .valueAccessor(d => parseFloat(d.value / all.value()));

    this.container.on("pretransition", function(chart) {
      // Apply rounded corners AFTER render, otherwise they don't exist
      chart
        .selectAll("rect")
        .attr("rx", 4)
        .attr("ry", 4);

      // Custom labels
      chart
        .selectAll("text.row")
        .text("")
        .selectAll("tspan")
        .data(d => {
          let label = truncate(d.key, { length: 25 });
          let pct;

          if (this.hasFilter() && !this.hasFilter(d.key)) {
            pct = 0.0;
          } else if (this.hasFilter() && this.hasFilter(d.key)) {
            pct = parseFloat(d.value / dimension.top(Infinity).length);
          } else {
            pct = parseFloat(d.value / all.value());
          }

          pct = pct.toLocaleString(I18n.locale, {
            style: "percent",
            minimumFractionDigits: 1
          });

          return [label, pct];
        })
        .enter()
        .append("tspan")
        .text(d => d)
        .attr("x", (d, i) =>
          i === 0 ? -_initialLabelOffset : -_pctLabelOffset
        );
    });

    this.container.on("filtered", (chart, filter) =>
      onFilteredFunction(chart, filter)
    );

    // Customization
    this.container.xAxis(d3.axisTop().ticks(0));
    this.container.margins().left = _initialLabelOffset + 5;
    this.container.margins().right = 0;

    // Rendering
    this.container.render();
  }

  setContainerSize() {
    this.container
      .width((this.node.parentNode || this.node).getBoundingClientRect().width) // webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .height(
        this.container.margins().top +
          this.container.margins().bottom +
          this._count * this._barHeight +
          (this._count + 1) * this._gap
      ) // Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(this._barHeight);
  }
}

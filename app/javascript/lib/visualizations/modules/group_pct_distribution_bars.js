import * as d3 from 'd3';
import { truncate } from '../../../lib/vue/filters';
import { divide } from '../../shared';

/**
 * NOTE: dc@4 has been imported via CDN due to d3 compatibility issues
 * It requires d3@5 to be imported as well
 */
export class GroupPctDistributionBars {
  constructor(options) {
    // Declaration
    const { containerSelector, dimension, onFilteredFunction, groupValue } = options;
    this.container = new dc.RowChart(containerSelector, "group");

    // Dimensions
    const groupedDimension = !groupValue ? dimension.group().reduceCount() : dimension.group().reduceSum(d => d[groupValue]),
      all = dimension.groupAll();

    // Styling
    this._count = groupedDimension.size();
    this._gap = 10;
    this._barHeight = 18;

    const _initialLabelOffset = 250
    const _pctLabelOffset = !groupValue ? 50 : 80;

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
      .valueAccessor(d => parseFloat(divide(d.value, all.value())));

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
          let labelValue;

          if (this.hasFilter() && !this.hasFilter(d.key)) {
            labelValue = 0.0;
          } else if (this.hasFilter() && this.hasFilter(d.key)) {
            labelValue = !groupValue
              ? parseFloat(divide(d.value, dimension.top(Infinity).length))
              : d.value;
          } else {
            labelValue = !groupValue
              ? parseFloat(divide(d.value, all.value()))
              : d.value;
          }

          if (!groupValue) {
            labelValue = labelValue.toLocaleString(I18n.locale, {
              style: "percent",
              minimumFractionDigits: 1
            });
          } else {
            //Convert negative zero to positive zero
            labelValue = Math.max(0, labelValue).toLocaleString(I18n.locale, {
              style: "currency",
              currency: "EUR",
              maximumFractionDigits: 0
            });
          }

          return [label, labelValue];
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

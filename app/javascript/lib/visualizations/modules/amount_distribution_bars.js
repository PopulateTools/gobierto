import { axisTop } from 'd3-axis';
import { scaleThreshold } from 'd3-scale';
import { select } from 'd3-selection';
import { rowChart } from 'dc';

const d3 = { scaleThreshold, axisTop, select };
const dc = { rowChart };

export class AmountDistributionBars {
  constructor(options) {
    // Declaration
    const {
      containerSelector,
      dimension,
      onFilteredFunction,
      range,
      labelMore,
      labelFromTo
    } = options;
    this.container = dc.rowChart(containerSelector, "group");

    // Dimensions
    const amountByGroupingField = dimension.group().reduceCount();

    // Styling
    (this._count = amountByGroupingField.size()), (this._gap = 10);
    this._barHeight = 18;

    const _labelOffset = 195;

    this.node = this.container.root().node() || document.createElement("div");

    this.setContainerSize();

    // Construction
    this.container
      .x(d3.scaleThreshold())
      .dimension(dimension)
      .group(amountByGroupingField)
      .ordering(d => d.key)
      .labelOffsetX(-_labelOffset)
      .gap(this._gap)
      .elasticX(true)
      .title(d => d.value)
      .on("pretransition", function(chart) {
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart
          .selectAll("rect")
          .attr("rx", 4)
          .attr("ry", 4);

        // edit labels positions
        chart
          .selectAll("text.row")
          .text("")
          .selectAll("tspan")
          .data(d => {
            // helper
            function intervalFormat(d) {
              var n = Number(range.domain[d.key]);
              var _s = Number(range.domain[d.key - 1]) || 1;

              // Last value is not a range
              if (d.key === range.domain.length) {
                return [
                  labelMore +
                    " " +
                    (_s - 1).toLocaleString(I18n.locale, {
                      style: "currency",
                      currency: "EUR",
                      minimumFractionDigits: 0
                    })
                ];
              }

              var _l = Number(n - 1);

              return [_s, _l].map(n =>
                n.toLocaleString(I18n.locale, {
                  style: "currency",
                  currency: "EUR",
                  minimumFractionDigits: 0
                })
              );
            }

            return intervalFormat(d);
          })
          .enter()
          .append("tspan")
          .text(d => d)
          .attr("x", (d, i) => (i === 0 ? -_labelOffset : -_labelOffset / 2));

        chart
          .select("g.axis")
          .attr("transform", "translate(0,0)")
          .append("text")
          .attr("class", "axis-title")
          .attr("y", -9) // Default
          .selectAll("text")
          .data(() => {
            // helper
            function titleFormat(str) {
              str = str.split(" ");
              if (str.length !== 4) throw new Error();

              var last = [str[2], str[3]].join(" ");
              return [str[0], str[1], last];
            }

            return titleFormat(labelFromTo);
          })
          .enter()
          .append("tspan")
          .text(d => d)
          .attr("x", (d, i) =>
            i === 0 ? -_labelOffset : i === 1 ? -_labelOffset / 2 : 0
          )
          .attr("text-anchor", (d, i) => (i === 2 ? "middle" : ""));

        chart.selectAll("g.axis line.grid-line").attr("y2", function() {
          return (
            Math.abs(+d3.select(this).attr("y2")) + chart.margins().top / 2
          );
        });
      })
      .on("filtered", (chart, filter) => onFilteredFunction(chart, filter));

    // Customization
    this.container.xAxis(d3.axisTop().ticks(5));
    this.container.xAxis().tickFormat((tick, pos) => {
      if (pos === 0) return null;
      return tick;
    });
    this.container.margins().top = 20;
    this.container.margins().left = _labelOffset + 5;
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

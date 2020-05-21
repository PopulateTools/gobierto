import { scaleThreshold, axisTop, select } from 'd3';
import { rowChart } from 'dc';

const d3 = { scaleThreshold, axisTop, select }
const dc = { rowChart }

export class AmountDistributionBars {
  constructor(options) {
    // Declaration
    const { containerSelector, dimension, onFilteredFunction, range, labelMore, labelFromTo } = options
    const container = dc.rowChart(containerSelector, "group");

    // Dimensions
    const amountByGroupingField = dimension.group().reduceCount();

    // Styling
    const _count = amountByGroupingField.size(),
          _gap = 10,
          _barHeight = 18,
          _labelOffset = 195;

    const node = container.root().node() || document.createElement("div")

    // Construction
    container
      .width((node.parentNode || node).getBoundingClientRect().width) // webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .height(container.margins().top + container.margins().bottom + (_count * _barHeight) + ((_count + 1) * _gap)) // Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .x(d3.scaleThreshold())
      .dimension(dimension)
      .group(amountByGroupingField)
      .ordering(d => d.key)
      .labelOffsetX(-_labelOffset)
      .gap(_gap)
      .elasticX(true)
      .title(d => d.value)
      .on('pretransition', function(chart){
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart.selectAll('rect').attr("rx", 4).attr("ry", 4);

        // edit labels positions
        chart.selectAll('text.row')
          .text('')
          .selectAll('tspan')
          .data(d => {
            // helper
            function intervalFormat(d) {
              var n = Number(range.domain[d.key])
              var _s = Number(range.domain[d.key - 1]) || 1;

              // Last value is not a range
              if (d.key === range.domain.length) {
                return [labelMore + " " + (_s - 1).toLocaleString(I18n.locale, {
                  style: 'currency',
                  currency: 'EUR',
                  minimumFractionDigits: 0
                })]
              }

              var _l = Number(n - 1);

              return [_s, _l].map(n => n.toLocaleString(I18n.locale, {
                style: 'currency',
                currency: 'EUR',
                minimumFractionDigits: 0
              }))
            }

            return intervalFormat(d)
          })
          .enter()
          .append('tspan')
          .text(d => d)
          .attr('x', (d, i) => i === 0 ? -_labelOffset : -_labelOffset / 2)

        chart.select('g.axis')
          .attr('transform', 'translate(0,0)')
          .append('text')
          .attr('class', 'axis-title')
          .attr('y', -9) // Default
          .selectAll('text')
          .data(() => {
            // helper
            function titleFormat(str) {
              str = str.split(' ')
              if (str.length !== 4) throw new Error()

              var last = [str[2], str[3]].join(' ')
              return [str[0], str[1], last]
            }

            return titleFormat(labelFromTo);
          })
          .enter()
          .append('tspan')
          .text(d => d)
          .attr('x', (d, i) => (i === 0) ? -_labelOffset : (i === 1) ? -_labelOffset / 2 : 0)
          .attr('text-anchor', (d, i) => (i === 2) ? 'middle' : '')

        chart.selectAll('g.axis line.grid-line').attr("y2", function() {
          return Math.abs(+d3.select(this).attr("y2")) + (chart.margins().top / 2)
        });
      })
      .on('filtered', () => onFilteredFunction());

    // Customization
    container.xAxis(d3.axisTop().ticks(5))
    container.xAxis().tickFormat(
      function(tick, pos) {
        if (pos === 0) return null
        return tick
      });
    container.margins().top = 20;
    container.margins().left = _labelOffset + 5;
    container.margins().right = 0;

    // Rendering
    container.render();

  }
}

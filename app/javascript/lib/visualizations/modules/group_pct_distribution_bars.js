import { scaleThreshold, axisTop, select } from 'd3';
import { rowChart } from 'dc';

const d3 = { scaleThreshold, axisTop, select }
const dc = { rowChart }

export class GroupPctDistributionBars {
  constructor(options) {
    // Declaration
    const { containerSelector, dimension, onFilteredFunction } = options
    const container = dc.rowChart(containerSelector, "group");

    // Dimensions
    const groupedDimension = dimension.group().reduceCount(),
          all = dimension.groupAll();

    // Styling
    const _count = groupedDimension.size(),
          _gap = 10,
          _barHeight = 18,
          _initialLabelOffset = 250,
          _pctLabelOffset = 70;

    const node = container.root().node() || document.createElement("div")

    // Construction
    container
      .width((node.parentNode || node).getBoundingClientRect().width) // webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .height(container.margins().top + container.margins().bottom + (_count * _barHeight) + ((_count + 1) * _gap)) // Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .x(d3.scaleThreshold())
      .dimension(dimension)
      .group(groupedDimension)
      .ordering(d => d.key)
      .labelOffsetX(-_initialLabelOffset)
      .gap(_gap)
      .elasticX(true)
      .title(function(d) { return d.value })
      .valueAccessor(d =>  parseFloat(d.value / all.value()) )

    container
      .on('pretransition', function(chart){
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart.selectAll('rect').attr("rx", 4).attr("ry", 4);

        // Custom labels
        chart.selectAll('text.row')
          .text('')
          .selectAll('tspan')
          .data(d => {
            let label = d.key, pct;

            if (container.hasFilter() && !container.hasFilter(d.key)){
              pct = 0.0;
            } else if (container.hasFilter() && container.hasFilter(d.key)){
              pct = parseFloat(d.value / dimension.top(Infinity).length);
            } else{
              pct = parseFloat(d.value / all.value());
            }

            pct = pct.toLocaleString(I18n.locale, {
                    style: 'percent',
                    minimumFractionDigits: 1
                  });

            return [label, pct]
          })
          .enter()
          .append('tspan')
          .text(d => d)
          .attr('x', (d, i) => i === 0 ? -_initialLabelOffset : -_pctLabelOffset)
      })

    container.on('filtered', () => onFilteredFunction());

    // Customization
    container.xAxis(d3.axisTop().ticks(0))
    container.margins().left = _initialLabelOffset + 5;
    container.margins().right = 0;

    // Rendering
    container.render();
  }
}

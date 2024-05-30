import * as d3 from 'd3';

export class Rowchart {
  constructor(context, data, options = {}) {
    // Markup has already a svg inside
    if ($(`${context} svg`).length !== 0) return;

    // options
    let itemHeight = options.itemHeight || 25;
    let gutter = options.gutter || 20;
    let margin = options.margins || {
      top: gutter / 1.5,
      right: gutter,
      bottom: gutter * 1.5,
      left: gutter
    };
    let xTickFormat = options.xTickFormat || (d => d);
    let yTickFormat = options.yTickFormat || (d => d);
    let tooltipContainer = options.tooltipContainer || "body";
    let tooltipContent = options.tooltipContent;

    // dimensions
    let container = d3.select(context);
    let width =
      +container.node().getBoundingClientRect().width -
      margin.left -
      margin.right;
    let height = data.length * itemHeight + margin.top + margin.bottom;
    let svg = container
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom);

    // tooltip
    let tooltip = d3
      .select(tooltipContainer)
      .append("div")
      .attr("id", `${container.node().id}-tooltip`)
      .attr("class", "graph-tooltip")
      .style("transform", "translateX(20%)");

    // scales
    let x = d3.scaleLinear().range([0, width]);
    let y = d3.scaleBand().range([height, 0]);

    let g = svg
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain([0, d3.max(data, d => d.value)]);
    y.domain(data.map(d => d.key)).padding(0.1);

    g.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + (height + gutter / 4) + ")")
      .call(
        d3
          .axisBottom(x)
          .ticks(5)
          .tickSizeOuter(0)
          .tickFormat(xTickFormat)
      );

    g.selectAll(".bar")
      .data(data)
      .enter()
      .append("a")
      .attr("xlink:href", d => (d.properties || {}).url)
      .append("rect")
      .on("mousemove", function(_, d) {
        if (!tooltipContent) return

        const content = `<div class="tooltip-content left">${tooltipContent(d)}</div>`;

        const node = container.node() || document.createElement("div");
        const coords = {
          x: window.scrollX + node.getBoundingClientRect().left,
          y: window.scrollY + node.getBoundingClientRect().top
        };

        tooltip
          .style("opacity", "1")
          .style("left", `${coords.x + x(d.value) + margin.left}px`)
          .style("top", `${coords.y + y(d.key) + itemHeight / 2}px`)
          .html(content);
      })
      .on("mouseout", () => tooltip.style("opacity", "0"))
      .attr("class", "bar")
      .attr("x", 0)
      .attr("y", d => y(d.key))
      .attr("height", y.bandwidth())
      .transition()
      .duration(750)
      .attr("width", d => x(d.value));

    g.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + gutter + ", 0)")
      .call(d3.axisLeft(y).tickFormat(yTickFormat));
  }
}

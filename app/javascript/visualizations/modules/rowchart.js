import { d3 } from 'shared'

export const rowchart = (context, data, options = {}) => {
  // options
  let itemHeight = options.itemHeight || 25
  let gutter = options.gutter || 20
  let margin = options.margins || {
    top: gutter / 1.5,
    right: gutter,
    bottom: gutter * 1.5,
    left: gutter
  }
  let xTickFormat = options.xTickFormat || (d => d)
  let yTickFormat = options.yTickFormat || (d => d)

  // dimensions
  let container = d3.select(context)
  let width = +container.node().getBoundingClientRect().width - margin.left - margin.right
  let height = (data.length * itemHeight) + margin.top + margin.bottom
  let svg = container.append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)

  // TODO: implementar tooltip
  // let tooltip = container.append("div").attr("class", "toolTip")

  // scales
  let x = d3.scaleLinear().range([0, width])
  let y = d3.scaleBand().range([height, 0])

  let g = svg.append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  x.domain([0, d3.max(data, d => d.value)])
  y.domain(data.map(d => d.key)).padding(0.1)

  g.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + (height + (gutter / 4)) + ")")
    .call(d3.axisBottom(x).ticks(5).tickSizeOuter(0).tickFormat(xTickFormat))

  g.selectAll(".bar")
    .data(data)
    .enter().append("rect")
    .attr("class", "bar")
    .attr("x", 0)
    .attr("height", y.bandwidth())
    .attr("y", d => y(d.key))
    .transition()
    .duration(750)
    .attr("width", d => x(d.value))
  // .on("mousemove", function(d) {
  //   tooltip
  //     .style("left", d3.event.pageX - 50 + "px")
  //     .style("top", d3.event.pageY - 70 + "px")
  //     .style("display", "inline-block")
  //     .html((d.key) + "<br>" + "£" + (d.value));
  // })
  // .on("mouseout", d => tooltip.style("display", "none"));

  g.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + gutter + ", 0)")
    .call(d3.axisLeft(y).tickFormat(yTickFormat))
}

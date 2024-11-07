import * as d3 from 'd3';
import { extend, flatten, map } from 'lodash';

function monthDiff(dateFrom, dateTo) {
  return (
    dateTo.getMonth() -
    dateFrom.getMonth() +
    12 * (dateTo.getFullYear() - dateFrom.getFullYear())
  );
}

export class Punchcard {
  constructor(context, data, options = {}) {
    // Markup has already a svg inside
    if ($(`${context} svg`).length !== 0) return;

    // options
    let itemHeight = options.itemHeight || 50;
    let gutter = options.gutter || 20;
    let margin = extend(
      {
        top: gutter * 3.5,
        right: gutter,
        bottom: gutter * 1.5,
        left: gutter * 15
      },
      options.margins
    );
    let xTickFormat = options.xTickFormat || (d => d);
    let yTickFormat = options.yTickFormat || (d => d);
    let title = options.title || "";
    let tooltipContainer = options.tooltipContainer || "body";
    let tooltipContent = options.tooltipContent;
    let fixedWidth = options.width;
    let fixedHeight = options.height;

    // parse dates
    data.forEach((element, elementIndex) => {
      for (var dateIndex = 0; dateIndex < element.value.length; dateIndex++) {
        let dateString = element.value[dateIndex].key;
        data[elementIndex].value[dateIndex].key = new Date(dateString);
      }
    });

    // estimation number of x.axis.ticks to center if there are no so much
    let xAxisLimits = d3.extent(map(flatten(map(data, "value")), "key"));
    let xAxisLength = monthDiff(...xAxisLimits);
    if (xAxisLength < 5) {
      margin = extend(margin, {
        left: margin.left * 2,
        right: margin.right * 10
      });
    }

    // dimensions
    let container = d3.select(context);
    let containerNode = container.node() || document.createElement("div");
    let width =
      fixedWidth ||
      +containerNode.getBoundingClientRect().width - margin.left - margin.right;
    let height =
      fixedHeight || data.length * itemHeight + margin.top + margin.bottom;
    let svg = container
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom);

    // scales
    let x = d3.scaleTime().range([0, width]);
    let y = d3.scaleBand().range([height, 0]);
    let r = d3.scaleSqrt().range([3, 15]); // tamaño de las bolas

    // domains
    x.domain([
      d3.min(data.map(d => d3.min(d.value.map(v => v.key)))),
      d3.max(data.map(d => d3.max(d.value.map(v => v.key))))
    ]);
    y.domain(data.map(d => d.key)).padding(0);
    r.domain([
      d3.min(data.map(d => d3.min(d.value.map(v => v.value)))),
      d3.max(data.map(d => d3.max(d.value.map(v => v.value))))
    ]);

    let g = svg
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    // circles
    let _g = g
      .selectAll("g.row")
      .data(data)
      .enter()
      .append("g")
      .attr("class", "row")
      .attr("transform", d => `translate(0, ${y(d.key)})`);

    _g.append("rect")
      .attr("x", -margin.left)
      .attr("rx", 6)
      .attr("ry", 6)
      .attr("width", svg.attr("width"))
      .attr("height", y.bandwidth());

    _g.selectAll("circle")
      .data(d => d.value)
      .enter()
      .append("a")
      // .attr("xlink:href", d => (d.properties || {}).url)
      .append("circle")
      .attr("class", "circle")
      .attr("cx", d => x(d.key))
      .attr("cy", y.bandwidth() / 2)
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
          .style("left", `${coords.x + margin.left + x(d.key)}px`)
          .style(
            "top",
            `${coords.y +
              margin.top +
              y(d3.select(this.parentNode.parentNode).data()[0].key)}px`
          )
          .html(content);
      })
      .on("mouseout", () => tooltip.style("opacity", "0"))
      .transition()
      .duration(800)
      .attr("r", d => r(d.value));

    // Custom X-axis
    function xAxis(g) {
      g.call(
        d3
          .axisTop(x)
          .ticks(d3.timeMonth.every(1))
          .tickSizeOuter(0)
          .tickSizeInner(0)
          .tickFormat(xTickFormat)
      );
      g.selectAll(".domain").remove();
      g.selectAll(".tick line")
        .attr("y1", 0)
        .attr("y2", height);
      g.selectAll(".tick text").attr("y", -margin.top / 1.5 + itemHeight / 2);
    }

    // Custom Y-axis
    function yAxis(g) {
      g.call(
        d3
          .axisLeft(y)
          .tickSizeOuter(0)
          .tickSizeInner(0)
          .tickFormat(yTickFormat)
      );
      g.selectAll("text").each(function() {
        // max size axis
        let maxWidth = margin.left - 2 * gutter;

        let self = d3.select(this);
        let textLength = self.node().getComputedTextLength();
        let text = self.text();

        while (textLength > maxWidth && text.length > 0) {
          text = text.slice(0, -1);
          self.html(`${text}&hellip;`);
          textLength = self.node().getComputedTextLength();
        }

        return self.text();
      });

      g.selectAll(".domain").remove();
      g.selectAll(".tick").on("click", function(d, i) {
        document.location.href = (data[i].properties || {}).url;
      });
    }

    // axis
    g.append("g")
      .attr("class", "x axis")
      .call(xAxis);

    g.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + (-margin.left + gutter) + ",0)")
      .call(yAxis);

    // chart title
    if (title) {
      const topSpace = margin.top / 3 + itemHeight / 2;

      // To overlap axis text, we create a fake background
      let bgText = svg
        .append("rect")
        .attr("x", 0)
        .attr("fill", "white");

      let titleText = svg
        .append("text")
        .attr("x", 0)
        .attr("y", topSpace)
        .attr("class", "title")
        .attr("text-anchor", "start")
        .text(title);

      bgText
        .attr("width", titleText.node().getBBox().width)
        .attr("height", titleText.node().getBBox().height)
        .attr("y", topSpace - titleText.node().getBBox().height / 2);
    }

    // tooltip
    let tooltip = d3
      .select(tooltipContainer)
      .append("div")
      .attr("id", `${container.node().id}-tooltip`)
      .attr("class", "graph-tooltip")
      .style("transform", "translate(-50%, -10%)");
  }
}

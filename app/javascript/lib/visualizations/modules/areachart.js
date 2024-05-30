import * as d3 from 'd3';

export class Areachart {
  constructor(props) {
    this.container = d3.select(props.ctx);
    this.data = props.data || [];

    // options
    this.maxWidth = props.maxWidth || 1440;
    this.minHeight = props.minHeight || 50;
    this.aspectRatio = props.aspectRatio || 4;
    this.circleSize = props.circleSize || 3;
    this.minValue = props.minValue || 0;
    this.tooltip = props.tooltip || this.defaultTooltip;
    this.xTickFormat = props.xTickFormat || (d => d3.timeFormat("%b %y")(d));
    this.margin = {
      top: props.marginTop !== undefined ? props.marginTop : 5,
      right: props.marginRight !== undefined ? props.marginRight : 5,
      bottom: props.marginBottom !== undefined ? props.marginBottom : 20,
      left: props.marginLeft !== undefined ? props.marginLeft : 5
    };

    // create main elements
    this.svg = this.container.append("svg").attr("class", "areachart");
    this.g = this.svg.append("g");
    this.g.append("path").attr("class", "area");
    this.g.append("path").attr("class", "headline");
    this.g.append("g").attr("class", "x axis");
    this.tooltipContainer = this.container.append("div");

    if (this.data.length) {
      this.draw();
    }

    window.addEventListener("resize", this.draw.bind(this));
  }

  draw() {
    if (this.data.length) {
      this.setElements();
      this.handleArea();
      this.handleLine();
      this.handleCircles();
    }
  }

  setElements() {
    // Dimensions
    this.width = Math.min(
      this.maxWidth,
      +this.container.node().getBoundingClientRect().width -
        this.margin.left -
        this.margin.right
    );
    this.height = Math.max(
      this.minHeight,
      this.width / this.aspectRatio - this.margin.top - this.margin.bottom
    );

    // Scales & Ranges
    this.x = d3
      .scaleTime()
      .range([this.data.length === 1 ? this.width / 2 : 0, this.width])
      .domain(d3.extent(this.data, d => d.key));

    this.y = d3
      .scaleLinear()
      .range([this.height, 0])
      .domain([this.minValue, d3.max(this.data, d => d.value)]);

    // Positions
    this.svg
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom);
    this.g.attr(
      "transform",
      `translate(${this.margin.left},${this.margin.top})`
    );

    // Axes
    this.g
      .select(".x.axis")
      .attr("transform", `translate(0,${this.height})`)
      .call(this.xAxis.bind(this));
  }

  handleArea() {
    const path = this.g.selectAll(`path.area`).datum(this.data);

    path.exit().remove();

    const pathEnter = path
      .enter()
      .append("path")
      .attr("class", "area");

    path
      .merge(pathEnter)
      .attr("class", "area")
      .attr(
        "d",
        d3
          .area()
          .x(d => this.x(d.key))
          .y0(this.y(this.minValue))
          .y1(d => this.y(d.value))
      );
  }

  handleLine() {
    const path = this.g.selectAll(`path.headline`).datum(this.data);

    path.exit().remove();

    const pathEnter = path
      .enter()
      .append("path")
      .attr("class", "headline");

    path
      .merge(pathEnter)
      .attr("class", "headline")
      .attr(
        "d",
        d3
          .line()
          .x(d => this.x(d.key))
          .y(d => this.y(d.value))
      );
  }

  handleCircles() {
    const circles = this.g.selectAll(`circle.circle`).data(this.data);

    circles.exit().remove();

    const circlesEnter = circles
      .enter()
      .append("circle")
      .attr("class", "circle")
      .on("mouseover", this.onCircleMouseover.bind(this))
      .on("mouseout", this.onCircleMouseout.bind(this));

    circles
      .merge(circlesEnter)
      .attr("cx", d => this.x(d.key))
      .attr("cy", d => this.y(d.value))
      .attr("r", this.circleSize);

    if (this.circleSize < 5) {
      const hoverCircles = this.g
        .selectAll(`circle.hover-circle`)
        .data(this.data);

      hoverCircles.exit().remove();

      const hoverCirclesEnter = hoverCircles
        .enter()
        .append("circle")
        .attr("class", "hover-circle")
        .attr("fill", "transparent")
        .attr("cursor", "pointer")
        .on("mouseover", this.onCircleMouseover.bind(this))
        .on("mouseout", this.onCircleMouseout.bind(this));

      hoverCircles
        .merge(hoverCirclesEnter)
        .attr("cx", d => this.x(d.key))
        .attr("cy", d => this.y(d.value))
        .attr("r", 5);
    }
  }

  onCircleMouseover(d) {
    this.tooltipContainer
      .html(this.tooltip(d))
      .style("opacity", 1)
      .style("position", "absolute")
      .style("z-index", "1")
      .style("transform", "translate(-50%, -100%)")
      .style("transition", "opacity 250ms")
      .style("left", `${this.x(d.key) + this.margin.left}px`)
      .style(
        "top",
        `${this.y(d.value) + this.margin.top - this.circleSize * 3}px`
      );
  }

  onCircleMouseout() {
    this.tooltipContainer.style("opacity", 0).style("z-index", "-1");
  }

  xAxis(g) {
    g.call(
      d3
        .axisBottom(this.x)
        .tickSize(0)
        .tickArguments([this.data.length])
        .tickFormat(this.xTickFormat)
    );

    // remove baseline
    g.select(".domain").remove();
    // remove default formats
    g.attr("font-family", null);
    // align last item
    g.select(".x.axis .tick:last-of-type:not(:only-child) text").attr(
      "text-anchor",
      "end"
    );
  }

  defaultTooltip(d) {
    return `<span>${d.key.toLocaleDateString()}</span>: <span>${
      d.value
    }</span>`;
  }
}

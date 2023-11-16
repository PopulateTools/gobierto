import { extent } from "d3-array";
import { axisTop } from "d3-axis";
import { scaleLinear, scaleOrdinal, scaleTime } from "d3-scale";
import { select } from "d3-selection";
import { line } from "d3-shape";
import { timeParse } from "d3-time-format";

const d3 = {
  timeParse,
  scaleTime,
  scaleLinear,
  scaleOrdinal,
  select,
  extent,
  line,
  axisTop
};

export class Sparkline {
  constructor(context, data, options = {}) {
    this.container = context;
    this.data = data;

    // options
    this.timeParse =
      options.freq === "daily"
        ? d3.timeParse("%Y-%m-%d")
        : options.freq === "monthly"
        ? d3.timeParse("%Y-%m")
        : d3.timeParse("%Y");
    this.trend = options.trend;
    this.axes = options.axes || false;
    this.aspectRatio = options.aspectRatio || 5;
    this.margin = options.margins || { top: 5, right: 5, bottom: 5, left: 5 };

    // Chart dimensions
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleTime();
    this.yScale = d3.scaleLinear();
    this.color = d3.scaleOrdinal();

    // Create main elements
    this.svg = d3
      .select(this.container)
      .append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("class", "chart-container")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    d3.select(window).on("resize." + this.container, () => {
      if (this.data) {
        this._resize();
      }
    });
  }

  render() {
    this._type();
    this.updateRender();
    this._renderLines();
  }

  updateRender() {
    this.xScale.rangeRound([0, this.width]).domain(
      d3.extent(
        this.data,
        function(d) {
          return d.date;
        }.bind(this)
      )
    );

    this.yScale
      .rangeRound([this.height, 0])
      .domain(
        d3.extent(
          this.data,
          function(d) {
            return Number(d.value);
          }.bind(this)
        )
      )
      .nice();
  }

  _renderLines() {
    this.line = d3
      .line()
      .x(
        function(d) {
          return this.xScale(d.date);
        }.bind(this)
      )
      .y(
        function(d) {
          return this.yScale(Number(d.value));
        }.bind(this)
      );

    this.isPositive =
      this.data[0].value - this.data.slice(-1)[0].value > 0 ? true : false;

    if (this.axes) {
      this.svg
        .append("g")
        .attr("class", "x axis")
        .attr("transform", `translate(0,${this.height})`)
        .call(this._xAxis.bind(this));
    }

    this.svg
      .append("path")
      .datum(this.data)
      .attr("stroke", this._getColor())
      .attr("fill", "none")
      .attr("d", this.line);

    this.svg
      .append("circle")
      .attr(
        "cx",
        function() {
          return this.xScale(this.data[0].date);
        }.bind(this)
      )
      .attr(
        "cy",
        function() {
          return this.yScale(this.data[0].value);
        }.bind(this)
      )
      .attr("r", 2.5)
      .attr("fill", this._getColor());
  }

  _xAxis(g) {
    g.call(d3.axisTop(this.xScale).ticks(this.data.length));
    g.selectAll(".domain").remove();
    g.selectAll(".tick text").remove();
    g.selectAll(".tick:first-of-type line").remove();
    g.selectAll(".tick:last-of-type line").remove();
    g.selectAll(".tick line")
      .attr("y1", 0)
      .attr("y2", -this.height);
  }

  _getColor() {
    if (
      (this.isPositive && this.trend === "up") ||
      (!this.isPositive && this.trend === "down")
    ) {
      return "#AAC44B";
    } else {
      return "#981F2E";
    }
  }

  _type() {
    this.data = this.data
      .map(d => ({
        ...d,
        date: this.timeParse(d.date)
      }))
      .sort((a, b) => (a.date < b.date ? 1 : -1));
  }

  _width() {
    return d3.select(this.container).node()
      ? parseInt(d3.select(this.container).style("width"))
      : 0;
  }

  _height() {
    return this._width() / this.aspectRatio;
  }

  _resize() {
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    this.updateRender();

    d3.select(this.container + " svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom);

    this.svg
      .select(".chart-container")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    this.svg.select("path").attr("d", this.line);

    this.svg
      .select("circle")
      .attr(
        "cx",
        function() {
          return this.xScale(this.data[0].date);
        }.bind(this)
      )
      .attr(
        "cy",
        function() {
          return this.yScale(this.data[0].value);
        }.bind(this)
      );
  }
}

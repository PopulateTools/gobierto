import { drag } from 'd3-drag';
import { scalePoint, scaleQuantize } from 'd3-scale';
import { mouse, select, selectAll } from 'd3-selection';

const d3 = {
  select,
  selectAll,
  scalePoint,
  scaleQuantize,
  drag,
  mouse
};

export class VisSlider {
  constructor(divId, data) {
    this.container = divId;
    $(this.container).html("");
    this.data = data;

    var currentYear = d3.select("body").attr("data-year");
    var maxYear = parseInt(d3.select("body").attr("data-max-year"));
    var years = this.data
      .reduce((acc, { values }) => {
        // add the keys, if they're not included, up to maxYear
        Object.keys(values).forEach(x => {
          if (!acc.includes(+x) && +x <= maxYear) acc.push(+x);
        });
        return acc;
      }, [])
      .sort();

    var margin = {
      right: 20,
      left: 10
    };
    var width =
      parseInt(d3.select(this.container).style("width")) -
      margin.left -
      margin.right;
    var height = 130;

    var svg = d3
      .select(this.container)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + 0 + ")");

    // scalePoint derives from the ordinal scale, but allows a continuous range
    var x = d3
      .scalePoint()
      .domain(years)
      .range([0, width]);

    // Invert ordinal scale, from: https://gist.github.com/shimizu/808e0f5cadb6a63f28bb00082dc8fe3f
    x.invert = (function() {
      var domain = x.domain();
      var range = x.range();
      var scale = d3
        .scaleQuantize()
        .domain(range)
        .range(domain);

      return function(x) {
        return scale(x);
      };
    })();

    var slider = svg
      .append("g")
      .attr("class", "slider")
      .attr("transform", "translate(0," + height / 4 + ")");

    slider
      .append("line")
      .attr("class", "track")
      .attr("x1", x.range()[0])
      .attr("x2", x.range()[1])
      .select(function() {
        return this.parentNode.appendChild(this.cloneNode(true));
      })
      .attr("class", "track-inset")
      .select(function() {
        return this.parentNode.appendChild(this.cloneNode(true));
      })
      .attr("class", "track-overlay")
      .call(
        d3
          .drag()
          .on("start.interrupt", () => {
            slider.interrupt();
          })
          .on("start drag", dragged)
          .on("end", endDrag)
      );

    slider
      .append("g")
      .attr("class", "year-circles")
      .attr("transform", "translate(0," + 0 + ")")
      .selectAll("circle")
      .data(years)
      .enter()
      .append("circle")
      .attr("cx", d => x(d))
      .attr("r", 9)
      .call(
        d3
          .drag()
          .on("start.interrupt", () => {
            slider.interrupt();
          })
          .on("start drag", dragged)
          .on("end", endDrag)
      );

    slider
      .append("g")
      .attr("class", "ticks")
      .attr("transform", "translate(0," + 30 + ")")
      .selectAll("text")
      .data(years)
      .enter()
      .append("text")
      .attr("x", d => x(d))
      .text(year => year)
      .classed("active", d => d == currentYear)
      .attr("dx", d => {
        if (d == maxYear) {
          return 10;
        } else if (d == 2010) {
          return -10;
        } else {
          return 0;
        }
      })
      .attr("text-anchor", d => {
        if (d == maxYear) {
          return "end";
        } else if (d == 2010) {
          return "start";
        } else {
          return "middle";
        }
      })
      .call(
        d3
          .drag()
          .on("start.interrupt", () => {
            slider.interrupt();
          })
          .on("start drag", dragged)
          .on("end", endDrag)
      );

    var handle = slider
      .append("circle")
      .attr("class", "handle")
      .attr("cx", x(currentYear))
      .attr("r", 9)
      .call(
        d3
          .drag()
          .on("start.interrupt", () => {
            slider.interrupt();
          })
          .on("start drag", dragged)
          .on("end", endDrag)
      );

    function dragged() {
      var year = x.invert(d3.mouse(this)[0]);
      handle.attr("cx", x(year));

      slider
        .select(".ticks")
        .selectAll("text")
        .classed("active", d => d === year);
    }

    function endDrag() {
      var year = x.invert(d3.mouse(this)[0]);
      $(document).trigger("visSlider:yearChanged", year);
    }
  }
}

import * as d3 from 'd3';
import { accounting } from '../../../lib/shared';

export class VisIndicators {
  constructor(divId, url) {
    this.container = divId;
    this.data = null;
    this.total = null;
    this.genderRatio = null;
    this.eqRatio = null;
    this.avgAge = null;
    this.places = null;
    this.table = null;
    this.dataUrl = url;
  }

  getData() {
    d3.csv(this.dataUrl).then(csvData => {
      // Main dataset
      this.data = csvData;
      this.data.forEach(function(d) {
        d.age = +d.age;
        d.answer = +d.answer;
        d.id = +d.id;
      });

      // Make an object for each participant
      var totalNest = Array.from(
        d3.group(this.data, d => d.id),
        ([key, values]) => ({
          key,
          values
        })
      );

      totalNest.forEach(function(d) {
        d.age = d.values[0].age;
        d.location = d.values[0].location;
      });

      // TOTAL RESPONSES
      this.total = totalNest.length;

      // GENDER RATIO
      var ratioNest = Array.from(
        d3.group(this.data, d => d.gender, d => d.id),
        ([key, values]) => ({
          key,
          values
        })
      );

      this.genderRatio = [
        ratioNest[0].values.length / this.total,
        ratioNest[1].values.length / this.total
      ];

      // EQ / DEFICIT RATIO
      var eqNest = Array.from(
        d3.rollup(this.data, v => d3.sum(v, d => d.answer), d => d.id),
        ([key, value]) => ({
          key,
          value
        })
      );

      this.eqRatio = [
        eqNest.filter(function(d) {
          return d.value < 0;
        }).length / this.total,
        eqNest.filter(function(d) {
          return d.value === 0;
        }).length / this.total,
        eqNest.filter(function(d) {
          return d.value > 0;
        }).length / this.total
      ];

      // AVERAGE AGE
      this.avgAge = d3.mean(totalNest, d => d.age);

      // PLACES COUNT
      var placesNest = Array.from(
        d3.rollup(this.data, v => v.length, d => d.id, d => d.location),
        ([key, values]) => ({
          key,
          values
        })
      );

      this.places = placesNest.map(
        function(d) {
          return {
            location: d.key,
            responses: d.values.length / this.total
          };
        }.bind(this)
      );

      this.places.sort((a, b) => b.responses - a.responses);

      // GET QUESTIONS SUMMARY
      this.table = Array.from(
        d3.rollup(
          this.data,
          d => d.length / this.total,
          d => d.answer,
          d => d.question
        ),
        ([key, values]) => ({
          key,
          values
        })
      );

      this.updateRender();
    });
  }

  render() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  }

  updateRender() {
    var format = d3.format(".0%");

    // TOTAL PARTICIPANTS
    d3.select(".total-participants").text(this.total);

    // PARTICIPANTS GENDER
    var genderClasses = [".ratio-participants-m", ".ratio-participants-w"];

    genderClasses.forEach(
      function(className, i) {
        d3.select(className).text(format(this.genderRatio[i]));
      }.bind(this)
    );

    // SURPLUS, EQ AND DEFICIT
    var budgetClasses = [
      ".ratio-responses-sp",
      ".ratio-responses-eq",
      ".ratio-responses-df"
    ];

    budgetClasses.forEach(
      function(className, i) {
        d3.select(className).text(format(this.eqRatio[i]));
      }.bind(this)
    );

    // AVG AGE
    d3.select(".avg-participants").text(
      accounting.formatNumber(this.avgAge, 0)
    );

    // PLACES LIST
    var placeList = d3
      .select(".location-participants")
      .append("ol")
      .selectAll("li")
      .data(this.places)
      .enter();

    placeList
      .append("li")
      .attr("class", "figure-row")
      .html(function(d) {
        return (
          d.location +
          '<span class="f_right">' +
          format(d.responses) +
          "</span>"
        );
      });

    // TABLE
    var color = d3
      .scaleQuantile()
      .domain([0, 1])
      .range([
        "bg-scale--1",
        "bg-scale--2",
        "bg-scale--3",
        "bg-scale--4",
        "bg-scale--5"
      ]);

    function returnValue(row) {
      return typeof row !== "undefined" ? format(row.value) : "—";
    }

    function customClass(row) {
      return typeof row !== "undefined"
        ? "center number " + color(row.value)
        : "center empty";
    }

    function extractValue(row, key) {
      return row.find(function(d) {
        return d.key === key;
      });
    }

    var columns = [
      {
        head: I18n.t("gobierto_common.visualizations.questions"),
        headCl: "title",
        cl: "title",
        html(d) {
          return d.key;
        }
      },
      {
        head: I18n.t("gobierto_common.visualizations.reduce"),
        headCl: "center",
        cl(d) {
          return customClass(extractValue(d.values, "-5"));
        },
        html(d) {
          return returnValue(extractValue(d.values, "-5"));
        }
      },
      {
        head: I18n.t("gobierto_common.visualizations.keep"),
        headCl: "center",
        cl(d) {
          return customClass(extractValue(d.values, "0"));
        },
        html(d) {
          return returnValue(extractValue(d.values, "0"));
        }
      },
      {
        head: I18n.t("gobierto_common.visualizations.increase"),
        headCl: "center",
        cl(d) {
          return customClass(extractValue(d.values, "5"));
        },
        html(d) {
          return returnValue(extractValue(d.values, "5"));
        }
      }
    ];

    var table = d3.select("#table_report").append("table");

    table
      .append("thead")
      .append("tr")
      .selectAll("th")
      .data(columns)
      .enter()
      .append("th")
      .attr("class", function(d) {
        return d.headCl + " table--header";
      })
      .text(function(d) {
        return d.head;
      });

    table
      .append("tbody")
      .selectAll("tr")
      .data(this.table)
      .enter()
      .append("tr")
      .selectAll("td")
      .data(function(row, i) {
        return columns.map(function(c) {
          var cell = {};

          Object.keys(c).forEach(function(k) {
            cell[k] = typeof c[k] == "function" ? c[k](row, i) : c[k];
          });
          return cell;
        });
      })
      .enter()
      .append("td")
      .html(function(d) {
        return d.html;
      })
      .attr("class", function(d) {
        return d.cl;
      });
  }
}

import crossfilter from "crossfilter2";
import { extent, max, min, sum } from "d3-array";
import { axisBottom } from "d3-axis";
import { csv } from "d3-fetch";
import { format, formatDefaultLocale } from "d3-format";
import { scaleLinear } from "d3-scale";
import { schemeCategory10 } from "d3-scale-chromatic";
import { select, selectAll } from "d3-selection";
import { transition } from "d3-transition";
import populationPyramid from "dc-population-pyramid";
import stackedVertical from "dc-vertical-stacked-bar-chart";
import { DataCount, RowChart, chartRegistry, renderAll, redrawAll, pluck } from "dc";
import * as dc_leaflet from "dc.leaflet";
//https://github.com/Leaflet/Leaflet.markercluster/issues/874
import * as L from "leaflet";
import "leaflet/dist/leaflet.css";

const d3 = {
  csv,
  max,
  min,
  schemeCategory10,
  select,
  selectAll,
  format,
  formatDefaultLocale,
  sum,
  axisBottom,
  extent,
  scaleLinear,
  transition
};

const locale = d3.formatDefaultLocale({
  decimal: ",",
  thousands: ".",
  grouping: [3]
});

function getSQLMonthFilter() {
  //FIXME: JavaScript date
  const month = "06";
  const year = "2020";
  /*const year = today.getFullYear();*/
  /*const month = zeroPad(today.getUTCMonth() + 1, 2);*/

  return ` WHERE to_char(fecha, 'YYYY-MM') = '${year}-${month}'`;
}

function getRemoteData(endpoint) {
  return csv(endpoint);
}

function checkStatus(response) {
  if (response.status >= 200 && response.status < 400) {
    return Promise.resolve(response);
  } else {
    return Promise.reject(new Error(response.statusText));
  }
}

function prepareAgeRange(d) {
  let age_range = "Unknown";
  d.rango_edad = parseInt(d.rango_edad.split("-")[0]);

  if (d.rango_edad <= 10) {
    age_range = "0 - 10";
  } else if (d.rango_edad <= 20) {
    age_range = "11 - 20";
  } else if (d.rango_edad <= 30) {
    age_range = "21 - 30";
  } else if (d.rango_edad <= 40) {
    age_range = "31 - 40";
  } else if (d.rango_edad <= 50) {
    age_range = "41 - 50";
  } else if (d.rango_edad <= 60) {
    age_range = "51 - 60";
  } else if (d.rango_edad <= 70) {
    age_range = "61 - 70";
  } else if (d.rango_edad <= 80) {
    age_range = "71 - 80";
  } else if (d.rango_edad <= 90) {
    age_range = "81 - 90";
  } else if (d.rango_edad < 100) {
    age_range = "91 - 100";
  } else {
    age_range = "+100";
  }
  return [d.sexo, age_range].join(".");
}

async function getMapPolygons(url) {
  const polygonsRequest = new Request(url, { method: "GET" });
  let response = await fetch(polygonsRequest);
  let dataRequest = await checkStatus(response);
  return dataRequest.json();
}

const marginHabNat = { top: 0, right: 0, bottom: 0, left: 0 };
const marginStudies = { top: 0, right: 0, bottom: 0, left: 180 };

export class DemographyMapController {
  constructor(options) {
    const entryPoint = document.getElementById(options.selector);
    const center = [options.mapLat, options.mapLon];

    // Datasets contain the history of all the months, but we only require the last month of data
    const studiesEndpointFiltered = options.studiesEndpoint + getSQLMonthFilter();
    const originEndpointFiltered = options.originEndpoint + getSQLMonthFilter();

    if (entryPoint) {
      Promise.all([
        getRemoteData(studiesEndpointFiltered),
        getRemoteData(originEndpointFiltered),
        getMapPolygons(options.sectionsEndpoint)
      ]).then(rawData => {
        const data = this.buildDataObject(rawData);

        const { studiesData, originData, mapPolygonsData } = data;

        this.currentFilter = "studies"; // options: 'studies' or 'origin'
        let ndxStudies = crossfilter(studiesData);
        let ndxOrigin = crossfilter(originData);
        const spinnerMap = document.getElementById(
          "gobierto_observatory-demography-map-app-container-spinner"
        );
        spinnerMap.classList.add("disable-spinner");
        let geojson = mapPolygonsData;
        this.ndx = {
          filters: {
            studies: {
              all: ndxStudies,
              bySex: ndxStudies.dimension(d => d.sexo),
              byAge: ndxStudies.dimension(d => prepareAgeRange(d)),
              byCusec: ndxStudies.dimension(d => d.cusec),
              byNationality: ndxStudies.dimension(d => d.nacionalidad),
              byOriginNational: null,
              byOriginOther: null,
              byStudies: ndxStudies.dimension(d => d.formacion)
            },
            origin: {
              all: ndxOrigin,
              bySex: ndxOrigin.dimension(d => d.sexo),
              byAge: ndxOrigin.dimension(d => prepareAgeRange(d)),
              byCusec: ndxOrigin.dimension(d => d.cusec),
              byNationality: ndxOrigin.dimension(d => d.nacionalidad),
              byOriginNational: ndxOrigin.dimension(d =>
                d.nacionalidad === "Nacional" ? d.procedencia : "Extranjero"
              ),
              byOriginOther: ndxOrigin.dimension(d =>
                d.nacionalidad === "Extranjero" ? d.procedencia : "Nacional"
              ),
              byStudies: null
            }
          }
        };
        this.calculateGroups();

        this.chart1 = this.renderInhabitants("#inhabitants");
        this.chart2 = this.renderBarNationality("#bar-nationality");
        this.chart3 = this.renderBarSex("#bar-sex");
        this.chart4 = this.renderPyramid("#piramid-age-sex");
        this.chart5 = this.renderStudies("#bar-by-studies");
        this.chart6 = this.renderOriginNational("#bar-by-origin-spaniards");
        this.chart7 = this.renderOriginOthers("#bar-by-origin-others");
        this.chart8 = this.renderChoroplethMap("#map", geojson, center);
        // Don't know why we need to do this
        renderAll("main");

        document.querySelectorAll(".filter-close").forEach(button =>
          button.addEventListener("click", () => {
            this.clearFilters(event);
          })
        );
      });
    }
  }

  calculateGroups() {
    this.ndx.groups = {
      studies: {
        all: this.ndx.filters.studies.all.groupAll().reduceSum(d => d.total),
        bySex: this.ndx.filters.studies.bySex.group().reduceSum(d => d.total),
        byAge: this.ndx.filters.studies.byAge.group().reduceSum(d => d.total),
        byCusec: this.ndx.filters.studies.byCusec
          .group()
          .reduceSum(d => d.total),
        byNationality: this.ndx.filters.studies.byNationality
          .group()
          .reduceSum(d => d.total),
        byOriginNational: null,
        byOriginOther: null,
        byStudies: this.ndx.filters.studies.byStudies
          .group()
          .reduceSum(d => d.total)
      },
      origin: {
        all: this.ndx.filters.origin.all.groupAll().reduceSum(d => d.total),
        bySex: this.ndx.filters.origin.bySex.group().reduceSum(d => d.total),
        byAge: this.ndx.filters.origin.byAge.group().reduceSum(d => d.total),
        byCusec: this.ndx.filters.origin.byCusec
          .group()
          .reduceSum(d => d.total),
        byNationality: this.ndx.filters.origin.byNationality
          .group()
          .reduceSum(d => d.total),
        byOriginNational: this.remove_empty_bins(
          this.ndx.filters.origin.byOriginNational
            .group()
            .reduceSum(d => d.total)
        ),
        byOriginOther: this.remove_empty_bins(
          this.ndx.filters.origin.byOriginOther.group().reduceSum(d => d.total)
        ),
        byStudies: null
      }
    };
  }

  buildDataObject(rawData) {
    const csvData = [rawData[0], rawData[1]];
    const geoData = rawData[2];
    for (let i = 0; i < 2; i++) {
      for (let j = 0; j < csvData[i].length; j++) {
        let d = csvData[i][j];
        // Rewrite cusec to match it with the map cusec
        d["cusec"] = d["seccion"] + "-" + d["distrito"];
        d["total"] = +d["total"];
        if (d["procedencia"] === "") {
          d["procedencia"] = "GETAFE *";
        }
        if (d["formacion"] === "No sabe leer ni escribir") {
          d["formacion"] = "Ni leer ni escribir";
        } else if (d["formacion"] === "Enseñanza Secundaria") {
          d["formacion"] = "Ens. Secundaria";
        } else if (d["formacion"] === "B.Superior.BUP,COU") {
          d["formacion"] = "Bachillerato sup";
        } else if (d["formacion"] === "Enseñanza Primaria incomp") {
          d["formacion"] = "Ens. Pri. incompleta";
        } else if (d["formacion"] === "Doctorado Postgrado") {
          d["formacion"] = "Doctorado";
        } else if (d["formacion"] === "FP1 Grado Medio") {
          d["formacion"] = "Formación prof. 1";
        } else if (d["formacion"] === "FP2 Grado Superior") {
          d["formacion"] = "Formación prof. 2";
        } else if (d["formacion"] === "Licenciado Universitario") {
          d["formacion"] = "Licenciado";
        }
      }
    }

    const sections = {
      type: "FeatureCollection",
      features: geoData.data.map(i => ({
        type: "Feature",
        geometry: JSON.parse(i.geometry),
        properties: {
          cusec: `${i.csec}-${i.cdis}`
        }
      }))
    };

    return {
      studiesData: csvData[0],
      originData: csvData[1],
      mapPolygonsData: sections
    };
  }

  remove_empty_bins(source_group) {
    return {
      all: function() {
        return source_group.all().filter(function(d) {
          return d.key !== "Nacional" && d.key !== "Extranjero";
        });
      }
    };
  }

  updateOriginFilters(dimension, filterValue) {
    if (filterValue.length) {
      filterValue.forEach(v => {
        this.ndx.filters.origin[dimension].filter(v);
      });
    } else {
      this.ndx.filters.origin[dimension].filterAll();
    }
    this.calculateGroups();
  }

  updateStudiesFilters(dimension, filterValue) {
    if (filterValue.length) {
      this.ndx.filters.studies[dimension].filter(filterValue[0]);
    } else {
      this.ndx.filters.studies[dimension].filterAll();
    }
    this.calculateGroups();
  }

  renderInhabitants(selector) {
    const chart = new DataCount(selector, "main");
    chart
      .crossfilter(this.ndx.filters.studies.all)
      .groupAll(this.ndx.groups.studies.all)
      .formatNumber(locale.format(",.0f"))
      .html({
        all:
          '<h2 class="gobierto_observatory-habitants-title">Total habitantes</h2><h3 class="gobierto_observatory-habitants-number">%total-count</h3>',
        some:
          '<h2 class="gobierto_observatory-habitants-title">Habitantes</h2><h3 id="gobierto_observatory-habitants-number" class="gobierto_observatory-habitants-number">%filter-count</h3>'
      });

    const that = this;
    chart.on("filtered", chart => {
      that.updateOriginFilters("all", chart.filters());
    });
    return chart;
  }

  renderBarNationality(selector) {
    const chart = stackedVertical(selector, "main");
    chartRegistry.register(chart, "main");
    const container = document.getElementById("container-bar-nationality");
    const sumAllValues = this.ndx.groups.studies.all.value();
    chart
      .useViewBoxResizing(true)
      .height(45)
      .group(this.ndx.groups.studies.byNationality)
      .dimension(this.ndx.filters.studies.byNationality)
      .elasticX(true)
      .gap(10)
      .margins(marginHabNat)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .title(function(d) {
        const habitants = document.getElementById(
          "gobierto_observatory-habitants-number"
        );
        let habitantsValue = habitants.innerText;
        habitantsValue = habitantsValue.replace(".", "");
        if (chart.hasFilter() && !chart.hasFilter(d.key)) return "0%";
        if (sumAllValues)
          return `${((d.value * 100) / Number(habitantsValue)).toFixed(1)}%`;
      })
      .xAxis()
      .ticks(4);

    const that = this;
    chart.on("filtered", chart => {
      that.updateOriginFilters("byNationality", chart.filters());
      that.activeFiltered(container);
      that.rebuildChoroplethColorDomain();
    });
    return chart;
  }

  renderBarSex(selector) {
    const chart = stackedVertical(selector, "main");
    chartRegistry.register(chart, "main");
    const sumAllValues = this.ndx.groups.studies.all.value();
    chart
      .useViewBoxResizing(true)
      .height(45)
      .group(this.ndx.groups.studies.bySex)
      .dimension(this.ndx.filters.studies.bySex)
      .elasticX(true)
      .gap(10)
      .margins(marginHabNat)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-110)
      .titleLabelOffsetX(145)
      .title(function(d) {
        const habitants = document.getElementById(
          "gobierto_observatory-habitants-number"
        );
        let habitantsValue = habitants.innerText;
        habitantsValue = habitantsValue.replace(".", "");
        if (chart.hasFilter() && !chart.hasFilter(d.key)) return "0%";
        if (sumAllValues)
          return `${((d.value * 100) / Number(habitantsValue)).toFixed(1)}%`;
      })
      .xAxis()
      .ticks(4);

    const that = this;
    chart.on("filtered", chart => {
      that.updateOriginFilters("bySex", chart.filters());
      const container = document.getElementById("container-bar-sex");
      that.activeFiltered(container);
      that.rebuildChoroplethColorDomain();
    });

    return chart;
  }

  renderPyramid(selector) {
    const chart = populationPyramid(selector, "main");
    chartRegistry.register(chart, "main");
    const that = this;

    let group = {
      all: function() {
        var age_ranges = [
          "+100",
          "91 - 100",
          "81 - 90",
          "71 - 80",
          "61 - 70",
          "51 - 60",
          "41 - 50",
          "31 - 40",
          "21 - 30",
          "11 - 20",
          "0 - 10"
        ];

        // convert to object so we can easily tell if a key exists
        var values = {};
        that.ndx.groups.studies.byAge.all().forEach(function(d) {
          // values[d.key[0] + '.' + d.key[1]] = d.value;
          values[d.key] = d.value;
        });

        // convert back into an array for the chart, making sure that all age_ranges exist
        var g = [];
        age_ranges.forEach(function(age_range) {
          g.push({
            key: "Hombre." + age_range,
            value: values["Hombre." + age_range] || 0
          });
          g.push({
            key: "Mujer." + age_range,
            value: values["Mujer." + age_range] || 0
          });
        });
        return g;
      }
    };

    chart.options({
      height: 250,
      labelOffsetX: -50,
      fixedBarHeight: 10,
      gap: 10,
      colorCalculator: function(d) {
        if (d.key.split(".")[0] === "Male") {
          return "#008E9C";
        }
        return "#F8B206";
      },
      // data
      dimension: this.ndx.filters.studies.byAge,
      group: group,
      // misc
      renderTitleLabel: true,
      title: d => d.key.split(".")[1],
      label: d => d.key.split(".")[1],
      cap: 11,
      // if elastic is set than the sub charts will have different extent ranges, which could mean the data is interpreted incorrectly
      elasticX: true,
      // custom
      leftKeyFilter: d => d.key.split(".")[0] === "Hombre",
      rightKeyFilter: d => d.key.split(".")[0] === "Mujer"
    });

    /*This chart is composed of two elements. You've to divide the container. The chart on the left will have the width minus the margin. And the right will have the width plus the margin.*/
    function pyramidResponsive() {
      const containerWidth = document
        .getElementById("piramid-age-sex")
        .getBoundingClientRect();
      const widthChartLeft = containerWidth.width / 2 - 40;
      const widthChartRight = widthChartLeft + 60;
      chart.leftChart().options({ width: widthChartLeft });
      chart.rightChart().options({ width: widthChartRight });
    }
    pyramidResponsive();

    window.addEventListener("resize", function() {
      pyramidResponsive();
      redrawAll("main");
    });

    chart.rightChart().on("filtered", function() {
      const container = document.getElementById("container-piramid-age-sex");
      that.activeFiltered(container);
      that.rebuildChoroplethColorDomain();
      that.updateOriginFilters("byAge", chart.rightChart().filters());

      redrawAll("main");
    });

    chart.leftChart().on("filtered", function() {
      const container = document.getElementById("container-piramid-age-sex");
      that.activeFiltered(container);
      that.rebuildChoroplethColorDomain();
      that.updateOriginFilters("byAge", chart.leftChart().filters());

      redrawAll("main");
    });

    chart.render();
    return chart;
  }

  renderStudies(selector) {
    const chart = new RowChart(selector, "main");
    const sumAllValues = this.ndx.groups.studies.all.value();
    const widthContainer = document.getElementById("container-bar-by-studies").offsetWidth;
    const widthContainerLabelPosition = widthContainer - 240;
    chart
      .useViewBoxResizing(true)
      .height(230)
      .cap(10) // Show only top 10
      .othersGrouper(null) // Don't show the rest of the 20 in Other clashttps://dc-js.github.io/dc.js/docs/html/CapMixin.htmls
      .group(this.ndx.groups.studies.byStudies)
      .dimension(this.ndx.filters.studies.byStudies)
      .elasticX(true)
      .gap(10)
      .margins(marginStudies)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-180)
      .titleLabelOffsetX(widthContainerLabelPosition)
      .title(function(d) {
        const habitants = document.getElementById(
          "gobierto_observatory-habitants-number"
        );
        let habitantsValue;
        if (habitants === null) {
          habitantsValue = "191.386";
        } else {
          habitantsValue = habitants.innerText;
          habitantsValue = habitantsValue.replace(".", "");
        }
        if (chart.hasFilter() && !chart.hasFilter(d.key)) return "0%";
        if (sumAllValues)
          return `${((d.value * 100) / Number(habitantsValue)).toFixed(1)}%`;
      })
      .xAxis()
      .ticks(4);

    const that = this;
    chart.on("filtered", chart => {
      that.currentFilter = "studies";
      const container = document.getElementById("container-bar-by-studies");
      that.activeFiltered(container);

      that.rebuildChoroplethColorDomain();
      if (chart.filter() !== null) {
        document.getElementById(
          "container-bar-by-origin-spaniards"
        ).style.visibility = "hidden";
        document.getElementById(
          "container-bar-by-origin-others"
        ).style.visibility = "hidden";
      } else {
        document.getElementById(
          "container-bar-by-origin-spaniards"
        ).style.visibility = "visible";
        document.getElementById(
          "container-bar-by-origin-others"
        ).style.visibility = "visible";
      }
      redrawAll("main");
    });
    chart.render();
    return chart;
  }

  renderOriginNational(selector) {
    const chart = new RowChart(selector, "main");
    const sumAllValues = this.ndx.groups.studies.all.value();

    const widthContainer = document.getElementById("container-bar-by-studies")
      .offsetWidth;
    const widthContainerLabelPosition = widthContainer - 240;
    chart
      .useViewBoxResizing(true)
      .height(210)
      .cap(10) // Show only top 10
      .othersGrouper(null) // Don't show the rest of the 20 in Other class - https://dc-js.github.io/dc.js/docs/html/CapMixin.html
      .group(this.ndx.groups.origin.byOriginNational)
      .dimension(this.ndx.filters.origin.byOriginNational)
      .elasticX(true)
      .gap(10)
      .margins(marginStudies)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-180)
      .titleLabelOffsetX(widthContainerLabelPosition)
      .title(function(d) {
        const habitants = document.getElementById(
          "gobierto_observatory-habitants-number"
        );
        let habitantsValue = habitants.innerText;
        habitantsValue = habitantsValue.replace(".", "");
        if (chart.hasFilter() && !chart.hasFilter(d.key)) return "0%";
        if (sumAllValues)
          return `${((d.value * 100) / Number(habitantsValue)).toFixed(1)}%`;
      })
      .xAxis()
      .ticks(4);

    const that = this;
    chart.on("filtered", chart => {
      that.currentFilter = "origin";
      const container = document.getElementById(
        "container-bar-by-origin-spaniards"
      );
      that.activeFiltered(container);

      if (chart.filter() !== null) {
        document.getElementById("container-bar-by-studies").style.visibility =
          "hidden";
      } else {
        document.getElementById("container-bar-by-studies").style.visibility =
          "visible";
      }
      that.rebuildChoroplethColorDomain();
      redrawAll("main");
    });
    return chart;
  }

  renderOriginOthers(selector) {
    const chart = new RowChart(selector, "main");
    const sumAllValues = this.ndx.groups.studies.all.value();
    const widthContainer = document.getElementById("container-bar-by-studies")
      .offsetWidth;
    const widthContainerLabelPosition = widthContainer - 240;
    const that = this;
    chart
      .useViewBoxResizing(true)
      .height(210)
      .cap(10) // Show only top 20
      .othersGrouper(null) // Don't show the rest of the 20 in Other clashttps://dc-js.github.io/dc.js/docs/html/CapMixin.htmls
      .group(this.ndx.groups.origin.byOriginOther)
      .dimension(this.ndx.filters.origin.byOriginOther)
      .elasticX(true)
      .gap(10)
      .margins(marginStudies)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-180)
      .titleLabelOffsetX(widthContainerLabelPosition)
      .title(function(d) {
        const habitants = document.getElementById(
          "gobierto_observatory-habitants-number"
        );
        let habitantsValue = habitants.innerText;
        habitantsValue = habitantsValue.replace(".", "");
        if (chart.hasFilter() && !chart.hasFilter(d.key)) return "0%";
        if (sumAllValues)
          return `${((d.value * 100) / Number(habitantsValue)).toFixed(1)}%`;
      })
      .xAxis()
      .ticks(4);

    chart.on("filtered", chart => {
      that.currentFilter = "origin";
      const container = document.getElementById(
        "container-bar-by-origin-others"
      );
      that.activeFiltered(container);
      if (chart.filter() !== null) {
        document.getElementById("container-bar-by-studies").style.visibility =
          "hidden";
      } else {
        document.getElementById("container-bar-by-studies").style.visibility =
          "visible";
      }
      that.rebuildChoroplethColorDomain();
      redrawAll("main");
    });
    return chart;
  }

  renderChoroplethMap(selector, data, center) {
    const zoom = 13.65;
    this.resetMapSelection();
    const chart = new dc_leaflet.choroplethChart(selector, "main");
    chartRegistry.register(chart, "main");
    const legendMap = new dc_leaflet.legend(selector).position("topright");
    const mapboxAccessToken =
      "pk.eyJ1IjoiYmltdXgiLCJhIjoiY2swbmozcndlMDBjeDNuczNscTZzaXEwYyJ9.oMM71W-skMU6IN0XUZJzGQ";
    const scaleColors = [
      "#fcde9c",
      "#faa476",
      "#f0746e",
      "#e34f6f",
      "#dc3977",
      "#b9257a",
      "#7c1d6f"
    ];

    /*Replace bindPopupWithMod from dc.leaflet, the method only accepted the click event to display the popup. We've replaced the click with the mouseover, include mouseout event to close the popup*/
    chart.bindPopupWithMod = function(layer, value) {
      layer.bindPopup(value);
      layer.off("mouseover", layer._openPopup);
      layer.on("mouseover", function(e) {
        if (chart.modKeyMatches(e, chart.popupMod())) layer._openPopup(e);
      });
      layer.on("mouseout", function(e) {
        if (chart.modKeyMatches(e, chart.popupMod())) layer.closePopup(e);
      });
    };

    chart
      .center(center, zoom)
      .zoom(zoom)
      .mapOptions({
        scrollWheelZoom: false
      })
      .dimension(this.ndx.filters.studies.byCusec)
      .group(this.ndx.groups.studies.byCusec)
      .geojson(data.features)
      .colors(scaleColors)
      .colorAccessor(d => d.value)
      .colorDomain([
        d3.min(this.ndx.groups.studies.byCusec.all(), pluck("value")),
        d3.max(this.ndx.groups.studies.byCusec.all(), pluck("value"))
      ])
      .featureKeyAccessor(feature => feature.properties.cusec)
      .legend(legendMap)
      .tiles(function(map) {
        L.tileLayer(
          "https://api.mapbox.com/styles/v1/{username}/{style_id}/tiles/{z}/{x}/{y}?access_token=" +
            mapboxAccessToken,
          {
            scrollWheelZoom: false,
            username: "gobierto",
            style_id: "ck18y48jg11ip1cqeu3b9wpar",
            attribution:
              '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
            tileSize: 512,
            minZoom: 9,
            maxZoom: 16,
            zoomOffset: -1
          }
        ).addTo(map);
      })
      .popup(d => `Habitantes: ${d.value}`);

    chart.on("filtered", () => {
      this.updateOriginFilters("byCusec", chart.filters());
      const buttonReset = document.getElementById("reset-filters");

      const activeFilters = this.getChartById("#map").filters().length;
      if (activeFilters !== 0) {
        buttonReset.classList.remove("disabled");
      } else {
        buttonReset.classList.add("disabled");
      }
      redrawAll("main");
    });

    return chart;
  }

  resetMapSelection() {
    //Remove the selection of 'sección censal'
    const buttonReset = document.getElementById("reset-filters");
    buttonReset.addEventListener("click", () => {
      const chartFromList = this.getChartById("#map")
      chartFromList.filter(null);
      chartFromList.redrawGroup();
      chartFromList._doRedraw();
      buttonReset.classList.add("disabled");
    });
  }

  activeFiltered(container) {
    const { id, className } = container;
    //Get all rect from the chart
    let getRectElements = d3.selectAll(`#${id} svg .row rect`);
    getRectElements = getRectElements._groups[0];
    //Convert rect's to array
    const rectArray = Array.from(getRectElements);
    const element = document.getElementById(id);
    if (className.includes("active-filtered")) {
      setTimeout(() => {
        //Check if all rect's are deselected, if deselected is true so remove active-fitered.
        const deselected = rectArray.every(rect => rect.classList.value === "");
        if (deselected) {
          element.classList.remove("active-filtered");
        } else {
          return false;
        }
      }, 100);
    } else {
      element.classList.toggle("active-filtered");
    }
  }

  //Remove filters when the user click on close button
  clearFilters({ currentTarget }) {
    // Get the container parent from the chart
    const containerChart = currentTarget.parentElement;

    let chart;
    if (containerChart.id === "container-bar-by-studies") {
      //Pass the number of the chart in chartRegisterList
      chart = this.getChartById("#bar-by-studies");
      //Remove active filters
      chart.filter(null);
    } else if (containerChart.id === "container-bar-nationality") {
      chart = this.getChartById("#bar-nationality");
      chart.filter(null);
    } else if (containerChart.id === "container-bar-by-origin-spaniards") {
      chart = this.getChartById("#bar-by-origin-spaniards");
      chart.filter(null);
    } else if (containerChart.id === "container-bar-by-origin-others") {
      chart = this.getChartById("#bar-by-origin-others");
      chart.filter(null);
    } else if (containerChart.id === "container-bar-sex") {
      chart = this.getChartById("#bar-sex");
      chart.filter(null);
    } else if (containerChart.id === "container-piramid-age-sex") {
      //Piramid Chart is compose by two children rowChart()
      chart = this.getChartById("#piramid-age-sex");
      //We need to reset filters from both charts
      chart.leftChart().filter(null);
      chart.rightChart().filter(null);
    }

    //Redraw
    chart.redrawGroup();

    setTimeout(() => {
      containerChart.classList.remove("active-filtered");
    }, 0);
  }

  getChartById(id) {
    // Search the chart based on its #id
    return chartRegistry.list("main").find(({ _anchor }) => id === _anchor)
  }

  //When the user interactive with the filter we need to rebuild color domain for update choroplethChart
  rebuildChoroplethColorDomain() {
    //Get the Map from the register list
    const choroplethChart = this.getChartById("#map");
    //Rebuild color domain with the selected values.
    if (this.currentFilter === "studies") {
      choroplethChart
        .dimension(this.ndx.filters.studies.byCusec)
        .group(this.ndx.groups.studies.byCusec)
        .colorDomain([
          d3.min(this.ndx.groups.studies.byCusec.all(), pluck("value")),
          d3.max(this.ndx.groups.studies.byCusec.all(), pluck("value"))
        ]);
    } else {
      choroplethChart
        .dimension(this.ndx.filters.origin.byCusec)
        .group(this.ndx.groups.origin.byCusec)
        .colorDomain([
          d3.min(this.ndx.groups.origin.byCusec.all(), pluck("value")),
          d3.max(this.ndx.groups.origin.byCusec.all(), pluck("value"))
        ]);
    }
  }
}

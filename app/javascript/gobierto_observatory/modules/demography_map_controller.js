import { csv } from "d3-request";
import { max, min } from "d3-array";
import * as dc from 'dc'
import crossfilter from 'crossfilter2'
//https://github.com/Leaflet/Leaflet.markercluster/issues/874
import * as L from 'leaflet';
import * as dc_leaflet from 'dc.leaflet';
import 'leaflet/dist/leaflet.css';

const d3 = { csv, max, min }

function getRemoteData(endpoint) {
  return new Promise((resolve) => {
    d3.csv(endpoint)
      .mimeType("text/csv")
      .get(function(error, csv) {
        if (error) throw error;
        resolve(csv);
      });
  })
}

let initObject = { method: 'GET' };

function checkStatus(response) {
  if (response.status >= 200 && response.status < 400) {
    return Promise.resolve(response)
  } else {
    return Promise.reject(new Error(response.statusText))
  }
}

const userRequest = new Request('https://demo-datos.gobify.net/api/v1/data/data?sql=select%20geometry,csec,cdis%20from%20secciones_censales%20where%20cumun=28065', initObject);

async function getData() {
  let response = await fetch(userRequest);
  let dataRequest = await checkStatus(response);
  let data = dataRequest.json()
  return data;
}


// Estudios
// seccion,distrito,rango_edad,sexo,nacionalidad,formacion,total
// 2,1,0 - 4,Hombre,Extranjero,Menores de 16,1
// -----
//
// Origen
// seccion,distrito,rango_edad,sexo,nacionalidad,procedencia,total
// 16,2,60 - 64,Mujer,Nacional,MADRID,22
// -----
//
// Dimensiones
// sexo
// rango-edad
// seccion
// distrito

export class DemographyMapController {
  constructor(options) {
    // Mount Vue applications
    const entryPoint = document.getElementById(options.selector);

    if (entryPoint) {
      Promise.all([getRemoteData(options.studiesEndpoint), getRemoteData(options.originEndpoint), getData()]).then((rawData) => {
        const data = this.buildDataObject(rawData)
        console.log("data", data);

        const { studiesData, originData, getafeData } = data

        this.currentFilter = 'studies'; // options: 'studies' or 'origin'
        let ndxStudies = crossfilter(studiesData);
        let ndxOrigin = crossfilter(originData);
        let geojson = getafeData
        this.ndx = {
          filters: {
            studies: {
              all: ndxStudies,
              bySex: ndxStudies.dimension(d => d.sexo),
              byAge: ndxStudies.dimension(d => parseInt(d.rango_edad.split('-')[0])),
              byCusec: ndxStudies.dimension(d => d.cusec),
              byNationality: ndxStudies.dimension(d => d.nacionalidad),
              byOriginNational: null,
              byOriginOther: null,
              byStudies: ndxStudies.dimension(d => d.formacion),
            },
            origin: {
              all: ndxOrigin,
              bySex: ndxOrigin.dimension(d => d.sexo),
              byAge: ndxOrigin.dimension(d => parseInt(d.rango_edad.split('-')[0])),
              byCusec: ndxOrigin.dimension(d => d.cusec),
              byNationality: ndxOrigin.dimension(d => d.nacionalidad),
              byOriginNational: ndxOrigin.dimension(d => d.nacionalidad === 'Nacional' ? d.procedencia : null),
              byOriginOther: ndxOrigin.dimension(d => d.nacionalidad === 'Extranjero' ? d.procedencia : null),
              byStudies: null,
            },
          }
        }
        this.calculateGroups();
        this.chart1 = this.renderInhabitants("#inhabitants");
        this.chart2 = this.renderBarNationality("#bar-nationality");
        this.chart3 = this.renderBarSex("#bar-sex");
        this.chart4 = this.renderPiramid("#piramid-age-sex");
        this.chart5 = this.renderStudies("#bar-by-studies");
        this.chart6 = this.renderOriginNational("#bar-by-origin-spaniards");
        this.chart7 = this.renderOriginOthers("#bar-by-origin-others");
        this.chart8 = this.renderChoroplethMap("#map", geojson);
        // Don't know why we need to do this
        dc.chartRegistry.register(this.chart8, "main");
        dc.renderAll("main");
      });
    }
  }

  calculateGroups() {
    this.ndx.groups = {
      studies: {
        all: this.ndx.filters.studies.all.groupAll().reduceSum(d => d.total),
        bySex: this.ndx.filters.studies.bySex.group().reduceSum(d => d.total),
        byAge: this.ndx.filters.studies.byAge.group().reduceSum(d => d.total),
        byCusec: this.ndx.filters.studies.byCusec.group().reduceSum(d => d.total),
        byNationality: this.ndx.filters.studies.byNationality.group().reduceSum(d => d.total),
        byOriginNational: null,
        byOriginOther: null,
        byStudies: this.ndx.filters.studies.byStudies.group().reduceSum(d => d.total),
      },
      origin: {
        all: this.ndx.filters.origin.all.groupAll().reduceSum(d => d.total),
        bySex: this.ndx.filters.origin.bySex.group().reduceSum(d => d.total),
        byAge: this.ndx.filters.origin.byAge.group().reduceSum(d => d.total),
        byCusec: this.ndx.filters.origin.byCusec.group().reduceSum(d => d.total),
        byNationality: this.ndx.filters.origin.byNationality.group().reduceSum(d => d.total),
        byOriginNational: this.remove_empty_bins(this.ndx.filters.origin.byOriginNational.group().reduceSum(d => d.total)),
        byOriginOther: this.remove_empty_bins(this.ndx.filters.origin.byOriginOther.group().reduceSum(d => d.total)),
        byStudies: null,
      }
    }
  }

  buildDataObject(rawData) {
    const csvData = [rawData[0], rawData[1]]
    const geoData = rawData[2]
    for (let i = 0; i < 2; i++) {
      for (let j = 0; j < csvData[i].length; j++) {
        let d = csvData[i][j];
        d['cusec'] = d['seccion'] + '-' + d['distrito']
        d['total'] = +d['total']
      }
    }

    const sections = {
      "type": "FeatureCollection",
      "features": geoData.data.map(i => ({
        "type": "Feature",
        "geometry": JSON.parse(i.geometry),
        "properties": {
          "cusec": `${i.csec}-${i.cdis}`
        }
      }))
    }

    return {
      studiesData: csvData[0],
      originData: csvData[1],
      getafeData: sections
    }
  }

  remove_empty_bins(source_group) {
    return {
      all: function() {
        return source_group.all().filter(function(d) {
          // return Math.abs(d.value) > 0.00001; // if using floating-point numbers
          return d.key !== null;
        });
      }
    };
  }

  updateOriginFilters(dimension, filterValue) {
    if (filterValue.length) {
      this.ndx.filters.origin[dimension].filter(filterValue[0]);
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
    const chart = new dc.dataCount(selector, "main");
    chart
      .crossfilter(this.ndx.filters.studies.all)
      .groupAll(this.ndx.groups.studies.all)
      .html({
        all: '<strong>%total-count</strong> habitantes',
        some: '<strong>%filter-count</strong>/total habitantes'
      })

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.updateOriginFilters('all', chart.filters());
      });
    return chart;
  }

  renderBarNationality(selector) {
    const chart = new dc.rowChart(selector, "main");
    chart
      .width(300)
      .height(100)
      .group(this.ndx.groups.studies.byNationality)
      .dimension(this.ndx.filters.studies.byNationality)
      .colors('#FF776D')
      .elasticX(true)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.updateOriginFilters('byNationality', chart.filters());
      });
    return chart;
  }

  renderBarSex(selector) {
    const chart = new dc.rowChart(selector, "main");

    chart
      .width(300)
      .height(100)
      .group(this.ndx.groups.studies.bySex)
      .dimension(this.ndx.filters.studies.bySex)
      .colors('#FF776D')
      .elasticX(true)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.updateOriginFilters('bySex', chart.filters());
      });

    return chart;
  }

  renderPiramid(selector) {
    const chart = new dc.rowChart(selector, "main");

    chart
      .width(300)
      .height(250)
      .group(this.ndx.groups.studies.byAge)
      .dimension(this.ndx.filters.studies.byAge)
      .colors('#FF776D')
      .elasticX(true)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.updateOriginFilters('byAge', chart.filters());
      });
    return chart;
  }

  renderStudies(selector) {
    const chart = new dc.rowChart(selector, "main");

    chart
      .width(300)
      .height(250)
      .cap(10) // Show only top 20
      .group(this.ndx.groups.studies.byStudies)
      .dimension(this.ndx.filters.studies.byStudies)
      .colors('#FF776D')
      .elasticX(true)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.currentFilter = 'studies';
        if (chart.filter() !== null) {
          document.getElementById("bar-by-origin-spaniards").style.display = 'none';
          document.getElementById("bar-by-origin-others").style.display = 'none';
        } else {
          document.getElementById("bar-by-origin-spaniards").style.display = 'block';
          document.getElementById("bar-by-origin-others").style.display = 'block';
        }
      });
    return chart;
  }

  renderOriginNational(selector) {
    const chart = new dc.rowChart(selector, "main");

    chart
      .width(300)
      .height(250)
      .cap(10) // Show only top 20
      .othersGrouper(null) // Don't show the rest of the 20 in Other class - https://dc-js.github.io/dc.js/docs/html/CapMixin.html
      .group(this.ndx.groups.origin.byOriginNational)
      .dimension(this.ndx.filters.origin.byOriginNational)
      .colors('#FF776D')
      .elasticX(true)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.currentFilter = 'origin';
        if (chart.filter() !== null) {
          document.getElementById("bar-by-studies").style.display = 'none';
        } else {
          document.getElementById("bar-by-studies").style.display = 'block';
        }
        that.updateStudiesFilters('all', chart.filters());
        that.chart1.dimension(that.ndx.filters.origin.all);
        that.chart1.group(that.ndx.groups.origin.all);
        that.chart2.dimension(that.ndx.filters.origin.byNationality);
        that.chart2.group(that.ndx.groups.origin.byNationality);
        that.chart3.dimension(that.ndx.filters.origin.bySex);
        that.chart3.group(that.ndx.groups.origin.bySex);
        that.chart8.dimension(that.ndx.filters.origin.byCusec);
        that.chart8.group(that.ndx.groups.origin.byCusec);
      });
    return chart;
  }

  renderOriginOthers(selector) {
    const chart = new dc.rowChart(selector, "main");

    chart
      .width(300)
      .height(380)
      .cap(10) // Show only top 20
      .othersGrouper(null) // Don't show the rest of the 20 in Other clashttps://dc-js.github.io/dc.js/docs/html/CapMixin.htmls
      .group(this.ndx.groups.origin.byOriginOther)
      .dimension(this.ndx.filters.origin.byOriginOther)
      .colors('#FF776D')
      .elasticX(true)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.currentFilter = 'origin';
        if (chart.filter() !== null) {
          document.getElementById("bar-by-studies").style.display = 'none';
        } else {
          document.getElementById("bar-by-studies").style.display = 'block';
        }
        that.chart1.dimension(that.ndx.filters.origin.all);
        that.chart1.group(that.ndx.groups.origin.all);
        that.chart2.dimension(that.ndx.filters.origin.byNationality);
        that.chart2.group(that.ndx.groups.origin.byNationality);
        that.chart3.dimension(that.ndx.filters.origin.bySex);
        that.chart3.group(that.ndx.groups.origin.bySex);
        that.chart8.dimension(that.ndx.filters.origin.byCusec);
        that.chart8.group(that.ndx.groups.origin.byCusec);
      });
    return chart;
  }

  renderChoroplethMap(selector, data) {
    const chart = new dc_leaflet.choroplethChart(selector, "#main");
    const legendMap = new dc_leaflet.legend(selector).position('bottomright');
    const mapboxAccessToken = "pk.eyJ1IjoiZmVyYmxhcGUiLCJhIjoiY2pqMzNnZjcxMTY1NjNyczI2ZXQ0dm1rYiJ9.yUynmgYKzaH4ALljowiFHw";

    chart
      .center([40.309, -3.680], 13.45)
      .zoom(13)
      .dimension(this.ndx.filters.studies.byCusec)
      .group(this.ndx.groups.studies.byCusec)
      .geojson(data.features)
      .colorDomain([
          0,
          d3.max(this.ndx.groups.studies.byCusec.all(), dc.pluck('value'))
      ])
      .colorAccessor(d => d.value)
      .featureKeyAccessor(feature => feature.properties.cusec)
      .legend(legendMap)
      .tiles(function(map) {
        L.tileLayer('https://api.mapbox.com/styles/v1/{username}/{style_id}/tiles/{z}/{x}/{y}?access_token=' + mapboxAccessToken, {
          username: "gobierto",
          style_id: "ck18y48jg11ip1cqeu3b9wpar",
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
          tileSize: 512,
          minZoom: 9,
          maxZoom: 16,
          zoomOffset: -1
        }).addTo(map);
      })
    return chart;
  }
}

export default getRemoteData

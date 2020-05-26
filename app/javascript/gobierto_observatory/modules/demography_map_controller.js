import { csv } from "d3-request";
import { format, formatDefaultLocale } from 'd3-format'
import { select, selectAll } from 'd3-selection';
import { max, min, sum, extent } from "d3-array";
import { schemeCategory10, scaleLinear } from 'd3-scale'
import { axisBottom } from 'd3-axis'
import dc from 'dc'
import crossfilter from 'crossfilter2'
//https://github.com/Leaflet/Leaflet.markercluster/issues/874
import * as L from 'leaflet';
import * as dc_leaflet from 'dc.leaflet';
import 'leaflet/dist/leaflet.css';
import pairedRow from 'dc-addons-paired-row'

const d3 = { csv, max, min, schemeCategory10, select, selectAll, format, formatDefaultLocale, sum, axisBottom, extent, scaleLinear }

var stackedChart = function (parent, chartGroup) {

    var _g;

    var _labelOffsetX = 10;
    var _labelOffsetY = 15;
    var _hasLabelOffsetY = false;
    var _dyOffset = '0.35em';  // this helps center labels https://github.com/d3/d3-3.x-api-reference/blob/master/SVG-Shapes.md#svg_text
    var _titleLabelOffsetX = 2;

    var _gap = 5;

    var _fixedBarHeight = false;
    var _rowCssClass = 'row';
    var _titleRowCssClass = 'titlerow';
    var _renderTitleLabel = false;

    var _chart = dc.capMixin(dc.marginMixin(dc.colorMixin(dc.baseMixin({}))));

    var _x;

    var _elasticX;

    var _xAxis = d3.axisBottom();

    var _rowData;

    _chart.rowsCap = _chart.cap;

    function calculateAxisScale () {
        if (!_x || _elasticX) {
            var extent = d3.extent(_rowData, _chart.cappedValueAccessor);
            if (extent[0] > 0) {
                extent[0] = 0;
            }
            if (extent[1] < 0) {
                extent[1] = 0;
            }
            _x = d3.scaleLinear().domain(extent)
                .range([0, _chart.effectiveWidth()]);
        }
        _xAxis.scale(_x);
    }

    function drawAxis () {
        var axisG = _g.select('g.axis');

        calculateAxisScale();

        if (axisG.empty()) {
            axisG = _g.append('g').attr('class', 'axis');
        }
        axisG.attr('transform', 'translate(0, ' + _chart.effectiveHeight() + ')');

        dc.transition(axisG, _chart.transitionDuration(), _chart.transitionDelay())
            .call(_xAxis);
    }

    _chart._doRender = function () {
        _chart.resetSvg();

        _g = _chart.svg()
            .append('g')
            .attr('transform', 'translate(' + _chart.margins().left + ',' + _chart.margins().top + ')');

        drawChart();

        return _chart;
    };

    _chart.title(function (d) {
        return _chart.cappedKeyAccessor(d) + ': ' + _chart.cappedValueAccessor(d);
    });

    _chart.label(_chart.cappedKeyAccessor);

    /**
     * Gets or sets the x scale. The x scale can be any d3
     * {@link https://github.com/d3/d3-scale/blob/master/README.md d3.scale}.
     * @method x
     * @memberof dc.rowChart
     * @instance
     * @see {@link https://github.com/d3/d3-scale/blob/master/README.md d3.scale}
     * @param {d3.scale} [scale]
     * @returns {d3.scale|dc.rowChart}
     */
    _chart.x = function (scale) {
        if (!arguments.length) {
            return _x;
        }
        _x = scale;
        return _chart;
    };

    function drawGridLines () {
        _g.selectAll('g.tick')
            .select('line.grid-line')
            .remove();

        _g.selectAll('g.tick')
            .append('line')
            .attr('class', 'grid-line')
            .attr('x1', 0)
            .attr('y1', 0)
            .attr('x2', 0)
            .attr('y2', function () {
                return -_chart.effectiveHeight();
            });
    }

    function drawChart () {
        _rowData = _chart.data();

        drawAxis();
        drawGridLines();

        var rows = _g.selectAll('g.' + _rowCssClass)
            .data(_rowData);

        removeElements(rows);
        rows = createElements(rows)
            .merge(rows);
        updateElements(rows);
    }

    function createElements (rows) {
        var rowEnter = rows.enter()
            .append('g')
            .attr('class', function (d, i) {
                return _rowCssClass + ' _' + i;
            });

        rowEnter.append('rect').attr('width', 0);

        createLabels(rowEnter);

        return rowEnter;
    }

    function removeElements (rows) {
        rows.exit().remove();
    }

    function rootValue () {
        var root = _x(0);
        return (root === -Infinity || root !== root) ? _x(1) : root;
    }

    function updateElements (rows) {
        var n = _rowData.length;
        _g = _chart.svg()
        const widthSvg = _g._groups[0][0].clientWidth
        const totalValues = _rowData[0].value + _rowData[1].value

        /*const percentageFirstValue = ((d.value * 100) / totalValues).toFixed(1)*/
        /*const percentageSecondValue = ((d.value * 100) / totalValues).toFixed(1)*/

        var height;
        if (!_fixedBarHeight) {
            height = (_chart.effectiveHeight() - (n + 1) * _gap) / n;
        } else {
            height = _fixedBarHeight;
        }

        // vertically align label in center unless they override the value via property setter
        if (!_hasLabelOffsetY) {
            _labelOffsetY = height / 2;
        }

        var rect = rows.attr('transform', function (d, i) {
            return 'translate(0,0)';
        }).select('rect')
            .attr('height', height)
            .attr('fill', _chart.getColor)
            .on('click', onClick)
            .classed('deselected', function (d) {
                return (_chart.hasFilter()) ? !isSelectedRow(d) : false;
            })
            .classed('selected', function (d) {
                return (_chart.hasFilter()) ? isSelectedRow(d) : false;
            });

        dc.transition(rect, _chart.transitionDuration(), _chart.transitionDelay())
            .attr('width', function (d) {
              return (((d.value * 100) / totalValues).toFixed(1) * widthSvg) / 100
            })
            .attr('transform', translateX);


        rows.select('.row._1 rect')
          .attr('x', function() {
            return (widthSvg - (((_rowData[1].value * 100) / totalValues).toFixed(1) * widthSvg) / 100) + 5
          })

        createTitles(rows);
        updateLabels(rows);
    }

    function createTitles (rows) {
        if (_chart.renderTitle()) {
            rows.select('title').remove();
            rows.append('title').text(_chart.title());
        }
    }

    function createLabels (rowEnter) {
        if (_chart.renderLabel()) {
            rowEnter.append('text')
                .on('click', onClick);
        }
        if (_chart.renderTitleLabel()) {
            rowEnter.append('text')
                .attr('class', _titleRowCssClass)
                .on('click', onClick);
        }
    }

    function updateLabels (rows) {
        if (_chart.renderLabel()) {
            var lab = rows.select('text')
                .attr('x', _labelOffsetX)
                .attr('y', _labelOffsetY)
                .attr('dy', _dyOffset)
                .on('click', onClick)
                .attr('class', function (d, i) {
                    return _rowCssClass + ' _' + i;
                })
                .attr('id', function (d, i) {
                    return 'text-label' + '_' + i;
                })
                .text(function (d) {
                    return _chart.label()(d);
                });

            _g = _chart.svg()
            const widthSvg = _g._groups[0][0].clientWidth
            const widthLabelText1 = document.getElementById("text-label_1").getBBox().width
            const translateLabel1 = widthSvg - widthLabelText1

            rows.select('.row._1 text._1')
              .attr('x', translateLabel1)
              .attr('y', 20)

            rows.select('.row._0 text._0')
              .attr('x', 0)
              .attr('y', 20)

            dc.transition(lab, _chart.transitionDuration(), _chart.transitionDelay())
                .attr('transform', translateX);
        }
        if (_chart.renderTitleLabel()) {
            var titlelab = rows.select('.' + _titleRowCssClass)
                    .attr('x', _chart.effectiveWidth() - _titleLabelOffsetX)
                    .attr('y', _labelOffsetY)
                    .attr('dy', _dyOffset)
                    .attr('text-anchor', 'end')
                    .on('click', onClick)
                    .attr('class', function (d, i) {
                        return _titleRowCssClass + ' _' + i ;
                    })
                    .attr('id', function (d, i) {
                        return 'titlerow' + '_' + i ;
                    })
                    .text(function (d) {
                        return _chart.title()(d);
                    });

            const widthLabelText0 = document.getElementById("text-label_0").getBBox().width
            const widthLabelTitle0 = document.getElementById("titlerow_0").getBBox().width
            const translateTitleRow0 = widthLabelText0 + widthLabelTitle0
            rows.select('.row._0 .titlerow._0')
              .attr('x', translateTitleRow0)
              .attr('y', 20)

            _g = _chart.svg()
            const widthSvg = _g._groups[0][0].clientWidth
            const widthLabelText1 = document.getElementById("text-label_1").getBBox().width
            const widthLabelTitle1 = document.getElementById("titlerow_1").getBBox().width
            const translateTitleRow1 = widthSvg - widthLabelText1 - 5

            rows.select('.row._1 .titlerow._1')
              .attr('x', translateTitleRow1)
              .attr('y', 20)


            dc.transition(titlelab, _chart.transitionDuration(), _chart.transitionDelay())
                .attr('transform', translateX);
        }
    }

    /**
     * Turn on/off Title label rendering (values) using SVG style of text-anchor 'end'.
     * @method renderTitleLabel
     * @memberof dc.rowChart
     * @instance
     * @param {Boolean} [renderTitleLabel=false]
     * @returns {Boolean|dc.rowChart}
     */
    _chart.renderTitleLabel = function (renderTitleLabel) {
        if (!arguments.length) {
            return _renderTitleLabel;
        }
        _renderTitleLabel = renderTitleLabel;
        return _chart;
    };

    function onClick (d) {
        _chart.onClick(d);
    }

    function translateX (d) {
        var x = _x(_chart.cappedValueAccessor(d)),
            x0 = rootValue(),
            s = x > x0 ? x0 : x;
        return 'translate(' + s + ',0)';
    }

    _chart._doRedraw = function () {
        drawChart();
        return _chart;
    };

    /**
     * Get or sets the x axis for the row chart instance.
     * See the {@link https://github.com/d3/d3-axis/blob/master/README.md d3.axis}
     * documention for more information.
     * @method xAxis
     * @memberof dc.rowChart
     * @instance
     * @param {d3.axis} [xAxis]
     * @example
     * // customize x axis tick format
     * chart.xAxis().tickFormat(function (v) {return v + '%';});
     * // customize x axis tick values
     * chart.xAxis().tickValues([0, 100, 200, 300]);
     * // use a top-oriented axis. Note: position of the axis and grid lines will need to
     * // be set manually, see https://dc-js.github.io/dc.js/examples/row-top-axis.html
     * chart.xAxis(d3.axisTop())
     * @returns {d3.axis|dc.rowChart}
     */
    _chart.xAxis = function (xAxis) {
        if (!arguments.length) {
            return _xAxis;
        }
        _xAxis = xAxis;
        return this;
    };

    /**
     * Get or set the fixed bar height. Default is [false] which will auto-scale bars.
     * For example, if you want to fix the height for a specific number of bars (useful in TopN charts)
     * you could fix height as follows (where count = total number of bars in your TopN and gap is
     * your vertical gap space).
     * @method fixedBarHeight
     * @memberof dc.rowChart
     * @instance
     * @example
     * chart.fixedBarHeight( chartheight - (count + 1) * gap / count);
     * @param {Boolean|Number} [fixedBarHeight=false]
     * @returns {Boolean|Number|dc.rowChart}
     */
    _chart.fixedBarHeight = function (fixedBarHeight) {
        if (!arguments.length) {
            return _fixedBarHeight;
        }
        _fixedBarHeight = fixedBarHeight;
        return _chart;
    };

    /**
     * Get or set the vertical gap space between rows on a particular row chart instance.
     * @method gap
     * @memberof dc.rowChart
     * @instance
     * @param {Number} [gap=5]
     * @returns {Number|dc.rowChart}
     */
    _chart.gap = function (gap) {
        if (!arguments.length) {
            return _gap;
        }
        _gap = gap;
        return _chart;
    };

    /**
     * Get or set the elasticity on x axis. If this attribute is set to true, then the x axis will rescale to auto-fit the
     * data range when filtered.
     * @method elasticX
     * @memberof dc.rowChart
     * @instance
     * @param {Boolean} [elasticX]
     * @returns {Boolean|dc.rowChart}
     */
    _chart.elasticX = function (elasticX) {
        if (!arguments.length) {
            return _elasticX;
        }
        _elasticX = elasticX;
        return _chart;
    };

    /**
     * Get or set the x offset (horizontal space to the top left corner of a row) for labels on a particular row chart.
     * @method labelOffsetX
     * @memberof dc.rowChart
     * @instance
     * @param {Number} [labelOffsetX=10]
     * @returns {Number|dc.rowChart}
     */
    _chart.labelOffsetX = function (labelOffsetX) {
        if (!arguments.length) {
            return _labelOffsetX;
        }
        _labelOffsetX = labelOffsetX;
        return _chart;
    };

    /**
     * Get or set the y offset (vertical space to the top left corner of a row) for labels on a particular row chart.
     * @method labelOffsetY
     * @memberof dc.rowChart
     * @instance
     * @param {Number} [labelOffsety=15]
     * @returns {Number|dc.rowChart}
     */
    _chart.labelOffsetY = function (labelOffsety) {
        if (!arguments.length) {
            return _labelOffsetY;
        }
        _labelOffsetY = labelOffsety;
        _hasLabelOffsetY = true;
        return _chart;
    };

    /**
     * Get of set the x offset (horizontal space between right edge of row and right edge or text.
     * @method titleLabelOffsetX
     * @memberof dc.rowChart
     * @instance
     * @param {Number} [titleLabelOffsetX=2]
     * @returns {Number|dc.rowChart}
     */
    _chart.titleLabelOffsetX = function (titleLabelOffsetX) {
        if (!arguments.length) {
            return _titleLabelOffsetX;
        }
        _titleLabelOffsetX = titleLabelOffsetX;
        return _chart;
    };

    function isSelectedRow (d) {
        return _chart.hasFilter(_chart.cappedKeyAccessor(d));
    }

    return _chart.anchor(parent, chartGroup);
};

const locale = d3.formatDefaultLocale({
  decimal: ',',
  thousands: '.',
  grouping: [3]
});

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

const marginHabNat = { top: 0, right: 0, bottom: 0, left: 0 }
const marginStudies = { top: 0, right: 0, bottom: 0, left: 180 }

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

        const { studiesData, originData, getafeData } = data

        this.currentFilter = 'studies'; // options: 'studies' or 'origin'
        let ndxStudies = crossfilter(studiesData);
        let ndxOrigin = crossfilter(originData);
        let geojson = getafeData
        this.ndx = {
          filters: {
            studies: {
              /*d => parseInt(d.rango_edad.split('-')[0])*/
              all: ndxStudies,
              bySex: ndxStudies.dimension(d => d.sexo),
              byAge: ndxStudies.dimension(function(d) {
                var age_range = 'Unknown';
                d.rango_edad = parseInt(d.rango_edad.split('-')[0])

                if (d.rango_edad <= 10) {
                  age_range = '0-10';
                } else if (d.rango_edad <= 20) {
                  age_range = '11-20';
                } else if (d.rango_edad <= 30) {
                  age_range = '21-30';
                } else if (d.rango_edad <= 40) {
                  age_range = '31-40';
                } else if (d.rango_edad <= 50) {
                  age_range = '41-50';
                } else if (d.rango_edad <= 60) {
                  age_range = '51-60';
                } else if (d.rango_edad <= 70) {
                  age_range = '61-70';
                } else if (d.rango_edad <= 80) {
                  age_range = '71-80';
                } else if (d.rango_edad <= 90) {
                  age_range = '81-90';
                } else if (d.rango_edad <= 100) {
                  age_range = '91-100';
                }
                return [d.sexo, age_range];
              }),
              byCusec: ndxStudies.dimension(d => d.cusec),
              byNationality: ndxStudies.dimension(d => d.nacionalidad),
              byOriginNational: null,
              byOriginOther: null,
              byStudies: ndxStudies.dimension(d => d.formacion),
            },
            origin: {
              all: ndxOrigin,
              bySex: ndxOrigin.dimension(d => d.sexo),
              byAge: ndxOrigin.dimension(function(d) {
                var age_range = 'Unknown';
                d.rango_edad = parseInt(d.rango_edad.split('-')[0])

                if (d.rango_edad <= 10) {
                  age_range = '0-10';
                } else if (d.rango_edad <= 20) {
                  age_range = '11-20';
                } else if (d.rango_edad <= 30) {
                  age_range = '21-30';
                } else if (d.rango_edad <= 40) {
                  age_range = '31-40';
                } else if (d.rango_edad <= 50) {
                  age_range = '41-50';
                } else if (d.rango_edad <= 60) {
                  age_range = '51-60';
                } else if (d.rango_edad <= 70) {
                  age_range = '61-70';
                } else if (d.rango_edad <= 80) {
                  age_range = '71-80';
                } else if (d.rango_edad <= 90) {
                  age_range = '81-90';
                } else if (d.rango_edad <= 100) {
                  age_range = '91-100';
                }
                return [d.sexo, age_range];
              }),
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
        this.chart4 = this.renderPyramid("#piramid-age-sex");
        this.chart5 = this.renderStudies("#bar-by-studies");
        this.chart6 = this.renderOriginNational("#bar-by-origin-spaniards");
        this.chart7 = this.renderOriginOthers("#bar-by-origin-others");
        this.chart8 = this.renderChoroplethMap("#map", geojson);
        // Don't know why we need to do this
        dc.chartRegistry.register(this.chart8, "main");
        dc.renderAll("main");

        document.querySelectorAll("#close").forEach(button => button.addEventListener('click', () => {
          this.clearFilters(event)
        }));
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
        if (d['formacion'] === 'No sabe leer ni escribir') {
          d['formacion'] = 'Ni leer ni escribir'
        } else if (d['formacion'] === 'Ense?anza Secundaria') {
          d['formacion'] = 'Ens. Secundaria'
        } else if (d['formacion'] === 'B.Superior.BUP,COU') {
          d['formacion'] = 'Bachillerato sup'
        } else if (d['formacion'] === 'Ense?anza Primaria incomp') {
          d['formacion'] = 'Ens. Pri. incompleta'
        } else if (d['formacion'] === 'Doctorado Postgrado') {
          d['formacion'] = 'Doctorado'
        } else if (d['formacion'] === 'Doctorado Postgrado') {
          d['formacion'] = 'Doctorado'
        } else if (d['formacion'] === 'FP1 Grado Medio') {
          d['formacion'] = 'Formación prof. 1'
        } else if (d['formacion'] === 'FP2 Grado Superior') {
          d['formacion'] = 'Formación prof. 2'
        } else if (d['formacion'] === 'Licenciado Universitario') {
          d['formacion'] = 'Licenciado'
        }
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
      .formatNumber(locale.format(',.0f'))
      .html({
        all: '<h2 class="gobierto_observatory-habitants-title">Habitantes</h2><h3 class="gobierto_observatory-habitants-number">%total-count</h3>',
        some: '<h2 class="gobierto_observatory-habitants-title">Total habitantes</h2><h3 class="gobierto_observatory-habitants-number">%filter-count</h3>'
      })

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.updateOriginFilters('all', chart.filters());
      })
    return chart;
  }

  renderBarNationality(selector) {
    const chart = stackedChart(selector, "main");
    const sumAllValues = this.ndx.groups.origin.all.value()
    chart
      .width(250)
      .height(45)
      .group(this.ndx.groups.studies.byNationality)
      .dimension(this.ndx.filters.studies.byNationality)
      .colors('#FF776D')
      .elasticX(true)
      .gap(10)
      .margins(marginHabNat)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .title(d => `${((d.value * 100) / sumAllValues).toFixed(1)}%`)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.updateOriginFilters('byNationality', chart.filters());
        const container = document.getElementById('container-bar-nationality')
        that.activeFiltered(container)
        that.pyramidChart()
      });
    return chart;
  }

  renderBarSex(selector) {
    const chart = stackedChart(selector, "main");
    const sumAllValues = this.ndx.groups.origin.all.value()

    chart
      .width(250)
      .height(45)
      .group(this.ndx.groups.studies.bySex)
      .dimension(this.ndx.filters.studies.bySex)
      .colors('#FF776D')
      .elasticX(true)
      .gap(10)
      .margins(marginHabNat)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-110)
      .titleLabelOffsetX(145)
      .title(d => `${((d.value * 100) / sumAllValues).toFixed(1)}%`)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.updateOriginFilters('bySex', chart.filters());
        const container = document.getElementById('container-bar-sex')
        that.activeFiltered(container)
        that.pyramidChart()
      });

    return chart;
  }

  renderPyramid(selector) {
    const chart = pairedRow(selector, "main");
    dc.chartRegistry.register(chart, 'main');
    const that = this;

    let group = {
      all: function() {
        var age_ranges = ['91-100','81-90','71-80','61-70','51-60','41-50','31-40','21-30','11-20','00-10']

        // convert to object so we can easily tell if a key exists
        var values = {};
        that.ndx.groups.studies.byAge.all().forEach(function(d) {
          values[d.key[0] + '.' + d.key[1]] = d.value;
        });

        // convert back into an array for the chart, making sure that all age_ranges exist
        var g = [];
        age_ranges.forEach(function(age_range) {
          g.push({
            key: ['Hombre', age_range],
            value: values['Hombre.' + age_range] || 0
          });
          g.push({
            key: ['Mujer', age_range],
            value: values['Mujer.' + age_range] || 0
          });
        });

        return g;
      }
    };

    chart.options({
      // display
      width: 250,
      height: 200,
      labelOffsetX: -50,
      fixedBarHeight: 10,
      gap: 10,
      colorCalculator: function(d) {
        if (d.key[0] === 'Male') {
          return '#008E9C';
        }
        return '#F8B206';
      },
      // data
      dimension: this.ndx.filters.studies.byAge,
      group: group,
      // misc
      renderTitleLabel: true,
      title: d => d.key[1],
      label: d => d.key[1],
      cap: 10,
      // if elastic is set than the sub charts will have different extent ranges, which could mean the data is interpreted incorrectly
      elasticX: true,
      // custom
      leftKeyFilter: d => d.key[0] === 'Hombre',
      rightKeyFilter: d => d.key[0] === 'Mujer'
    })

    chart.rightChart().options({ width: 185})


    let allRows = d3.selectAll('g.row')
    allRows
      .attr('opacity', 0)

    chart.render(this.pyramidChart())
    return chart;
  }

  //Create a Pyramid population Chart
  pyramidChart() {
    setTimeout(() => {
      //Only get the rows of the left chart.
      let selectLeftRows = d3.selectAll('.left-chart g.row rect')
      selectLeftRows = selectLeftRows._groups[0]
      const leftChart = d3.select('.left-chart')
      //Get the size of the left chart. 30 isn't a magic number, it is the margin-right of the  chart.
      const widthLeftchart = leftChart._groups[0][0].clientWidth - 30
      selectLeftRows.forEach(rect => {
        //Get the width of the every rect inside a row.
        const rectWidth = rect.width.animVal.value
        //Subtract the width of the chart minus width of the rect, with this now move rect to the right position
        const translateRectToRight = widthLeftchart - rectWidth
        //Hack to create a tricky animation
        //First set a width with zero
        rect.setAttribute('width', 0)
        //Second, use translateRectToRight to move rect
        rect.setAttribute('x', translateRectToRight)
        //Finally, set again the width of the rect, we need a class with CSS animation
        rect.setAttribute('width', rectWidth)
      })
      let allRects = d3.selectAll('g.row')
      allRects.attr('opacity', 1)
      //Hack, force to redrawAll dc-charts when user click on every row
      document.querySelectorAll("g.row").forEach(row => row.addEventListener('click', () => {
        dc.redrawAll('main');
      }));
      const that = this;
      document.querySelectorAll("#container-piramid-age-sex g.row").forEach(row => row.addEventListener('click', () => {
        const container = document.getElementById('container-piramid-age-sex')
        that.activeFiltered(container)
      }));
      //Why???? because the timing of the dc.js animation is equal 1000ms
    }, 1000)
  }

  renderStudies(selector) {
    const chart = new dc.rowChart(selector, "main");
    const sumAllValues = this.ndx.groups.origin.all.value()
    chart
      .width(300)
      .height(210)
      .cap(10) // Show only top 20
      .group(this.ndx.groups.studies.byStudies)
      .dimension(this.ndx.filters.studies.byStudies)
      .colors('#FF776D')
      .elasticX(true)
      .gap(10)
      .margins(marginStudies)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-180)
      .titleLabelOffsetX(125)
      .title(d => `${((d.value * 100) / sumAllValues).toFixed(1)}%`)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.currentFilter = 'studies';
        const container = document.getElementById('container-bar-by-studies')
        that.activeFiltered(container)
        if (chart.filter() !== null) {
          document.getElementById("bar-by-origin-spaniards").style.display = 'none';
          document.getElementById("bar-by-origin-others").style.display = 'none';
        } else {
          document.getElementById("bar-by-origin-spaniards").style.display = 'block';
          document.getElementById("bar-by-origin-others").style.display = 'block';
        }
        that.pyramidChart()
      });
    chart.render()
    return chart;
  }

  renderOriginNational(selector) {
    const chart = new dc.rowChart(selector, "main");
    const sumAllValues = this.ndx.groups.origin.all.value()
    chart
      .width(300)
      .height(180)
      .cap(10) // Show only top 20
      .othersGrouper(null) // Don't show the rest of the 20 in Other class - https://dc-js.github.io/dc.js/docs/html/CapMixin.html
      .group(this.ndx.groups.origin.byOriginNational)
      .dimension(this.ndx.filters.origin.byOriginNational)
      .colors('#FF776D')
      .elasticX(true)
      .gap(10)
      .margins(marginStudies)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-180)
      .titleLabelOffsetX(125)
      .title(d => `${((d.value * 100) / sumAllValues).toFixed(1)}%`)
      .xAxis().ticks(4)

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.currentFilter = 'origin';
        /*const container = document.getElementById('container-bar-origin-spaniards')
        that.activeFiltered(container)*/
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
        that.pyramidChart()
      });
    return chart;
  }

  renderOriginOthers(selector) {
    const chart = new dc.rowChart(selector, "main");
    const sumAllValues = this.ndx.groups.origin.all.value()
    chart
      .width(300)
      .height(210)
      .cap(10) // Show only top 20
      .othersGrouper(null) // Don't show the rest of the 20 in Other clashttps://dc-js.github.io/dc.js/docs/html/CapMixin.htmls
      .group(this.ndx.groups.origin.byOriginOther)
      .dimension(this.ndx.filters.origin.byOriginOther)
      .colors('#FF776D')
      .elasticX(true)
      .gap(10)
      .margins(marginStudies)
      .renderTitleLabel(true)
      .fixedBarHeight(10)
      .labelOffsetX(-180)
      .titleLabelOffsetX(125)
      .title(d => `${((d.value * 100) / sumAllValues).toFixed(1)}%`)
      .xAxis().ticks(4);

    const that = this;
    chart
      .on('filtered', (chart) => {
        that.currentFilter = 'origin';
        /*const container = document.getElementById('container-bar-origin-others')
        that.activeFiltered(container)*/
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
        that.pyramidChart()
      });
    return chart;
  }

  renderChoroplethMap(selector, data) {
    const chart = new dc_leaflet.choroplethChart(selector, "#main");
    const legendMap = new dc_leaflet.legend(selector, "#main").position('topright');
    const mapboxAccessToken = "pk.eyJ1IjoiZmVyYmxhcGUiLCJhIjoiY2pqMzNnZjcxMTY1NjNyczI2ZXQ0dm1rYiJ9.yUynmgYKzaH4ALljowiFHw";

    chart
      .center([40.309, -3.680], 13.45)
      .zoom(13)
      .mapOptions({
        scrollWheelZoom: false,
      })
      .dimension(this.ndx.filters.studies.byCusec)
      .group(this.ndx.groups.studies.byCusec)
      .geojson(data.features)
      .colors(['#b6d8e6','#9ccbdd','#7fbcd3','#5da9c7','#3293b9','#0174a1','#01445f'])
      .colorDomain([
          d3.min(this.ndx.groups.studies.byCusec.all(), dc.pluck('value')),
          d3.max(this.ndx.groups.studies.byCusec.all(), dc.pluck('value'))
      ])
      .colorAccessor(d => d.value)
      .featureKeyAccessor(feature => feature.properties.cusec)
      .legend(legendMap)
      .tiles(function(map) {
        L.tileLayer('https://api.mapbox.com/styles/v1/{username}/{style_id}/tiles/{z}/{x}/{y}?access_token=' + mapboxAccessToken, {
          scrollWheelZoom: false,
          username: "gobierto",
          style_id: "ck18y48jg11ip1cqeu3b9wpar",
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
          tileSize: 512,
          minZoom: 9,
          maxZoom: 16,
          zoomOffset: -1
        }).addTo(map);
      })

    const that = this;
    chart.on('filtered', function() {
      dc.redrawAll('main', that.pyramidChart());
    })
    return chart;
  }

  activeFiltered(container) {
    const {
      id,
      className
    } = container
    const element = document.getElementById(id)
    if (className.includes('active-filtered')) {
      return false
    } else {
      element.classList.toggle('active-filtered')
    }
  }

  clearFilters(event) {
    const target = event.target;
    const parent = target.parentElement;
    const chart = parent.parentElement;
    if (chart.id === 'container-bar-by-studies') {
      const chartFromList = dc.chartRegistry.list('main')[4]
      const activeFilters = chartFromList.filters().length
      for (let index = 0; index < activeFilters; index++) {
        chartFromList.filter(chartFromList.filters()[0])
      }
      chartFromList.redrawGroup();
      setTimeout(() => {
        chart.classList.toggle('active-filtered')
      }, 0)
    } else if (chart.id === 'container-bar-nationality') {
      const chartFromList = dc.chartRegistry.list('main')[1]
      const activeFilters = chartFromList.filters().length
      for (let index = 0; index < activeFilters; index++) {
        chartFromList.filter(chartFromList.filters()[0])
      }
      chartFromList.redrawGroup();
      setTimeout(() => {
        chart.classList.toggle('active-filtered')

      }, 0)
    } else if (chart.id === 'container-bar-sex') {
      const chartFromList = dc.chartRegistry.list('main')[2]
      const activeFilters = chartFromList.filters().length
      for (let index = 0; index < activeFilters; index++) {
        chartFromList.filter(chartFromList.filters()[0])
      }
      chartFromList.redrawGroup();
      setTimeout(() => {
        chart.classList.toggle('active-filtered')
      }, 0)
    } else if (chart.id === 'container-piramid-age-sex') {
      //Piramid Chart is compose by two children rowChart()
      //We need to reset filters from both charts
      const chartFromList = dc.chartRegistry.list('main')[3]
      const chartFromListLeft = chartFromList.leftChart()
      const chartFromListRight = chartFromList.rightChart()
      //Get the filters length
      const activeFilters = chartFromListLeft.filters().length
      const activeFiltersRight = chartFromListRight.filters().length
      //reset every filter
      for (let index = 0; index < activeFilters; index++) {
        chartFromListLeft.filter(chartFromListLeft.filters()[0])
      }
      for (let index = 0; index < activeFiltersRight; index++) {
        chartFromListRight.filter(chartFromListRight.filters()[0])
      }
      //Redraw
      dc.chartRegistry.list('main')[0].redrawGroup()
      setTimeout(() => {
        chart.classList.toggle('active-filtered')
      }, 0)
    }
  }
}



export default getRemoteData

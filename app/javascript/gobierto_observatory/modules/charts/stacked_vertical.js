import { CapMixin, MarginMixin, ColorMixin, transition } from "dc"
import { axisBottom } from "d3-axis";
import { extent } from "d3-array";
import { select } from "d3-selection";
import { scaleLinear } from "d3-scale";

//Extends dc.rowChart to create a rowChartStackedVertical
//Add changes to two functions: updateElements and updateLabels()

export default function (parent, chartGroup) {

    var _g;

    var _labelOffsetX = 10;
    var _labelOffsetY = 15;
    var _hasLabelOffsetY = false;
    var _dyOffset = '0.35em'; // this helps center labels https://github.com/d3/d3-3.x-api-reference/blob/master/SVG-Shapes.md#svg_text
    var _titleLabelOffsetX = 2;

    var _gap = 5;

    var _fixedBarHeight = false;
    var _rowCssClass = 'row';
    var _titleRowCssClass = 'titlerow';
    var _renderTitleLabel = false;

    // https://github.com/dc-js/dc.js/blob/develop/docs/dc-v4-upgrade-guide.md#steps-to-upgrade
    var _chart = new (CapMixin(ColorMixin(MarginMixin)))()

    var _x;

    var _elasticX;

    var _xAxis = axisBottom();

    var _rowData;

    _chart.rowsCap = _chart.cap;

    function calculateAxisScale() {
        if (!_x || _elasticX) {

            var extentValues = extent(_rowData, function() {
                return _chart.cappedValueAccessor
            });

            if (extentValues[0] > 0) {
                extentValues[0] = 0;
            }
            if (extentValues[1] < 0) {
                extentValues[1] = 0;
            }
            _x = scaleLinear().domain(extentValues)
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

        transition(axisG, _chart.transitionDuration(), _chart.transitionDelay())
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

    _chart.label(function (d) {
        return _chart.cappedKeyAccessor(d)
    });

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

        //Every row in the same X/Y coordinate
        var rect = rows.attr('transform', function () {
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

        //Get the width of the SVG
        _g = _chart.svg()
        const widthSvg = _g._groups[0][0].clientWidth
        //Calculate total values
        const totalValues = _rowData[0].value + _rowData[1].value - 6

        transition(rect, _chart.transitionDuration(), _chart.transitionDelay())
            .attr('width', function (d) {
              //Transform values to pixels
              return (((d.value * 100) / totalValues).toFixed(1) * widthSvg) / 100
            })
            .attr('transform', translateX);

        //Move the second rect
        rows.select('.row._1 rect')
          .attr('x', function() {
            return (widthSvg - (((_rowData[1].value * 100) / totalValues).toFixed(1) * widthSvg) / 100) + 1
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

            //Move labels to new positions
            _g = _chart.svg()
            const widthSvg = _g._groups[0][0].clientWidth
            const widthLabelText1 = rows.select('#text-label_1').node().getBoundingClientRect().width;
            const translateLabel1 = widthSvg - widthLabelText1 + 3

            rows.select('.row._1 text._1')
              .attr('x', translateLabel1)
              .attr('y', 20)

            transition(lab, _chart.transitionDuration(), _chart.transitionDelay())
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

            //Move title to new positions
            //Position for title row is equal
            const widthLabelText0 = select('#text-label_0').node().getBoundingClientRect().width;
            const widthLabelTitle0 = rows.select('#titlerow_0').node().getBoundingClientRect().width;

            rows.select('.row._0 .titlerow._0')
              .attr('x', widthLabelTitle0)
              .attr('y', 20)

            rows.select('.row._0 text._0')
              .attr('x', widthLabelText0 + 5)
              .attr('y', 20)

            _g = _chart.svg()
            const widthSvg = _g._groups[0][0].clientWidth
            const widthLabelText1 = rows.select('#text-label_1').node().getBoundingClientRect().width;
            // const widthLabelTitle1 = rows.select('#titlerow_1').node().getBoundingClientRect().width;
            const translateTitleRow1 = widthSvg - widthLabelText1

            rows.select('.row._1 .titlerow._1')
              .attr('x', translateTitleRow1)
              .attr('y', 20)

            transition(titlelab, _chart.transitionDuration(), _chart.transitionDelay())
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

    function onClick (_, d) {
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
}

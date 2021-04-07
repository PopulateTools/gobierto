/**
 * Original code
 * https://github.com/jorgeatgu/dc-addons-paired-row/
 */
import { select, selectAll } from "d3-selection";
import { scaleLinear } from "d3-scale";
import { extent } from "d3-array";
import { transition } from "d3-transition";
import { CapMixin, ColorMixin, MarginMixin, rowChart, events, utils } from "dc";

const d3 = { select, selectAll, scaleLinear, extent, transition }

export default function(parent, chartGroup) {
  // https://github.com/dc-js/dc.js/blob/develop/docs/dc-v4-upgrade-guide.md#steps-to-upgrade
  var _chart = new (CapMixin(ColorMixin(MarginMixin)))()

  var _leftChartWrapper = d3.select(parent).append('div').attr('class', 'left-chart');
  var _rightChartWrapper = d3.select(parent).append('div').attr('class', 'right-chart');

  var _leftChart = rowChart(_leftChartWrapper, chartGroup);
  var _rightChart = rowChart(_rightChartWrapper, chartGroup);

  // data filtering

  // we need a way to know which data belongs on the left chart and which data belongs on the right
  var _leftKeyFilter = function(d) {
    return d.key[0];
  };

  var _rightKeyFilter = function(d) {
    return d.key[0];
  };

  /**
  #### .leftKeyFilter([value]) - **mandatory**
  Set or get the left key filter attribute of a chart.

  For example
  function (d) {
      return d.key[0] === 'Male';
  }

  If a value is given, then it will be used as the new left key filter. If no value is specified then
  the current left key filter will be returned.

  **/
  _chart.leftKeyFilter = function(_) {
    if (!arguments.length) {
      return _leftKeyFilter;
    }

    _leftKeyFilter = _;
    return _chart;
  };

  /**
  #### .rightKeyFilter([value]) - **mandatory**
  Set or get the right key filter attribute of a chart.

  For example
  function (d) {
      return d.key[0] === 'Female';
  }

  If a value is given, then it will be used as the new right key filter. If no value is specified then
  the current right key filter will be returned.

  **/
  _chart.rightKeyFilter = function(_) {
    if (!arguments.length) {
      return _rightKeyFilter;
    }

    _rightKeyFilter = _;
    return _chart;
  };

  // when trying to get the data for the left chart then filter all data using the leftKeyFilter function
  _leftChart.data(function(data) {
    var cap = _leftChart.cap(),
      d = data.all().filter(function(d) {
        return _chart.leftKeyFilter()(d);
      });

    if (cap === Infinity) {
      return d;
    }

    return d.slice(0, cap);
  });

  // when trying to get the data for the right chart then filter all data using the rightKeyFilter function
  _rightChart.data(function(data) {
    var cap = _rightChart.cap(),
      d = data.all().filter(function(d) {
        return _chart.rightKeyFilter()(d);
      });

    if (cap === Infinity) {
      return d;
    }

    return d.slice(0, cap);
  });

  // chart filtering
  // on clicking either chart then filter both

  _leftChart.onClick = _rightChart.onClick = function(d) {
    var filter = _leftChart.keyAccessor()(d);
    events.trigger(function() {
      _leftChart.filter(filter);
      _rightChart.filter(filter);
    });
  };

  // width and margins

  // the margins between the charts need to be set to 0 so that they sit together
  var _margins = _chart.margins(); // get the default margins
  _margins.right = _margins.left;

  _chart.margins = function(_) {
    if (!arguments.length) {
      return _margins;
    }
    _margins = _;

    // set left chart margins
    _leftChart.margins({
      top: _.top,
      right: 0,
      bottom: _.bottom,
      left: _.left,
    });

    // set right chart margins
    _rightChart.margins({
      top: _.top,
      right: _.right,
      bottom: _.bottom,
      left: 60,
    });

    return _chart;
  };

  _chart.margins(_margins); // set the new margins

  // the width needs to be halved
  var _width = 0; // get the default width

  _chart.width = function(_) {
    if (!arguments.length) {
      return _width;
    }
    _width = _;

    // set left chart width
    _leftChart.width(utils.isNumber(_) ? _ / 2 : _);

    // set right chart width
    _rightChart.width(utils.isNumber(_) ? _ / 2 + 60 : _);

    return _chart;
  };

  // the minWidth needs to be halved
  var _minWidth = _chart.minWidth(); // get the default minWidth

  _chart.minWidth = function(_) {
    if (!arguments.length) {
      return _minWidth;
    }
    _minWidth = _;

    // set left chart minWidth
    _leftChart.minWidth(utils.isNumber(_) ? _ / 2 : _);

    // set right chart minWidth
    _rightChart.minWidth(utils.isNumber(_) ? _ / 2 : _);

    return _chart;
  };

  _chart.minWidth(_minWidth); // set the new minWidth

  // svg
  // return an array of both the sub chart svgs

  _chart.svg = function() {
    return d3.selectAll([_leftChart.svg()[0][0], _rightChart.svg()[0][0]]);
  };

  // data - we need to make sure that the extent is the same for both charts

  // this way we need a new function that is overridable
  if (_leftChart.calculateAxisScaleData) {
    _leftChart.calculateAxisScaleData = _rightChart.calculateAxisScaleData = function() {
      return _leftChart.data().concat(_rightChart.data());
    };
    // this way we can use the current dc.js library but we can't use elasticX
  } else {
    _chart.group = function(_) {
      if (!arguments.length) {
        return _leftChart.group();
      }
      _leftChart.group(_);
      _rightChart.group(_);

      // set the new x axis scale
      var extent = d3.extent(_.all(), _chart.cappedValueAccessor);
      if (extent[0] > 0) {
        extent[0] = 0;
      }
      _leftChart.x(d3.scaleLinear().domain(extent).range([_leftChart.effectiveWidth(), 0]));
      _rightChart.x(d3.scaleLinear().domain(extent).range([0, _rightChart.effectiveWidth()]));

      return _chart;
    };
  }

  // get the charts - mainly used for testing
  _chart.leftChart = function() {
    return _leftChart;
  };

  _chart.rightChart = function() {
    return _rightChart;
  };

  // functions that we just want to pass on to both sub charts

  var _getterSetterPassOn = [
    // display
    'height', 'minHeight', 'renderTitleLabel', 'fixedBarHeight', 'gap', 'othersLabel',
    'transitionDuration', 'label', 'renderLabel', 'title', 'renderTitle', 'chartGroup', 'legend',
    //colors
    'colors', 'ordinalColors', 'linearColors', 'colorAccessor', 'colorDomain', 'getColor', 'colorCalculator',
    // x axis
    'x', 'elasticX', 'valueAccessor', 'labelOffsetX', 'titleLabelOffsetx', 'xAxis',
    // y axis
    'keyAccessor', 'labelOffsetY', 'yAxis',
    // data
    'cap', 'ordering', 'dimension', 'group', 'othersGrouper', 'data'
  ];

  function addGetterSetterfunction(functionName) {
    _chart[functionName] = function(_) {
      if (!arguments.length) {
        return [_leftChart[functionName](), _rightChart[functionName]()];
      }
      _leftChart[functionName](_);
      _rightChart[functionName](_);
      return _chart;
    };
  }

  for (var i = 0; i < _getterSetterPassOn.length; i++) {
    addGetterSetterfunction(_getterSetterPassOn[i]);
  }

  var _passOnFunctions = [
    '_doRedraw', 'redraw', '_doRender', 'render', 'calculateColorDomain', 'filterAll', 'resetSvg', 'expireCache'
  ];

  function addPassOnFunctions(functionName) {
    _chart[functionName] = function() {
      _leftChart[functionName]();
      _rightChart[functionName]();
      return _chart;
    };
  }

  for (i = 0; i < _passOnFunctions.length; i++) {
    addPassOnFunctions(_passOnFunctions[i]);
  }


  function pyramidChart() {
    setTimeout(() => {
      const leftChartId = document.querySelector('.left-chart')
      const leftChartClassName = leftChartId.classList.contains('init-left-chart')
      if (!leftChartClassName) {
        const leftChart = d3.select('.left-chart')
        let selectLeftRows = d3.selectAll('.left-chart g.row rect')
        selectLeftRows.style('opacity', '0')
          .attr('x', leftChart._groups[0][0].clientWidth)
        leftChartId.classList.add('init-left-chart')
      }
    }, 150)
    setTimeout(() => {
      let selectLeftRows = d3.selectAll('.left-chart g.row rect')
      selectLeftRows.style('opacity', '1')
      selectLeftRows = selectLeftRows._groups[0]
      const leftChart = d3.select('.left-chart')
      //Get the size of the left chart. 30 isn't a magic number, is the margin right of the chart.
      const widthLeftchart = leftChart._groups[0][0].clientWidth - 30
      selectLeftRows.forEach(rect => {
        //Get the width of the every rect inside a row
        const rectWidth = rect.width.animVal.value
        //Substract width of the chart minus width of the rect, with this now move rect to right position
        const translateRectToRight = widthLeftchart - rectWidth
        //Hack to create a tricky animation
        rect.setAttribute('x', translateRectToRight)
        //Finally, set again the width of the rect, we need a class with CSS animation
        rect.setAttribute('width', rectWidth)
      })
    }, 750)
  }

  _leftChart.on('pretransition', function() {
    pyramidChart()
  });

  const stopTranslateRight = function(element) {
    d3.selectAll(element)
      .attr('transform', 'translate(0,0)')
      .transition()
      .duration(500)
  }

  _rightChart.on('preRedraw', function() {
    stopTranslateRight('.right-chart g.row text.row')
  });

  _rightChart.on('pretransition', function() {
    stopTranslateRight('.right-chart g.row text.row')
  });

  _rightChart.on('preRender', function() {
    stopTranslateRight('.right-chart g.row text.row')
  });

  _chart.pyramidChart = function() {
    pyramidChart()
  };

  return _chart.anchor(parent, chartGroup);
}

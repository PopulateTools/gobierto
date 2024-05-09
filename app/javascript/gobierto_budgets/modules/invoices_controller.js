import crossfilter from 'crossfilter2';
import { axisTop } from 'd3-axis';
import { csv } from 'd3-fetch';
import { scaleBand, scaleOrdinal, scaleThreshold } from 'd3-scale';
import { select } from 'd3-selection';
import { timeMonth } from 'd3-time';
import { timeFormatLocale } from 'd3-time-format';
import { barChart, rowChart, units } from 'dc';
import 'jsgrid';
import moment from 'moment';
import { d3locale } from '../../lib/shared';
import { AmountDistributionBars } from '../../lib/visualizations';

const d3 = {
  select,
  csv,
  scaleThreshold,
  scaleBand,
  axisTop,
  scaleOrdinal,
  timeMonth,
  timeFormatLocale
};
const dc = { barChart, rowChart, units };

window.GobiertoBudgets.InvoicesController = (function() {
  function InvoicesController() {}

  // Global variables
  var data,
    ndx,
    _r,
    _tabledata,
    _empty,
    dataEndpoint,
    _chartdata = {},
    $tableHTML = {};

  InvoicesController.prototype.show = function() {
    $tableHTML = $("#providers-table");

    dataEndpoint = "/presupuestos/proveedores-facturas.csv";

    let municipalityId = window.populateData.municipalityId;
    let maxYearUrl =
      dataEndpoint +
      "?filter_by_location_id=" +
      municipalityId +
      "&sort_desc_by=date&limit=1";
    let minYearUrl =
      dataEndpoint +
      "?filter_by_location_id=" +
      municipalityId +
      "&sort_asc_by=date&limit=1";

    // Get the dates
    const getYear = function(url) {
      return new Promise(resolve => {
        d3.csv(url, {
          headers: new Headers({
            authorization: "Bearer " + window.populateData.token
          })
        }).then(csv => resolve(moment(_.map(csv, "date")[0]).year()));
      });
    };

    // Insert the buttons to the DOM
    Promise.all([getYear(minYearUrl), getYear(maxYearUrl)]).then(range => {
      const $dropdownContent = $("[data-dropdown]:not(.js-dropdown)");
      for (var i = range[0]; i <= range[1]; i++) {
        $(
          '<button class="button-grouped button-compact sort-G" data-toggle="' +
            i +
            '">' +
            i +
            "</button>"
        )
          .appendTo($dropdownContent)
          .bind("click", btnOnClickExtended);
      }
    });

    // Click event handler
    let btnOnClick = function(e) {
      var filter = $(e.target).attr("data-toggle");

      // Reset all buttons
      $(".sort-G").removeClass("active");
      $('.sort-G[data-toggle="' + filter + '"]').addClass("active");

      // Reset dropdown
      const $dropdownText = $("[data-dropdown].js-dropdown");
      let tpl = `${I18n.t(
        "gobierto_budgets.providers.index.previous"
      )}&nbsp;<small>&#9660;</small>`;
      $dropdownText.html(tpl);

      // Hide dropdown always
      const $dropdownContent = $("[data-dropdown]:not(.js-dropdown)");
      $dropdownContent.addClass("hidden");

      // Hide table to show spinner
      $tableHTML.addClass("hidden");

      $("html, body").animate(
        {
          scrollTop: $("#invoices-filters").offset().top
        },
        500
      );

      getData(filter);
    };

    // Extend btnOnClick functionality just for dynamic content (Promise)
    // In order to avoid mix logic with old features, since jQuery appendTo method must bind the event itself
    let btnOnClickExtended = function(e) {
      // Call original function
      btnOnClick.call(this, e);

      // Run concrete stuff
      const $dropdownText = $("[data-dropdown].js-dropdown");
      let tpl = `${$(e.target).attr(
        "data-toggle"
      )}&nbsp;<small>&#9660;</small>`;
      $dropdownText.html(tpl);
    };

    $("#invoices-filters .sort-G").on("click", btnOnClick);

    getData("3m");
  };

  function getData(filter) {
    var dateRange;

    if (filter === "3m") {
      dateRange =
        moment()
          .subtract(3, "month")
          .format("YYYYMMDD") +
        "-" +
        moment().format("YYYYMMDD");
    } else if (filter === "12m") {
      dateRange =
        moment()
          .subtract(1, "year")
          .format("YYYYMMDD") +
        "-" +
        moment().format("YYYYMMDD");
    } else {
      var d1 = new Date(filter, 0, 1);
      var d2 = new Date(filter, 11, 31);
      dateRange =
        moment(d1).format("YYYYMMDD") + "-" + moment(d2).format("YYYYMMDD");
    }

    var municipalityId = window.populateData.municipalityId;
    var url =
      dataEndpoint +
      "?filter_by_location_id=" +
      municipalityId +
      "&date_date_range=" +
      dateRange +
      "&sort_asc_by=date&except_columns=_id,invoice_id,payment_date,location_id,province_id,autonomous_region_id";

    // Show spinner
    $(".js-toggle-overlay").addClass("is-active");

    d3.csv(url, {
      headers: new Headers({
        authorization: "Bearer " + window.populateData.token
      })
    }).then(csv => {
      // Hide spinner
      $(".js-toggle-overlay").removeClass("is-active");
      // Show table again
      $tableHTML.removeClass("hidden");

      data = _.filter(csv, _callback(filter));

      // enable empty filter
      $("#invoices-filters button[data-toggle=" + filter + "]").prop(
        "disabled",
        false
      );

      if (!data.length) {
        // disable empty filter
        $("#invoices-filters button[data-toggle=" + filter + "]").prop(
          "disabled",
          true
        );

        // if there's no data, get all available filters and trigger a new one
        let filters = [];
        $("#invoices-filters button[data-toggle]").each(function() {
          filters.push($(this).attr("data-toggle"));
        });
        let previousFilter =
          filters.indexOf(filter) > 0
            ? filters[filters.indexOf(filter) - 1]
            : alert(I18n.t("gobierto_budgets.invoices.show.empty"));

        // trigger another filter automatically
        $(
          "#invoices-filters button[data-toggle=" + previousFilter + "]"
        ).trigger("click");
        return;
      }

      _r = {
        domain: [501, 1001, 5001, 10001, 15001],
        range: [0, 1, 2, 3, 4, 5]
      };
      var rangeFormat = d3
        .scaleThreshold()
        .domain(_r.domain)
        .range(_r.range);
      var intl = new Intl.DateTimeFormat(I18n.locale); // Improve performance

      // pre-calculate for better performance
      for (var i = 0, l = data.length; i < l; i++) {
        var d = data[i];

        d.dd = new Date(d.date);
        d.datel10n = intl.format(d.dd);
        d.month = moment(d.dd).endOf("month")._d;
        d.range = rangeFormat(+d.value);
        d.paid = d.paid == "true";
        d.value = Number(d.value);
        d.freelance = d.freelance == "true";
        // optionals
        d.payment_date = !!d.payment_date && intl.format(new Date(d.payment_date))
        d.payment_date_limit = !!d.payment_date_limit && intl.format(new Date(d.payment_date_limit))
      }

      // See the [crossfilter API](https://github.com/square/crossfilter/wiki/API-Reference) for reference.
      ndx = crossfilter(data);

      _boxesCalculations();

      // BARS CHART - BY DATE
      _renderByMonthsChart();

      // ROW CHART - MAIN PROVIDERS
      _renderMainProvidersChart();

      // ROW CHART - BY AMOUNT
      _renderByAmountsChart();

      // TABLE FILTER - FULL PROVIDERS
      _renderTableFilter(data);
    });
  }

  function _callback(f) {
    var cb = function() {};

    // Return the filter callback function based on filter selected
    switch (f) {
      case "3m":
        cb = function(o) {
          return moment(new Date(o.date)) > moment().subtract(3, "months");
        };
        break;
      case "12m":
        cb = function(o) {
          return moment(new Date(o.date)) > moment().subtract(12, "months");
        };
        break;
      default:
        // Filter is the year itself
        cb = function(o) {
          return moment(new Date(o.date)).year() === Number(f);
        };
    }

    return cb;
  }

  // Spread data object updates
  function _refreshFromCharts(_data) {
    _boxesCalculations(_data);

    // If the data filtered is the same as the data total, tabledata = undefined
    _tabledata = _.isEqual(data, _data) ? undefined : _data;
    $tableHTML.jsGrid("search");
  }

  function _refreshFromTable(_data) {
    _boxesCalculations(_data);

    ndx = crossfilter(_data);
    _renderByMonthsChart();
    _renderMainProvidersChart();
    _renderByAmountsChart();
  }

  function _boxesCalculations(reduced) {
    var _data = reduced || data;

    // Totals box
    var totalAmount = _.sumBy(_data, "value");

    document.getElementById(
      "numberOfInvoices"
    ).innerText = _data.length.toLocaleString();
    document.getElementById("totalAmount").innerText = totalAmount.toLocaleString(I18n.locale, {
      style: "currency",
      currency: "EUR",
      maximumFractionDigits: 0
    });

    var providers = _.uniqBy(_data, "provider_name");
    var numberFreelancers = providers.filter(p => p.freelance).length || 0;
    var numberCorporationsSA =
      providers.filter(
        p => !p.freelance && p.provider_id.substring(0, 1) === "A"
      ).length || 0;
    var numberCorporationsSL =
      providers.length - numberFreelancers - numberCorporationsSA;

    $("#providerType .number:eq(0)").text(
      numberCorporationsSA.toLocaleString()
    );
    $("#providerType .number:eq(1)").text(
      numberCorporationsSL.toLocaleString()
    );
    $("#providerType .number:last").text(numberFreelancers.toLocaleString());

    var invoicesFreelancers = _data.filter(d => d.freelance).length || 0;
    var invoicesCorporationsSA =
      _data.filter(d => !d.freelance && d.provider_id.substring(0, 1) === "A")
        .length || 0;
    var invoicesCorporationsSL =
      _data.length - invoicesFreelancers - invoicesCorporationsSA;

    $("#providerType .percent:eq(0)").text(
      (invoicesCorporationsSA / _data.length || 0).toLocaleString(I18n.locale, {
        style: "percent"
      })
    );
    $("#providerType .percent:eq(1)").text(
      (invoicesCorporationsSL / _data.length || 0).toLocaleString(I18n.locale, {
        style: "percent"
      })
    );
    $("#providerType .percent:last").text(
      (invoicesFreelancers / _data.length || 0).toLocaleString(I18n.locale, {
        style: "percent"
      })
    );

    // Math results box
    function median(values) {
      var half = Math.floor(values.length / 2);

      if (values.length % 2) return values[half];
      else return (values[half - 1] + values[half]) / 2.0;
    }

    var amount = _.isEmpty(_.map(_data, "value").map(Number))
      ? [0]
      : _.map(_data, "value").map(Number);
    amount.sort((b, a) => a - b);

    document.getElementById("meanBudget").innerText = _.mean(
      amount
    ).toLocaleString(I18n.locale, {
      style: "currency",
      currency: "EUR"
    });
    document.getElementById("medianBudget").innerText = median(
      amount
    ).toLocaleString(I18n.locale, {
      style: "currency",
      currency: "EUR"
    });

    // Text info calculations
    function percentileAgg(arr, p) {
      if (arr.length === 0) return 0;

      var percentile = _.sum(arr) * p;
      var accumulate = 0;
      var i = 0;

      while (accumulate < percentile) {
        accumulate += +arr[i];
        i++;
      }

      return i / arr.length || 0;
    }

    var lt1000 = _.filter(amount, o => o <= 1000).length / _data.length || 0; // Filter those amounts less than 1000
    var lgProvider =
      _.max(
        _.map(_.groupBy(_data, "provider_name"), group =>
          _.sumBy(group, "value")
        )
      ) / totalAmount || 0; // Max amount group by provider amount

    document.getElementById("lessThan1000").innerText = lt1000.toLocaleString(
      I18n.locale,
      {
        style: "percent"
      }
    );
    document.getElementById(
      "largestProvider"
    ).innerText = lgProvider.toLocaleString(I18n.locale, {
      style: "percent"
    });
    document.getElementById("percentile50").innerText = percentileAgg(
      amount,
      0.5
    ).toLocaleString(I18n.locale, {
      style: "percent",
      minimumFractionDigits: 2
    });
    document.getElementById("percentile10").innerText = percentileAgg(
      amount,
      0.1
    ).toLocaleString(I18n.locale, {
      style: "percent",
      minimumFractionDigits: 2
    });
  }

  function _renderByMonthsChart() {
    // Declaration
    var bars = dc.barChart("#bars", "group");

    // Dimensions
    var months = ndx.dimension(d => d.month),
      budgetMonthly = months.group().reduceSum(d => +d.value);

    const node = bars.root().node() || document.createElement("div");

    bars
      .width((node.parentNode || node).getBoundingClientRect().width) // webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .dimension(months)
      .group(budgetMonthly)
      .x(d3.scaleBand())
      .xUnits(dc.units.ordinal)
      .round(d3.timeMonth.round)
      .elasticX(true)
      .elasticY(true)
      .alwaysUseRounding(true)
      .renderHorizontalGridLines(true)
      .barPadding(0.45)
      .title(d => _abbrevLargeCurrency(d.value, { minimumFractionDigits: 0 }))
      .on("pretransition", function(chart) {
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart
          .selectAll("rect")
          .attr("rx", 4)
          .attr("ry", 4);
      })
      .on("filtered", function(chart) {
        _chartdata[chart.anchorName()] = chart.filters();
        _refreshFromCharts(months.top(Infinity));
      });

    // Customize
    bars.xAxis().tickFormat(d => {
      let _mf = d3.timeFormatLocale(d3locale[I18n.locale]).format("%b");
      return _mf(d).toUpperCase();
    });
    bars.yAxis().ticks(5);
    bars.yAxis().tickFormat(v =>
      _abbrevLargeCurrency(v, {
        minimumFractionDigits: 0
      })
    );
    bars.margins().left = 80;
    bars.margins().right = 0;

    // Render
    bars.render();
  }

  function _renderMainProvidersChart() {
    // Declaration
    var hbars1 = dc.rowChart("#hbars1", "group");

    // Dimensions
    var providers = ndx.dimension(d => d.provider_name),
      providerByAmount = providers.group().reduceSum(d => +d.value);

    // Styling
    var _count = 10,
      _gap = 10,
      _barHeight = 15,
      _labelOffset = 195;

    const node = hbars1.root().node() || document.createElement("div");

    hbars1
      .width((node.parentNode || node).getBoundingClientRect().width) // webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .height(
        hbars1.margins().top +
          hbars1.margins().bottom +
          _count * _barHeight +
          (_count + 1) * _gap
      ) // Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .cap(_count)
      .othersGrouper(null) // Show only a couple of results, and hide Others groups
      .x(d3.scaleOrdinal())
      .dimension(providers)
      .group(providerByAmount)
      .gap(_gap)
      .labelOffsetX(-_labelOffset)
      .label(d => (d.key.length > 24 ? d.key.slice(0, 24) + "..." : d.key))
      .title(
        d =>
          d.key +
          " - " +
          _abbrevLargeCurrency(d.value, { minimumFractionDigits: 0 })
      )
      .elasticX(true)
      .on("pretransition", function(chart) {
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart
          .selectAll("rect")
          .attr("rx", 4)
          .attr("ry", 4);

        chart
          .select("g.axis")
          .attr("transform", "translate(0,0)")
          .append("text")
          .text(I18n.t("gobierto_budgets.invoices.show.invoiced"))
          // .attr("x", -9 * 3)
          .attr("x", -_labelOffset)
          .attr("y", -9) // Default
          .attr("class", "axis-title")
          .attr("text-anchor", "start");

        chart.selectAll("g.axis line.grid-line").attr("y2", function() {
          return (
            Math.abs(+d3.select(this).attr("y2")) + chart.margins().top / 2
          );
        });

        $("#providers-number").html(providers.group().all().length - _count);
      })
      .on("filtered", function() {
        _refreshFromCharts(providers.top(Infinity));
      });

    // Customize
    hbars1.xAxis().tickFormat(v =>
      _abbrevLargeCurrency(v, {
        minimumFractionDigits: 0
      })
    );
    hbars1.xAxis(d3.axisTop().ticks(3));
    hbars1.margins().top = 20;
    hbars1.margins().left = _labelOffset + 5;
    hbars1.margins().right = 10;

    // Render
    hbars1.render();
  }

  function _renderByAmountsChart() {
    const amounts = ndx.dimension(contract => contract.range);

    const renderOptions = {
      containerSelector: "#hbars2",
      dimension: amounts,
      range: _r,
      labelMore: I18n.t("gobierto_budgets.invoices.show.more"),
      labelFromTo: I18n.t("gobierto_budgets.invoices.show.fromto"),
      onFilteredFunction: () => _refreshFromCharts(amounts.top(Infinity))
    };

    new AmountDistributionBars(renderOptions);
  }

  function _renderTableFilter(data) {
    var resetFilters = false;

    // Optional fields: if any value exist, returns false
    const payment_date = data.some(x => !!x.payment_date)
    const payment_date_limit = data.some(x => !!x.payment_date_limit)

    $tableHTML.jsGrid({
      width: "100%",
      height: "auto",
      filtering: true,
      sorting: true,
      autoload: true,
      paging: true,
      pageSize: 50,
      pagerFormat: I18n.t("gobierto_budgets.invoices.show.table.pager.format", {
        tpl: "{first} {prev} {pages} {next} {last} &nbsp;&nbsp; {pageIndex}",
        tpl2: "{pageCount}"
      }),
      pageNextText: I18n.t("gobierto_budgets.invoices.show.table.pager.next"),
      pagePrevText: I18n.t("gobierto_budgets.invoices.show.table.pager.prev"),
      pageFirstText: I18n.t("gobierto_budgets.invoices.show.table.pager.first"),
      pageLastText: I18n.t("gobierto_budgets.invoices.show.table.pager.last"),
      controller: {
        loadData: function(filter) {
          return $.grep(_tabledata || data, function(row) {
            return (
              (!filter.provider_name.toLowerCase() ||
                row.provider_name
                  .toLowerCase()
                  .indexOf(filter.provider_name.toLowerCase()) > -1) &&
              (!filter.provider_id.toLowerCase() ||
                row.provider_id
                  .toLowerCase()
                  .indexOf(filter.provider_id.toLowerCase()) > -1) &&
              (!filter.date || row.datel10n.indexOf(filter.date) > -1) &&
              (filter.paid === undefined || row.paid === filter.paid) &&
              (!filter.value || row.value === filter.value) &&
              (!filter.subject.toLowerCase() ||
                row.subject
                  .toLowerCase()
                  .indexOf(filter.subject.toLowerCase()) > -1)
            );
          });
        }.bind(this)
      },
      onDataLoading: function(f) {
        // Initialize table filter
        if (_empty === undefined) {
          _empty = f.filter;
          return;
        }
      }.bind(this),
      onDataLoaded: function(f) {
        if (_tabledata !== undefined) {
          if (f.data.length !== _tabledata.length) {
            _refreshFromTable(f.data);
          } else if (resetFilters) {
            // reset defaults
            resetFilters = false;
            _tabledata = undefined;

            $tableHTML.jsGrid("search");
            _refreshFromTable(data);
          }
        }
      }.bind(this),
      fields: [
        {
          name: "provider_id",
          title: I18n.t(
            "gobierto_budgets.invoices.show.table.fields.provider_id"
          ),
          type: "text",
          autosearch: true,
          align: "center",
          css: "break",
          width: 30,
          itemTemplate: value => value.substring(0, 16)
        },
        {
          name: "provider_name",
          title: I18n.t(
            "gobierto_budgets.invoices.show.table.fields.provider_name"
          ),
          type: "text",
          autosearch: true,
          width: 50
        },
        {
          name: "date",
          title: I18n.t("gobierto_budgets.invoices.show.table.fields.date"),
          type: "text",
          align: "center",
          width: 30,
          itemTemplate: function(value) {
            return new Date(value).toLocaleDateString(I18n.locale);
          }
        },
        {
          name: "paid",
          title: I18n.t("gobierto_budgets.invoices.show.table.fields.paid"),
          type: "checkbox",
          align: "center",
          width: 20,
          visible: false
        },
        {
          name: "value",
          title: I18n.t("gobierto_budgets.invoices.show.table.fields.value"),
          type: "number",
          width: 20,
          itemTemplate: function(value) {
            return value.toLocaleString(I18n.locale, {
              style: "currency",
              currency: "EUR",
              minimumFractionDigits: 0
            });
          }
        },
        {
          name: "subject",
          title: I18n.t("gobierto_budgets.invoices.show.table.fields.subject"),
          type: "text",
          autosearch: true
        },
        // optional
        ...[payment_date && {
          name: "payment_date",
          title: I18n.t("gobierto_budgets.invoices.show.table.fields.payment_date"),
          type: "date",
          autosearch: true,
          align: "center",
          width: 30,
          itemTemplate: function(value) {
            console.log(value, new Date(value).toLocaleDateString(I18n.locale));
            return new Date(value).toLocaleDateString(I18n.locale);
          }
        }],
        // optional
        ...[payment_date_limit && {
          name: "payment_date_limit",
          title: I18n.t("gobierto_budgets.invoices.show.table.fields.payment_date_limit"),
          type: "date",
          autosearch: true,
          align: "center",
          width: 30,
          itemTemplate: function(value) {
            return new Date(value).toLocaleDateString(I18n.locale);
          }
        }]
      ]
    });

    $(".jsgrid-filter-row input").on(
      "input",
      function() {
        resetFilters = _.isEqual(_empty, $tableHTML.jsGrid("getFilter"));
      }.bind(this)
    );
  }

  function _abbrevLargeCurrency(num, props = {}, currency = "EUR") {
    var _obj = {
      style: "currency",
      currency: currency
    };

    return num > 1000000
      ? num
          .toLocaleString(
            I18n.locale,
            _.extend(_obj, {
              maximumSignificantDigits: 3 //Math.log10(pow) / 2 + 1
            })
          )
          .split("")
          .reverse()
          .join("")
          .replace(/000000(.|,)/, "M")
          .split("")
          .reverse()
          .join("")
      : num.toLocaleString(I18n.locale, _.extend(_obj, props));
  }

  return InvoicesController;
})();

window.GobiertoBudgets.invoices_controller = new GobiertoBudgets.InvoicesController();

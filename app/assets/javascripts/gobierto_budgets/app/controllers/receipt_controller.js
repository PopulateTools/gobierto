this.GobiertoBudgets.ReceiptController = (function() {

  function ReceiptController() {}

  ReceiptController.prototype.show = function(options){
    _receiptCalculator(options);
    _budgetLinesMenu();
  };

  function _budgetLinesMenu() {
    $('.bill_row').on('click', function() {
      $(this)
      .toggleClass('toggled')
      .find('.fa').toggleClass('fa-plus fa-minus')
      .parent().siblings('.children').toggleClass('hidden');
    }).find('.children').click(function(e) {
      return false;
    });
  }

  function _receiptCalculator(options) {

    var app = new Vue({
      el: '#taxes_receipt',
      name: 'taxes-receipt',
      data: function() {
        return {
          locale: I18n.locale,
          data: options.receiptConfiguration.budgets_simulation_sections || [],
          selected: [],
          categories: []
        }
      },
      created: function () {
        this.selected = Array(this.data.length).fill(0); // Assign BEFORE compile the template to avoid render twice
        this.categories = _.keys(this.data[0].options[0].value).sort(); // Shortcut for columns
      },
      filters: {
        format: function (m) {
          return accounting.formatMoney(m, "€", 2, ".", ",").replace(/,0+ €$/, ' €')
        },
        percent: function (value) {
          if (!value) return

          return value.toLocaleString(undefined, {
            style: 'percent'
          })
        }
      },
      methods: {
        total: function(o) {
          return _.sumBy(this.selected, this.categories[o]);
        },
        localizedName: function(attr) {
          return attr['name_' + this.locale] || attr['name'];
        },
        ratio: function(percentage) {
          return this.total * (percentage/100.0);
        },
        formatMoney: function(m) {
          return accounting.formatMoney(m, "€", 2, ".", ",").replace(/,0+ €$/, ' €')
        },
        getValue: function (obj, o) {
          if (!obj) return

          var _key = this.categories[o];

          return obj[_key]
        },
        getYear: function (o) {
          return this.categories[o] || o
        },
        getDiff: function (obj, p) {
          if (!obj) return

          var self = parseFloat(obj[this.categories[p]]);
          var prev = parseFloat(obj[this.categories[p - 1]]);
          var diff = self - prev;

          return diff / self
        }
      }
    });
  }

  return ReceiptController;
})();

this.GobiertoBudgets.receipt_controller = new GobiertoBudgets.ReceiptController;

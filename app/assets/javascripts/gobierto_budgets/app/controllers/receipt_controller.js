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
          selected: []
        }
      },
      mounted: function() {
        this.selected = Array(this.data.length).fill(0);
      },
      computed: {
        total: function() {
          return _.sum(this.selected);
        }
      },
      methods: {
        localizedName: function(attr) {
          return attr['name_' + this.locale] || attr['name'];
        },
        ratio: function(percentage) {
          return this.total * (percentage/100.0);
        },
        formatMoney: function(m) {
          return accounting.formatMoney(m, "€", 2, ".", ",").replace(/,0+ €$/, ' €')
        }
      }
    });
  }

  return ReceiptController;
})();

this.GobiertoBudgets.receipt_controller = new GobiertoBudgets.ReceiptController;

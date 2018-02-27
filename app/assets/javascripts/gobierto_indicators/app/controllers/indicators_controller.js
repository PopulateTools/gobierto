this.GobiertoIndicators.IndicatorsController = (function() {

    function IndicatorsController() {}

    IndicatorsController.prototype.show = function() {
      _loadIndicator();
    };

    function _loadIndicator() {

      // define the item component
      Vue.component('item-tree', {
        template: '#item-tree-template',
        props: ['model'],
        data: function() {
          return {
            open: true,
            type: this.$root.type,
            year: this.$root.year
          }
        },
        computed: {
          hasChildren: function() {
            return this.model.children &&
              this.model.children.length
          },
          value: function (i) {
            var p = 0;
            p = (_.find(i.model.attributes.values, function (o) {
              return o[this.year]
            }.bind(this)) || {})[this.year] || 0
            return parseValue(p);
          }
        },
        methods: {
          toggle: function() {
            if (this.hasChildren) {
              this.open = !this.open
            }
          },
          viewDetail: function() {
            var ancestors = [];
            var parent = this.$parent;
            // get all my parents models
            while (parent.model !== undefined) {
              ancestors.push(parent.model);
              parent = parent.$parent;
            }
            this.$root.selected = _.extend(this.model, { ancestors: ancestors.reverse() });
          },
          getLevelClass: function(lvl) {
            return "item-lvl-" + lvl
          }
        }
      });

      // define the item view component
      Vue.component('item-view', {
        template: '#item-view-template',
        props: ['model'],
        data: function() {
          return {
            type: this.$root.type,
            year: this.$root.year
          }
        },
        computed: {
          value: function (i) {
            var p = 0;
            p = (_.find(i.model.attributes.values, function (o) {
              return o[this.year]
            }.bind(this)) || {})[this.year] || 0
            return parseValue(p);
          }
        },
        methods: {
          getLevelClass: function(lvl) {
            return "item-lvl-" + lvl
          }
        }
      });

      // define the item view wrap component
      Vue.component('item-view-wrap', {
        template: '#item-view-wrap-template',
        props: ['model'],
        data: function() {
          return {}
        },
        computed: {
          title: function() {
            var title = this.model.ancestors[0].attributes.title || '';
            if (this.model.ancestors.length > 0) this.model.ancestors.shift();
            return title;
          },
          hasAncestors: function() {
            return this.model.ancestors &&
              this.model.ancestors.length
          }
        },
        methods: {
          unselect: function() {
            return this.$root.selected = null;
          }
        }
      });

      // Helper to format values
      function parseValue(val) {
        if (_.isNumber(parseFloat(val)) && val.toString().indexOf("%") !== -1) {
          // percent
          val = (parseFloat(val) / 100).toLocaleString(I18n.locale, { style: "percent", minimumFractionDigits: 2, maximumFractionDigits: 2 });
        } else if (_.isNumber(parseFloat(val)) && val.toString().indexOf("€")!== -1) {
          // currency
          val = parseFloat(val).toLocaleString(I18n.locale, { style: "currency", currency: "EUR", minimumFractionDigits: 2, maximumFractionDigits: 2 });
        } else if (!_.isNaN(parseFloat(val))) {
          // float
          val = parseFloat(val).toLocaleString();
        } else {
          // string
          val = val.toLocaleString();
        }
        return val
      }

      var element = document.getElementById("indicator-form");
      var year = parseInt(document.getElementById("indicators-tree").dataset.year);

      var app = new Vue({
        el: '.indicators-tree',
        name: 'indicators-tree',
        data: function() {
          return {
            json: {},
            selected: null,
            type: element.dataset.type,
            year: year
          }
        },
        created: function() {
          this.getJson();
        },
        methods: {
          getJson: function() {
            $.getJSON(window.location.href, function(json) {
                this.json = JSON.parse(json["indicator"]);
              }.bind(this));
            }
        }
      });
    };

    return IndicatorsController;
  })();

  this.GobiertoIndicators.indicators_controller = new GobiertoIndicators.IndicatorsController;

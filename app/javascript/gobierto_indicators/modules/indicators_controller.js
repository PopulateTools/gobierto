import Vue from 'vue'
import { find, extend, map, isNumber, isNaN, isArray } from 'lodash';

Vue.config.productionTip = false

window.GobiertoIndicators.IndicatorsController = (function() {

    function IndicatorsController() {}

    IndicatorsController.prototype.show = function() {
      _loadIndicator();
    };

    function _loadIndicator() {

      // define the item component
      Vue.component('item-tree', {
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
            p = (find(i.model.attributes.values, function (o) {
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
            if (!this.hasChildren) {
              var ancestors = [];
              var parent = this.$parent;
              // get all my parents models
              while (parent.model !== undefined) {
                ancestors.push(parent.model);
                parent = parent.$parent;
              }
              this.$root.selected = extend(this.model, { ancestors: ancestors.reverse() });
            }
          },
          getLevelClass: function(lvl) {
            return "item-lvl-" + lvl
          }
        },
        template: '#item-tree-template'
      });

      // define the item view component
      Vue.component('item-view', {
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
            p = (find(i.model.attributes.values, function (o) {
              return o[this.year]
            }.bind(this)) || {})[this.year] || 0
            return parseValue(p);
          }
        },
        created: function () {
          var hash = window.location.hash;
          var _model = this.model.id;
          var hasValue = (hash.indexOf('v') !== -1);

          // Set the hash if not exists
          if (!hasValue) {
            window.location.hash += "&v=" + _model;
          } else {
            // Or updates it
            window.location.hash = hash.replace(hash.split('&')[1], "v=" + _model)
          }
        },
        mounted: function () {
          $('#indicators-tree').velocity('scroll', {
            duration: 500,
            offset: -40,
            easing: 'ease-in-out'
          });
        },
        methods: {
          getLevelClass: function(lvl) {
            return "item-lvl-" + lvl
          }
        },
        template: '#item-view-template'
      });

      // define the item view wrap component
      Vue.component('item-view-wrap', {
        props: ['model'],
        data: function() {
          return {}
        },
        computed: {
          title: function() {
            var title = this.model.ancestors[0].attributes.title || '';
            if (this.model.ancestors.length > 0) this.model.ancestors.slice(0).shift();
            return title;
          },
          hasAncestors: function() {
            return this.model.ancestors &&
              this.model.ancestors.length
          }
        },
        created: function () {
          // Creates a hash
          var _ancestors = this.model.ancestors;
          var group = map(_ancestors, 'id').toString();
          if (!window.location.hash.includes("a=")) {
            window.location.hash += "a=" + group
          }
        },
        methods: {
          unselect: function() {
            window.location.hash = "";
            return this.$root.selected = null;
          }
        },
        template: '#item-view-wrap-template'
      });

      // Helper to format values
      function parseValue(val) {
        if (isNumber(parseFloat(val)) && val.toString().indexOf("%") !== -1) {
          // percent
          val = (parseFloat(val) / 100).toLocaleString(I18n.locale, { style: "percent", minimumFractionDigits: 2, maximumFractionDigits: 2 });
        } else if (isNumber(parseFloat(val)) && val.toString().indexOf("€")!== -1) {
          // currency
          val = parseFloat(val).toLocaleString(I18n.locale, { style: "currency", currency: "EUR", minimumFractionDigits: 2, maximumFractionDigits: 2 });
        } else if (!isNaN(parseFloat(val))) {
          // float
          val = parseFloat(val).toLocaleString();
        } else {
          // string
          val = val.toLocaleString();
        }
        return val
      }

      // Recursive find in tree
      function findById(id, items) {
        var i = 0,
          found, result = [];

        for (; i < items.length; i++) {
          if (items[i].id === id) {
            result.push(items[i]);
          } else if (isArray(items[i].children)) {
            found = findById(id, items[i].children);
            if (found.length) {
              result = result.concat(found);
            }
          }
        }

        return result;
      }

      var element = document.getElementById("indicator-form");
      var year = parseInt(document.getElementById("indicators-tree").dataset.year);

      new Vue({
        el: '#indicators-tree',
        name: 'IndicatorsTree',
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

                // Apply hash if exits
                if (window.location.hash !== "") {
                  // Strip '#' char
                  var hash = window.location.hash.substr(1);
                  // ancestors ids
                  var _a = hash.split('&')[0].split('=')[1].split(',').map(function(x) { return parseInt(x) });
                  // view id
                  var _v = parseInt(hash.split('&')[1].split('=')[1]);
                  // find the id in the tree
                  var model = findById(parseInt(_v), this.json)[0];

                  // Get the ancestors models from the refs
                  var vm = this;
                  this.$nextTick(function () {
                    var ancestors = [vm.$refs.inode[_a[0]].model, vm.$refs.inode[_a[0]].$refs.inode[_a[1]].model]
                    this.selected = extend(model, { ancestors: ancestors });
                  })
                }
              }.bind(this));
            }
        }
      });
    }

    return IndicatorsController;
  })();

  window.GobiertoIndicators.indicators_controller = new GobiertoIndicators.IndicatorsController;

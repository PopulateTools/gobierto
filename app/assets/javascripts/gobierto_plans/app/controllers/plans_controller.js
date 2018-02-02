this.GobiertoPlans.PlansController = (function() {

    function PlansController() {}

    PlansController.prototype.show = function() {
      _loadPlan();
    };

    function _loadPlan() {

      // filters
      Vue.filter('translate', function (key) {
        return key[I18n.locale] || key["es"] || key["en"] || Object.values(key)[0] // fallback translations
      });

      Vue.filter('percent', function (value) {
        return (value / 100).toLocaleString(I18n.locale, { style: 'percent', maximumSignificantDigits: 4 })
      });

      Vue.filter('date', function (date) {
        return new Date(date).toLocaleString(I18n.locale, { year: 'numeric', month: 'short', day: 'numeric' })
      });

      // define the node root component
      Vue.component('node-root', {
        template: '#node-root-template',
        props: ['model'],
        data: function() {
          return {}
        },
        methods: {
          open: function() {
            // { ...this.model } conversion to ES2015
            var _extends = Object.assign || function(target) {
              for (var i = 1; i < arguments.length; i++) {
                var source = arguments[i];
                for (var key in source) {
                  if (Object.prototype.hasOwnProperty.call(source, key)) {
                    target[key] = source[key];
                  }
                }
              }
              return target;
            };

            var model = _extends({}, this.model);

            // Trigger event
            this.$emit('selection', model);

            // REVIEW: Revisar este bloque
            $('section.level_0 .js-img').velocity({flex: "0"});
            $('section.level_0 .js-info').velocity({padding: "1.5em"});
            $('section.level_0 .js-info h3, section.level_1 .js-info span').velocity({"font-size": "1.25rem" });

            $('section.level_0').velocity({flex: "0 0 25%"});
            $('section.level_1').velocity("transition.slideRightBigIn");
            $('section.level_1').css("display: flex");

          }
        }
      });

      // define the node list component
      Vue.component('node-list', {
        template: '#node-list-template',
        props: ['model'],
        data: function() {
          return {
            isOpen: false
          }
        },
        methods: {
          setActive: function() {
            var l = this.model.level;

            if (l === 1) {
              // { ...this.model } conversion to ES2015
              var _extends = Object.assign || function(target) {
                for (var i = 1; i < arguments.length; i++) {
                  var source = arguments[i];
                  for (var key in source) {
                    if (Object.prototype.hasOwnProperty.call(source, key)) {
                      target[key] = source[key];
                    }
                  }
                }
                return target;
              };

              var model = _extends({}, this.model);

              this.$emit('selection', model);

              // hacky
              $('section.level_' + l).hide();
              $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");
              $('section.level_' + (l + 1)).css("display: flex");
            }

            if (l === 2) {
              this.$emit("toggle");
              this.isOpen = !this.isOpen;
            }
          }
        }
      });

      // define the table view component
      Vue.component('table-view', {
        template: '#table-view-template',
        props: ['model'],
        data: function() {
          return {}
        },
        methods: {
          getProject: function(model) {
            var l = this.model.level;

            // { ...this.model } conversion to ES2015
            var _extends = Object.assign || function(target) {
              for (var i = 1; i < arguments.length; i++) {
                var source = arguments[i];
                for (var key in source) {
                  if (Object.prototype.hasOwnProperty.call(source, key)) {
                    target[key] = source[key];
                  }
                }
              }
              return target;
            };

            var project = _extends({}, model);

            this.$emit('selection', project);

            // hacky
            $('section.level_' + l).hide();
            $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");
            $('section.level_' + (l + 1)).css("display: flex");
          }
        }
      });

      var app = new Vue({
        el: '#gobierto-planification',
        name: 'gobierto-planification',
        data: {
          json: {},
          activeNode: {},
          showTable: {},
          rootid: 0
        },
        created: function() {
          this.getJson();
        },
        watch: {
          activeNode: {
            handler: function(node) {
              this.showTable = {};
              this.isOpen(node.level);
            },
            deep: true
          }
        },
        computed: {
          globalProgress: function () {
            return _.meanBy(this.json, 'attributes.progress')
          }
        },
        methods: {
          getJson: function() {
            $.getJSON(window.location.href, function(json) {
              var data = json["plan_tree"];
              this.json = data;
            }.bind(this));
          },
          color: function() {
            return this.rootid % this.json.length + 1; // TODO: el mod no debe ser la longitud del array, sino, la de la variable de colores
          },
          setRootColor: function(index) {
            return index % this.json.length + 1;
          },
          setSelection: function(model) {
            this.activeNode = model;

            // To know the root node
            if (this.activeNode.level === 0) {
              // parse first position
              this.rootid = this.activeNode.uid.toString().charAt(0);
            }
          },
          isOpen: function(level) {
            return (level - 1) <= this.activeNode.level;
          },
          typeOf: function(val) {
            if (_.isString(val)) {
              return "string"
            } else if (_.isArray(val)) {
              return "array"
            }
            return "object";
          },
          toggle: function(i) {
            Vue.set(this.showTable, i, !(this.showTable[i]));
          },
          getParent: function() {
            this.activeNode = this.json[this.rootid].children[this.activeNode.parent];
          }
        }
      });

      //close everything
      $(document).click(function (e) {
        e.preventDefault();

        // if the target of the click isn't the container nor a descendant of the container REVIEW
        var container = $(".planification-content");
        if (!container.is(e.target) && container.has(e.target).length === 0) {
          app.activeNode = {};

          $('section.level_0').removeAttr('style');
          $('section.level_0 .js-img').removeAttr('style');
          $('section.level_0 .js-info').removeAttr('style');
          $('section.level_0 .js-info h3, section.level_1 .js-info span').removeAttr('style');
        }
      });
    };


    return PlansController;
  })();

  this.GobiertoPlans.plans_controller = new GobiertoPlans.PlansController;

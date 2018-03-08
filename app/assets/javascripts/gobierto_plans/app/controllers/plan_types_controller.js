this.GobiertoPlans.PlanTypesController = (function() {

    function PlanTypesController() {}

    PlanTypesController.prototype.show = function() {
      _loadPlan();
    };

    function _loadPlan() {

      // filters
      Vue.filter('translate', function (key) {
        if (!key) return
        return key[I18n.locale] || key["es"] || key["en"] || Object.values(key)[0] // fallback translations
      });

      Vue.filter('percent', function (value) {
        if (!value) return
        return (value / 100).toLocaleString(I18n.locale, { style: 'percent', maximumSignificantDigits: 4 })
      });

      Vue.filter('date', function (date) {
        if (!date) return
        return new Date(date).toLocaleString(I18n.locale, { year: 'numeric', month: 'short', day: 'numeric' })
      });

      // define the node root component
      Vue.component('node-root', {
        template: '#node-root-template',
        props: ['model'],
        data: function() {
          return {}
        },
        computed: {
          progressWidth: function () {
            // Apply programatically a vue global filter
            return Vue.filter('percent')(this.model.attributes.progress)
          }
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
          }
        }
      });

      // define the node list component
      Vue.component('node-list', {
        template: '#node-list-template',
        props: ['model', 'level'],
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
            }

            if (l === 2) {
              this.$emit("toggle");
              this.isOpen = !this.isOpen;
            }
          },
          getLabel: function(level, number_of_elements) {
            var key = this.level["level" + (level + 1)]
            return (number_of_elements == 1 ? key["one"] : key["other"])
          }
        }
      });

      // define the table view component
      Vue.component('table-view', {
        template: '#table-view-template',
        props: ['model', 'header', 'open'],
        data: function() {
          return {}
        },
        methods: {
          getProject: function(model) {
            if (this.open) {
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
            }
          }
        }
      });

      var app = new Vue({
        el: '#gobierto-planification',
        name: 'gobierto-planification',
        data: {
          json: {},
          levelKeys: {},
          optionKeys: [],
          activeNode: {},
          showTable: {},
          showTableHeader: true,
          openNode: false,
          rootid: 0
        },
        created: function() {
          this.getJson();
        },
        watch: {
          activeNode: {
            handler: function(node, old) {
              this.showTable = {};
              this.isOpen(node.level);
              animate(node.level);
            },
            deep: true
          }
        },
        computed: {
          globalProgress: function () {
            return _.meanBy(this.json, 'attributes.progress')
          },
          availableOpts: function () {
            // Filter options object only to those values present in the configuration (optionKeys)
            return _.pick(this.activeNode.attributes.options, _.filter(_.keys(this.activeNode.attributes.options), function (o) {
              return _.includes(_.keys(this.optionKeys), o.toString().toLowerCase())
            }.bind(this)));
          }
        },
        methods: {
          getJson: function() {
            $.getJSON(window.location.href, function(json) {
              // Tree with categories and the leaves (nodes)
              var data = json["plan_tree"];
              // Nodes can have variable attributes and these are their keys
              var optionKeys = json["option_keys"];
              // Keys for different levels
              var levelKeys = json["level_keys"];
              // If you can see the table header
              var showTableHeader = json["show_table_header"];
              // If you can open a node (project)
              var openNode = json["open_node"];

              // Hide spinner
              $(".js-toggle-overlay").removeClass('is-active');

              this.json = data;
              this.levelKeys = levelKeys;
              this.showTableHeader = showTableHeader;
              this.openNode = openNode;
              this.optionKeys = Object.keys(optionKeys).reduce(function(c, k) {
                return (c[k.toLowerCase()] = optionKeys[k]), c;
              }, {});
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
            if (this.activeNode.level === undefined) return false
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
          getLabel: function(level, number_of_elements) {
            var l = (_.keys(this.levelKeys).length === (level + 1)) ? level : (level + 1);
            var key = this.levelKeys["level" + l];
            return (number_of_elements == 1 ? key["one"] : key["other"]);
          },
          getParent: function() {
            // Initialize args
            var breakpoint = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : undefined;

            // From uid, turno into array all parents, and drop last item (myself)
            var ancestors = _.dropRight(this.activeNode.uid.split('.')).map(Number);

            var current = this.json; // First item. ROOT item
            for (var i = 0; i < ancestors.length; i++) {
              if (i === breakpoint) {
                // If there is breakpoint, I get the corresponding ancestor set by breakpoint
                break;
              }

              if (!_.isArray(current)) {
                current = current.children;
              }
              current = current[ancestors[i]];
            }

            return current || {}
          },
          setParent: function() {
            // Initialize args
            var breakpoint = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : undefined;
            //hack 3rd level (3rd level has no SECTION)
            if (breakpoint === 3) breakpoint = breakpoint - 1;

            this.activeNode = this.getParent(breakpoint);
          }
        }
      });

      // Velocity Animates
      function animate(l) {
        if (l === 0) {
          $('section.level_0 .js-img').hide();
          $('section.level_0 .js-info').velocity({
            padding: "1.5em"
          });
          $('section.level_0 .js-info h3, section.level_0 .js-info span').css({
            "font-size": "1.25rem"
          });
          $('section.level_0').velocity({
            flex: "0 0 25%"
          });
          $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");

          return
        }

        if (l !== 0 && l < 3) {
          $('section.level_' + l).hide();
          $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");

          return
        } else if (l >= 3) {
          $('section.level_' + (l - 1)).hide();
          $('section.level_' + l).velocity("transition.slideRightBigIn");

          return
        }

      }

      //close everything
      $(document).click(function (e) {
        // if the target of the click isn't the container nor a descendant of the container
        if (!$(e.target).closest('.planification-content').length) {
          app.activeNode = {};
          // Restore styles
          $('section.level_0, section.level_0 .js-img, section.level_0 .js-info, section.level_0 .js-info h3, section.level_1 .js-info span').removeAttr('style');
        }
      });
    }


    return PlanTypesController;
  })();

  this.GobiertoPlans.plan_types_controller = new GobiertoPlans.PlanTypesController;

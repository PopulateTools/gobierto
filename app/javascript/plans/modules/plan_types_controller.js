import { Vue } from 'shared'

window.GobiertoPlans.PlanTypesController = (function() {

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
            // Trigger event
            this.$emit('selection', { ...this.model });
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
            if (this.model.type === "category" && !this.model.max_level) {
              var model = { ...this.model };

              this.$emit('selection', model);
            }

            if (this.model.type === "category" && this.model.max_level) {
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
          getProject: function() {
            if (this.open) {
              var project = { ...this.model };

              this.$emit('selection', project);
            }
          }
        }
      });

      // main object
      new Vue({
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
            handler: function(node) {
              this.showTable = {};
              this.isOpen(node.level);
              animate(node.level, node.type);
              this.setPermalink()
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
            $.getJSON(window.location.href, {format: 'json'}, function(json) {
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

              // Parse permalink
              if (window.location.hash) {
                this.getPermalink(window.location.hash.substring(1))
              }

            }.bind(this));
          },
          color: function() {
            return this.rootid % this.json.length + 1;
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
          },
          setPermalink: function () {
            window.location.hash = btoa(this.activeNode.uid)
          },
          getPermalink: function (hash) {
            let uid

            try {
              uid = atob(hash)
            } catch (e) {
              // If permalink is wrong
              history.replaceState(null, null, ' ');
              return false
            }

            let found = this.searchByUid(uid, this.json)
            if (found) {
              this.setSelection(found)
            }
          },
          searchByUid: function(id, data) {
            let result = false

            if (_.isArray(data)) {
              _.each(data, d => {
                result = findNodeByProp(id, d, 'uid')

                // Return false to break loop
                if (result !== false) {
                  return false;
                }
              })
            } else {
              result = findNodeByProp(id, data, 'uid')
            }

            return result
          }
        }
      });

      // Velocity Animates
      function animate(l, type) {
        if (l === 0) {
          $('section.level_0 .js-img').hide();
          $('section.level_0 .js-info').velocity({
            padding: "1.5em"
          });
          $('section.level_0 .js-info h3, section.level_0 .js-info span').css({
            "font-size": "1.25rem"
          });
          $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");

          return
        }
        if (l !== 0 && type === "category") {
          $('section.level_' + l).hide();
          $('section.level_' + (l + 1)).velocity("transition.slideRightBigIn");

          return
        } else if (type === "node") {
          $('section.level_' + (l - 1)).hide();
          $('section.level_' + l).velocity("transition.slideRightBigIn");

          return
        }
      }

      function findNodeByProp(id, currentNode, prop = 'id') {
        var i,
          currentChild,
          result;

        if (id == currentNode[prop]) {
          return currentNode;
        } else {

          // Use a for loop instead of forEach to avoid nested functions
          // Otherwise "return" will not work properly
          for (i = 0; i < currentNode.children.length; i += 1) {
            currentChild = currentNode.children[i];

            // Search in the current child
            result = findNodeByProp(id, currentChild, prop);

            // Return the result if the node has been found
            if (result !== false) {
              return result;
            }
          }

          // The node has not been found and we have no more options
          return false;
        }
      }
    }

    return PlanTypesController;
  })();

  window.GobiertoPlans.plan_types_controller = new GobiertoPlans.PlanTypesController;
